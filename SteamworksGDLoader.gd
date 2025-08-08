extends Node
## Loads Steamworks

@export var isSteamRunning : bool = false
@export var steamID = 0
@export var steamUsername = ""

var steamAppID = 480
## appID should be set to your game's Steam Application ID. The default is 480, corresponding to demo project Spacewar.

var EnableSteamInput = true

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

	
@warning_ignore("unused_parameter")
func _process(delta):
	if isSteamRunning:
		Steam.run_callbacks()

func _exit_tree():
	if (SteamworksInputLoader.isSteamInputRunning): # Remove this and the next line if you aren't using the Steam Input loader.
		Steam.inputShutdown()
	if isSteamRunning:
		Steam.steamShutdown()
