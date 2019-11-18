extends "res://Scenes/GenericMap.gd"

var bodiesInFinish = []

func _ready():
	# Super call to ready
	._ready()
	
	# Add the level 1 code directory to the file tree
	FileManager.copy_dir(Constants.LEVEL_2_CODE_DIR, Constants.PLAYER_CODE_DIR)
	
	# Update the IDE
	Player.ide_update_files()
	
	# Set the camera bounds
	set_camera_part1()


func player_won():
	Player.push_view_to_stack(get_won_ui())


""" GETTERS """

func get_camera():
	return $Camera


func get_camera_part1():
	return $CameraAreas/Part1


func get_won_ui():
	return $CanvasLayer/WonUI


func get_won_quit_button():
	return $CanvasLayer/WonUI/Quit


func get_objectives_ui():
	return $CanvasLayer/Objectives


""" SETTERS """

func set_camera_part1():
	get_camera().set_bounds_with_area(get_camera_part1())


""" SIGNALS """

func _on_game_pause():
	pass


func _on_game_resume():
	pass
