extends Node2D

@export var FormGlyph : Texture2D
@export var DefaultGlyph : Texture2D
@export var GlyphCycleTimer : float = 2.0

var PlayerCont = [0, 0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !SteamworksInputLoader.isSteamInputRunning:
		return
		
	var StCont = Steam.getConnectedControllers()

	var SH_GameSecond = Steam.getActionSetHandle("SetGameSecond")
	var DH_Left = Steam.getDigitalActionHandle("BDLeftFlipper")
	var DH_Right = Steam.getDigitalActionHandle("BDRightFlipper")
	var DH_Pause = Steam.getDigitalActionHandle("BDPause")

	### SPECIAL NOTE: GameFirst Input Test and GameSecond Input Test are ALSO testing differnt methods
	### 			  of going across the player list. GameFirst treats them discretely as their own code;
	###				  GameSecond loops and needs control arrays.
	var AlreadySeekingInput : bool = false  # If already seeking input from a lower player number, don't seek for higher player numbers.
	for i in 4:
		if StCont.has(PlayerCont[i]):
			# Handle Player Input
			# Get and Display Glyphs
			var Or_Left = Steam.getDigitalActionOrigins(PlayerCont[i], SH_GameSecond, DH_Left)
			var Or_Right = Steam.getDigitalActionOrigins(PlayerCont[i], SH_GameSecond, DH_Right)
			for j in Or_Left + Or_Right:
				SteamworksGlyphBank.LoadGlyphIntoBank(j)
			if (Or_Left.size() > 0):
				var cur_tex = Or_Left[SteamworksGlyphBank.ButtonCycleCounter(Or_Left.size(), GlyphCycleTimer)]
				get_node("imgGlyphFlipperLeftP" + str(i+1)).texture = SteamworksGlyphBank.GlyphBank[cur_tex]
			else: get_node("imgGlyphFlipperLeftP" + str(i+1)).texture = DefaultGlyph
			if (Or_Right.size() > 0):
				var cur_tex = Or_Right[SteamworksGlyphBank.ButtonCycleCounter(Or_Right.size(), GlyphCycleTimer)]
				get_node("imgGlyphFlipperRightP" + str(i+1)).texture = SteamworksGlyphBank.GlyphBank[cur_tex]
			else: get_node("imgGlyphFlipperRightP" + str(i+1)).texture = DefaultGlyph
			# Take and process input
			Steam.activateActionSet(PlayerCont[i], SH_GameSecond)
			get_node("colFlipperLeftP" + str(i+1)).visible = Steam.getDigitalActionData(PlayerCont[i], DH_Left)["state"]
			get_node("colFlipperRightP" + str(i+1)).visible = Steam.getDigitalActionData(PlayerCont[i], DH_Right)["state"]
		else:
			# Controller Connection Not Found, Find Active Controller
			get_node("imgGlyphFlipperLeftP" + str(i+1)).texture = FormGlyph
			get_node("imgGlyphFlipperRightP" + str(i+1)).texture = FormGlyph
			get_node("colFlipperLeftP" + str(i+1)).visible = false
			get_node("colFlipperRightP" + str(i+1)).visible = false
			if AlreadySeekingInput: continue # Don't seek controller if already seeking
			for j in StCont:
				if PlayerCont.has(j): continue
				Steam.activateActionSet(j, SH_GameSecond) # REAL GAME should instead use "Menu" Set and seek "Confirm" Action instead
				if (Steam.getDigitalActionData(j, DH_Left)["state"] || Steam.getDigitalActionData(j, DH_Right)["state"]):
					PlayerCont[i] = j
					break
				pass
			pass
			AlreadySeekingInput = true
		pass
		#print(str(PlayerCont))


	# Get Pause Button glyphs and put them on screen
	var pause_button_handles = []
	for i in StCont:
		pause_button_handles += Steam.getDigitalActionOrigins(i, SH_GameSecond, DH_Pause)
	for i in pause_button_handles:
		SteamworksGlyphBank.LoadGlyphIntoBank(i)
	if (pause_button_handles.size() > 0):
		var cur_tex = pause_button_handles[SteamworksGlyphBank.ButtonCycleCounter(pause_button_handles.size(), GlyphCycleTimer)]
		$imgGlyphPause.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
	else:
		$imgGlyphPause.texture = FormGlyph
	# Check if Pause is pressed, switch to Main Menu if true
	for i in StCont:
		Steam.activateActionSet(i, SH_GameSecond)
		if (Steam.getDigitalActionData(i, DH_Pause))["state"]:
			print(str(get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")))
			pass
