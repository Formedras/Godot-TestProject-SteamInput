extends Node

@export var isSteamRunning = false
@export var isSteamInputRunning = false
@export var steamID = 0
@export var steamUsername = ""

var steamAppID = 480 # Spacewar is 480. Use that for testing stuff if you don't have your own AppID.
var EnableSteamInput = true # Create an IGA file and copy or symlink it to "%SteamInstallFolder%\controller_config\" as "game_actions_%steamAppID%.vdf" to use this.

func _ready():
	Steam.steamInit(true, steamAppID)
	isSteamRunning = Steam.isSteamRunning()

	if (!isSteamRunning):
		print("Steam is not running.")
		return

	print("Steam is running.")

	steamID = Steam.getSteamID()
	steamUsername = str(Steam.getFriendPersonaName(steamID))
	
	print("Your steam name: " + steamUsername)

	if (EnableSteamInput):
		InitSteamInput()
	
func _process(_delta):
	if isSteamRunning:
		Steam.run_callbacks()

func _exit_tree():
	if (isSteamInputRunning):
		Steam.inputShutdown()
	if isSteamRunning:
		Steam.steamShutdown()

func InitSteamInput():
	isSteamInputRunning = Steam.inputInit(false)
	if (isSteamInputRunning):
		print("Steam Input Enabled")
	else:
		print("Steam Input Failed")

#region GlyphBank
static var GlyphBank = {} # Key = Handle : int, Value = Glyph : Texture2D
static var TotalGlyphRef = {} # Key = Handle: int, Value = Path : string
static var LocalGlyphRef = {} # Key = Handle : int, Value = LocalPath : string

func CheckGlyphBank(handle : Steam.InputActionOrigin) -> bool:
	return GlyphBank.has(handle)

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadGlyphIntoBank(handle: Steam.InputActionOrigin, override_existing : bool = false, style: Steam.InputGlyphStyle = Steam.INPUT_GLYPH_STYLE_LIGHT | Steam.INPUT_GLYPH_STYLE_SOLID_ABXY, steam_svg : bool = true) -> void:
	# Loads a button glyph into the Glyph Bank; prioritizes local glyphs over Steam-supplied ones.
	if (CheckGlyphBank(handle) && !override_existing):
		return

	if (LocalGlyphRef.has(handle)):
		LoadLocalGlyphIntoBank(handle, override_existing)
	else:
		LoadSteamGlyphIntoBank(handle, override_existing, style, steam_svg)
	
	pass

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadSteamGlyphIntoBank(handle: Steam.InputActionOrigin, override_existing : bool = false, style: Steam.InputGlyphStyle = Steam.INPUT_GLYPH_STYLE_LIGHT | Steam.INPUT_GLYPH_STYLE_SOLID_ABXY, steam_svg : bool = true, steam_png_size : Steam.InputGlyphSize = Steam.INPUT_GLYPH_SIZE_LARGE) -> void:
	# Loads a button glyph from Steam into the Glyph Bank. Doesn't consider local glyphs.
	if (CheckGlyphBank(handle) && !override_existing):
		return
	var path : String
	if (steam_svg):
		path = Steam.getGlyphSVGForActionOrigin(handle, style)
	else:
		path = Steam.getGlyphPNGForActionOrigin(handle, steam_png_size, style)
	TotalGlyphRef[handle] = path
	var image = Image.new()
	image.load(path)
	var glyph = ImageTexture.create_from_image(image)
	GlyphBank[handle] = glyph
	pass

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadLocalGlyphIntoBank(handle: Steam.InputActionOrigin, override_existing : bool = false) -> void:
	if (CheckGlyphBank(handle) && !override_existing):
		return
	if (!LocalGlyphRef.has(handle)):
		#assert (false, "Local Glyph Not Available")
		push_error("Local Glyph Not Available")
		return
	var path : String = LocalGlyphRef[handle]
	TotalGlyphRef[handle] = path
	var image = Image.new()
	image.load(path)
	var glyph = ImageTexture.create_from_image(image)
	GlyphBank[handle] = glyph
	pass

# Takes a JSON string and loads it into the LocalGlyphRef. If "fullpreload" is true, also loads the each glyph from this string into the GlyphBank.
# Currently untested. JSON keys must be strings; importing a file with number-string keys may or may not work properly.
func LoadLocalGlyphRef(glyphref, fullpreload : bool = false) -> void:
	var glyphs : Dictionary = JSON.parse_string(glyphref)
	LocalGlyphRef.merge(glyphs)
	if fullpreload:
		for glyph in glyphs:
			LoadLocalGlyphIntoBank(glyph, true)

# Takes a path to a JSON file, parses it using LoadLocalGlyphRef, and loads it into the LocalGlyphRef.
# If "fullpreload" is true, also loads the each glyph from this string into the GlyphBank.
#func LoadLocalGlyphRefFromFile(glyphref, fullpreload : bool = false) -> void:
#	
#	pass

# Takes a number of elements (not the elements themselves) and how long each element should be on-screen, and based on time, returns the index of which element should be displayed.
func ButtonCycleCounter(count : int, timer : float) -> int:
	@warning_ignore("integer_division")
	@warning_ignore("narrowing_conversion")
	return ((Time.get_ticks_msec() % int(count * timer * 1000)) / (timer * 1000))
#endregion
