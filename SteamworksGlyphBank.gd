extends Node

## The Glyph Bank is a collection of images for controller buttons, dictionary keyed to Steam Input control IDs.
## The bank has no mechanism to delete glyphs at this point, so it's a potential memory usage issue. That said, it should only be holding up to 100 small images in uncommon conditions (and far less normally), so that issue should be negligible in modern computers.

static var GlyphCycleTimer : float = 1.0
static var GlyphBank = {}
static var LocalGlyphRef = {}

func CheckGlyphBank(handle : Steam.InputActionOrigin) -> bool:
	return GlyphBank.has(handle)

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadGlyphIntoBank(handle : Steam.InputActionOrigin, override_existing : bool = false, style: Steam.InputGlyphStyle = Steam.INPUT_GLYPH_STYLE_LIGHT | Steam.INPUT_GLYPH_STYLE_SOLID_ABXY, steam_svg : bool = true) -> void:
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
func LoadSteamGlyphIntoBank(handle : Steam.InputActionOrigin, override_existing : bool = false, style: Steam.InputGlyphStyle = Steam.INPUT_GLYPH_STYLE_LIGHT | Steam.INPUT_GLYPH_STYLE_SOLID_ABXY, steam_svg : bool = true, steam_png_size : Steam.InputGlyphSize = Steam.INPUT_GLYPH_SIZE_LARGE) -> void:
	# Loads a button glyph from Steam into the Glyph Bank. Doesn't consider local glyphs.
	if (CheckGlyphBank(handle) && !override_existing):
		return
	var path : String
	if (steam_svg):
		path = Steam.getGlyphSVGForActionOrigin(handle, style)
	else:
		path = Steam.getGlyphPNGForActionOrigin(handle, steam_png_size, style)
	var image = Image.new()
	image.load(path)
	var glyph = ImageTexture.create_from_image(image)
	GlyphBank[handle] = glyph
	pass

@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
func LoadLocalGlyphIntoBank(handle : Steam.InputActionOrigin, override_existing : bool = false) -> void:
	if (CheckGlyphBank(handle) && !override_existing):
		return
	if (!LocalGlyphRef.has(handle)):
		#assert (false, "Local Glyph Not Available")
		push_error("Local Glyph Not Available")
		return
	var path : String = LocalGlyphRef[handle]
	var image = Image.new()
	image.load(path)
	var glyph = ImageTexture.create_from_image(image)
	GlyphBank[handle] = glyph
	pass

# Takes a number of elements and how long each element should be on-screen, and based on time, returns the index of which element should be displayed.
func ButtonCycleCounter(count : int, timer : float) -> int:
	@warning_ignore("integer_division")
	@warning_ignore("narrowing_conversion")
	return ((Time.get_ticks_msec() % int(count * timer * 1000)) / (timer * 1000))

func getBankSize() -> int:
	return GlyphBank.size()
