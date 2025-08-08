extends Node2D

@export var DefaultGlyph : Texture2D
@export var GlyphCycleTimer : float = 2.0

var confirm_pressed_last_frame : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !SteamworksInputLoader.isSteamInputRunning:
		return

	var StCont = Steam.getConnectedControllers()
	if (StCont.size() < 1):
		$imgGlyphConfirm.texture = DefaultGlyph
		$imgGlyphGameFirst.texture = DefaultGlyph
		$imgGlyphGameSecond.texture = DefaultGlyph
		return
	
	var confirm_handle = Steam.getDigitalActionHandle("MenuConfirm")
	var gamefirst_handle = Steam.getDigitalActionHandle("DebugGameFirst")
	var gamesecond_handle = Steam.getDigitalActionHandle("DebugGameSecond")
	var menuset_handle = Steam.getActionSetHandle("SetMenu")
	var json_handle = Steam.getDigitalActionHandle("MenuGlyphJSON")

	var confirm_button_handles = []
	var gamefirst_button_handles = []
	var gamesecond_button_handles = []
	for i in StCont:
		confirm_button_handles += Steam.getDigitalActionOrigins(i, menuset_handle, confirm_handle)
		gamefirst_button_handles += Steam.getDigitalActionOrigins(i, menuset_handle, gamefirst_handle)
		gamesecond_button_handles += Steam.getDigitalActionOrigins(i, menuset_handle, gamesecond_handle)
	for i in confirm_button_handles:
		SteamworksGlyphBank.LoadGlyphIntoBank(i)
	for i in gamefirst_button_handles:
		SteamworksGlyphBank.LoadGlyphIntoBank(i)
	for i in gamesecond_button_handles:
		SteamworksGlyphBank.LoadGlyphIntoBank(i)
		
	if (confirm_button_handles.size() > 0):
		var cur_tex = confirm_button_handles[SteamworksGlyphBank.ButtonCycleCounter(confirm_button_handles.size(), GlyphCycleTimer)]
		$imgGlyphConfirm.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
	else:
		$imgGlyphConfirm.texture = DefaultGlyph
	if (gamefirst_button_handles.size() > 0):
		var cur_tex = gamefirst_button_handles[SteamworksGlyphBank.ButtonCycleCounter(gamefirst_button_handles.size(), GlyphCycleTimer)]
		$imgGlyphGameFirst.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
	else:
		$imgGlyphConfirm.texture = DefaultGlyph
	if (gamesecond_button_handles.size() > 0):
		var cur_tex = gamesecond_button_handles[SteamworksGlyphBank.ButtonCycleCounter(gamesecond_button_handles.size(), GlyphCycleTimer)]
		$imgGlyphGameSecond.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
	else:
		$imgGlyphConfirm.texture = DefaultGlyph

	var confirm_pressed = false
	for i in StCont:
		Steam.activateActionSet(i, menuset_handle)

		confirm_pressed = Steam.getDigitalActionData(i, confirm_handle)["state"] || confirm_pressed

		if (Steam.getDigitalActionData(i, gamefirst_handle))["state"]:
			print(str(get_tree().change_scene_to_file("res://Scenes/gamefirst_input_test.tscn")))
		if (Steam.getDigitalActionData(i, gamesecond_handle))["state"]:
			print(str(get_tree().change_scene_to_file("res://Scenes/gamesecond_input_test.tscn")))
		if (Steam.getDigitalActionData(i, json_handle))["state"]:
			print(GlyphRefToJSON())

	if confirm_pressed && !confirm_pressed_last_frame:
		SavedVariables.ConfirmPressed += 1
	confirm_pressed_last_frame = confirm_pressed
	$lblConfirmPressed.text = str(SavedVariables.ConfirmPressed)

func GlyphRefToJSON() -> String:
	var output = ""
	if (FileAccess.file_exists("user://glyphref.json")):
		return "EXISTS"
	var file = FileAccess.open("user://glyphref.json", FileAccess.WRITE)
	output = JSON.stringify(SteamworksGdLoader.TotalGlyphRef)
	file.store_string(output)
	file.close()
	return output
