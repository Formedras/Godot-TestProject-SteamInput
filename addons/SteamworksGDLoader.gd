extends Node

@export var isSteamRunning = false
@export var isSteamInputRunning = false
@export var steamID = 0
@export var steamUsername = ""


var EnableSteamInput = true

func _ready():
	Steam.steamInit(true, 480)
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
	
@warning_ignore("unused_parameter")
func _process(delta):
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
static var GlyphBank = {}

func CheckGlyphBank(handle : Steam.InputActionOrigin) -> bool:
	return GlyphBank.has(handle)

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadGlyphIntoBank(handle: Steam.InputActionOrigin, style: Steam.InputGlyphStyle = Steam.INPUT_GLYPH_STYLE_LIGHT | Steam.INPUT_GLYPH_STYLE_SOLID_ABXY) -> void:
	if (CheckGlyphBank(handle)):
		return
	var path : String = Steam.getGlyphSVGForActionOrigin(handle, style)
	var image = Image.new()
	image.load(path)
	var glyph = ImageTexture.create_from_image(image)
	GlyphBank[handle] = glyph
#endregion