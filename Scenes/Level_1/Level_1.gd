extends "res://Scenes/GenericMap.gd"

func _ready():
	# Super call to ready
	._ready()
	
	# Add the level 1 code directory to the file tree
	FileManager.copy_dir(Constants.LEVEL_1_CODE_DIR, Constants.PLAYER_CODE_DIR, true)
	
	# Update the IDE
	Player.ide_update_files()
	
	# Select the file we want
	var gettingStartedFile = FileManager.join(Constants.PLAYER_CODE_DIR, "Level_1_Code/GettingStarted")
	Player.get_ide().set_selected_file(gettingStartedFile)
	
	# Set the camera bounds
	get_camera().set_bounds_with_area(get_camera_area_part1())


""" GETTERS """

func get_camera():
	return $Camera


func get_camera_area_part1():
	return $CameraAreas/Part1


""" SIGNALS """

func _on_Finish_body_entered(body):
	$FinishedUI.visible = true