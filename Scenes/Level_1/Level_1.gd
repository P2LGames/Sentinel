extends "res://Scenes/GenericMap.gd"

var bodiesInFinish = []

func _ready():
	# Super call to ready
	._ready()
	
	# Add the level 1 code directory to the file tree
	FileManager.copy_dir(Constants.LEVEL_1_CODE_DIR, Constants.PLAYER_CODE_DIR)
	
	# Update the IDE
	Player.ide_update_files()
	
	# Select the file we want
	var gettingStartedFile = FileManager.join(Constants.PLAYER_CODE_DIR, "Default/GettingStarted")
	Player.get_ide().set_selected_file(gettingStartedFile)
	
	# Set the camera bounds
	set_camera_part1()
	
	# Set the quit button in the win window to quit via the player's quit
	get_won_quit_button().connect("pressed", Player, "_on_QuitGame_pressed")


func check_player_won():
	if bodiesInFinish.size() == 2:
		player_won()


func player_won():
	Player.push_view_to_stack(get_won_ui())
	
	# Hide everything else
	get_hint_toggle().visible = false
	get_tutorial_ui().visible = false
	get_objectives_ui().visible = false


""" GETTERS """

func get_camera():
	return $Camera


func get_camera_part1():
	return $CameraAreas/Part1


func get_tutorial_ui():
	return $CanvasLayer/HintsPanel


func get_hint_toggle():
	return $CanvasLayer/ToggleVisible


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

func _on_Part1Finish_body_entered(body):
	pass


func _on_Part2Finish_body_entered(body):
	bodiesInFinish.append(body)
	
	check_player_won()


func _on_Part2Finish_body_exited(body):
	bodiesInFinish.erase(body)
	
	check_player_won()


func _on_ToggleVisible_pressed():
	var tutUI = get_tutorial_ui()
	# Toggle the tutorial UI and change the toggle text
	if tutUI.visible:
		tutUI.visible = false
		
		# Change toggle text
		get_hint_toggle().text = "Show"
	else:
		tutUI.visible = true
		
		# Change toggle text
		get_hint_toggle().text = "Hide"


func _on_game_pause():
	get_tutorial_ui().visible = false
	get_hint_toggle().visible = false
	get_objectives_ui().visible = false


func _on_game_resume():
	get_tutorial_ui().visible = true
	get_hint_toggle().visible = true
	get_objectives_ui().visible = true
