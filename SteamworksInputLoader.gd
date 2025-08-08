extends Node
## Loads Steam Input, but only if Steam is running.

@export var isSteamInputRunning : bool = false

@export var ManualUpdates : bool = false
## ManualUpdates determines if you need to call Steam.runFrame() every frame when you need to poll controls.
## Unless you have special reasons that you need to manually get input state at specific times, you should probably keep this as false.

func _ready():
	if (SteamworksGdLoader.isSteamRunning):
		InitSteamInput()
		# InitSteamInput is a separate function in case it doesn't work right on load, so that the game can try to run it later.

func InitSteamInput():
	isSteamInputRunning = Steam.inputInit(!ManualUpdates)
	if (isSteamInputRunning):
		print("Steam Input Enabled")
	else:
		print("Steam Input Failed")
		
