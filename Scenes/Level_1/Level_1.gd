extends "res://Scenes/GenericMap.gd"

func _ready():
	# Super call to ready
	._ready()
	
	# Add the level 1 code directory to the file tree
#	Player.get_ide().add_directory(Constants.LEVEL_1_CODE_DIR)
	FileManager.copy_dir(Constants.LEVEL_1_CODE_DIR, Constants.PLAYER_CODE_DIR)


""" SIGNALS """

func _on_Finish_body_entered(body):
	$FinishedUI.visible = true