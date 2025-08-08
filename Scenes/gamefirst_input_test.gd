extends Node2D

@export var FormGlyph : Texture2D
@export var DefaultGlyph : Texture2D
@export var GlyphCycleTimer : float = 2.0
@export var MaxRotation : float = 45.0

var P1Handle = 0
var P2Handle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !SteamworksInputLoader.isSteamInputRunning:
		return
		
	var StCont = Steam.getConnectedControllers()

	var SH_GameFirst = Steam.getActionSetHandle("SetGameFirst")
	var LH_Movable = Steam.getActionSetHandle("LayerGameFirstMovable")
	var DH_Fire = Steam.getDigitalActionHandle("CFFire")
	var DH_Take = Steam.getDigitalActionHandle("CFTake")
	var DH_Load = Steam.getDigitalActionHandle("CFLoad")
	var DH_Pause = Steam.getDigitalActionHandle("CFPause")
	var AH_Aim = Steam.getAnalogActionHandle("CFAim")

	### SPECIAL NOTE: GameFirst Input Test and GameSecond Input Test are ALSO testing differnt methods
	### 			  of going across the player list. GameFirst treats them discretely as their own code;
	###				  GameSecond loops and needs control arrays.
	if StCont.has(P1Handle):
		# Handle P1 Input
		# Get Glyphs
		var Or_Fire = Steam.getDigitalActionOrigins(P1Handle, SH_GameFirst, DH_Fire)
		var Or_Take = Steam.getDigitalActionOrigins(P1Handle, SH_GameFirst, DH_Take)
		var Or_Load = Steam.getDigitalActionOrigins(P1Handle, SH_GameFirst, DH_Load)
		var Or_Aim = Steam.getAnalogActionOrigins(P1Handle, SH_GameFirst, AH_Aim)
		for i in Or_Fire + Or_Take + Or_Load + Or_Aim:
			SteamworksGlyphBank.LoadGlyphIntoBank(i)

		# Display Glyphs
		if (Or_Fire.size() > 0):
			var cur_tex = Or_Fire[SteamworksGlyphBank.ButtonCycleCounter(Or_Fire.size(), GlyphCycleTimer)]
			$imgGlyphFireP1.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphFireP1.texture = DefaultGlyph
		if (Or_Take.size() > 0):
			var cur_tex = Or_Take[SteamworksGlyphBank.ButtonCycleCounter(Or_Take.size(), GlyphCycleTimer)]
			$imgGlyphTakeP1.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphTakeP1.texture = DefaultGlyph
		if (Or_Load.size() > 0):
			var cur_tex = Or_Load[SteamworksGlyphBank.ButtonCycleCounter(Or_Load.size(), GlyphCycleTimer)]
			$imgGlyphLoadP1.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphLoadP1.texture = DefaultGlyph
		if (Or_Aim.size() > 0):
			var cur_tex = Or_Aim[SteamworksGlyphBank.ButtonCycleCounter(Or_Aim.size(), GlyphCycleTimer)]
			$imgGlyphAimP1.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphAimP1.texture = DefaultGlyph

		# Check inputs and act
		Steam.activateActionSet(P1Handle, SH_GameFirst)
		$colBGTakeP1.visible = Steam.getDigitalActionData(P1Handle, DH_Take)["state"]
		$colBGFireP1.visible = Steam.getDigitalActionData(P1Handle, DH_Fire)["state"]
		$colBGLoadP1.visible = Steam.getDigitalActionData(P1Handle, DH_Load)["state"]
		var rot = Steam.getAnalogActionData(P1Handle, AH_Aim)["x"]
		$colBGAimP1.visible = (abs(rot) >= 0.1)
		$imgGlyphAimP1.rotation_degrees = rot * MaxRotation
		pass
	else:
		# No P1 Controller Available
		$imgGlyphTakeP1.texture = FormGlyph
		$imgGlyphLoadP1.texture = FormGlyph
		$imgGlyphAimP1.texture = FormGlyph
		$imgGlyphFireP1.texture = FormGlyph
		
		$colBGTakeP1.visible = false
		$colBGFireP1.visible = false
		$colBGLoadP1.visible = false
		$colBGAimP1.visible = false
		$imgGlyphAimP1.rotation_degrees = 0

		# Get P1 Controller
		for i in StCont:
			if i == P2Handle: continue
			Steam.activateActionSet(i, SH_GameFirst) # REAL GAME should instead use "Menu" Set and seek "Confirm" Action instead
			if (Steam.getDigitalActionData(i, DH_Fire))["state"]:
				P1Handle = i
				break

	if (StCont.has(P2Handle) && (P1Handle != P2Handle)):
		# Handle P2 Input
		# Get Glyphs
		var Or_Fire = Steam.getDigitalActionOrigins(P2Handle, SH_GameFirst, DH_Fire)
		var Or_Take = Steam.getDigitalActionOrigins(P2Handle, SH_GameFirst, DH_Take)
		var Or_Load = Steam.getDigitalActionOrigins(P2Handle, SH_GameFirst, DH_Load)
		var Or_Aim = Steam.getAnalogActionOrigins(P2Handle, SH_GameFirst, AH_Aim)
		for i in Or_Fire + Or_Take + Or_Load + Or_Aim:
			SteamworksGlyphBank.LoadGlyphIntoBank(i)

		# Display Glyphs
		if (Or_Fire.size() > 0):
			var cur_tex = Or_Fire[SteamworksGlyphBank.ButtonCycleCounter(Or_Fire.size(), GlyphCycleTimer)]
			$imgGlyphFireP2.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphFireP2.texture = DefaultGlyph
		if (Or_Take.size() > 0):
			var cur_tex = Or_Take[SteamworksGlyphBank.ButtonCycleCounter(Or_Take.size(), GlyphCycleTimer)]
			$imgGlyphTakeP2.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphTakeP2.texture = DefaultGlyph
		if (Or_Load.size() > 0):
			var cur_tex = Or_Load[SteamworksGlyphBank.ButtonCycleCounter(Or_Load.size(), GlyphCycleTimer)]
			$imgGlyphLoadP2.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphLoadP2.texture = DefaultGlyph
		if (Or_Aim.size() > 0):
			var cur_tex = Or_Aim[SteamworksGlyphBank.ButtonCycleCounter(Or_Aim.size(), GlyphCycleTimer)]
			$imgGlyphAimP2.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
		else: $imgGlyphAimP2.texture = DefaultGlyph

		# Check Inputs and act
		Steam.activateActionSet(P2Handle, SH_GameFirst)
		$colBGTakeP2.visible = Steam.getDigitalActionData(P2Handle, DH_Take)["state"]
		$colBGFireP2.visible = Steam.getDigitalActionData(P2Handle, DH_Fire)["state"]
		$colBGLoadP2.visible = Steam.getDigitalActionData(P2Handle, DH_Load)["state"]
		var rot = Steam.getAnalogActionData(P2Handle, AH_Aim)["x"]
		$colBGAimP2.visible = (abs(rot) >= 0.1)
		$imgGlyphAimP2.rotation_degrees = rot * MaxRotation
		pass
	else:
		# No P2 Controller Available
		$imgGlyphTakeP2.texture = FormGlyph
		$imgGlyphLoadP2.texture = FormGlyph
		$imgGlyphAimP2.texture = FormGlyph
		$imgGlyphFireP2.texture = FormGlyph

		$colBGTakeP2.visible = false
		$colBGFireP2.visible = false
		$colBGLoadP2.visible = false
		$colBGAimP2.visible = false
		$imgGlyphAimP2.rotation_degrees = 0
		if StCont.has(P1Handle):
			# Get P2 Controller only if P1 Controller already valid
			for i in StCont:
				if i == P1Handle: continue
				Steam.activateActionSet(i, SH_GameFirst) # REAL GAME should instead use Menu set and seek "Confirm" Action instead
				if (Steam.getDigitalActionData(i, DH_Fire))["state"]:
					P2Handle = i
					break

	#print(str(P1Handle) + ", " + str(P2Handle))
	# Get Pause Button glyphs and put them on screen
	var pause_button_handles = []
	for i in StCont:
		pause_button_handles += Steam.getDigitalActionOrigins(i, SH_GameFirst, DH_Pause)
	for i in pause_button_handles:
		SteamworksGlyphBank.LoadGlyphIntoBank(i)
	if (pause_button_handles.size() > 0):
		var cur_tex = pause_button_handles[SteamworksGlyphBank.ButtonCycleCounter(pause_button_handles.size(), GlyphCycleTimer)]
		$imgGlyphPause.texture = SteamworksGlyphBank.GlyphBank[cur_tex]
	else:
		$imgGlyphPause.texture = DefaultGlyph

	# Check if Pause is pressed, switch to Main Menu if true
	for i in StCont:
		Steam.activateActionSet(i, SH_GameFirst)
		if (Steam.getDigitalActionData(i, DH_Pause))["state"]:
			print(str(get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")))
			pass
		
