extends Spatial

var viewStack = []

var selectedFilePath = ""

func _ready():
	OS.set_borderless_window(true)
	OS.set_window_size(OS.get_screen_size())
	OS.set_window_position(Vector2(0, 0))
	
	# Add the main menu to the stack
	viewStack.append(get_main_menu())
	
	# Copy the generic code over
	FileManager.copy_dir(Constants.GENERIC_CODE_DIR, Constants.PLAYER_CODE_DIR)
	
	# Run the idle animation
	run_idle()
	
	Player._on_new_scene(self)


func run_idle():
	# Get the tween
	var tween = $Sentinel/Tween
	var sensor = $Sentinel/AttachmentContainer/Head/Sensor
	
	# Get the start and ending rotation
	var startRot = sensor.rotation_degrees
	var targetRot = Vector3.ZERO
	
	# Get the random rotation to get to
	targetRot.y = randf() * 60 - 30
	
	# Define a max left and right for the head rotation
	var maxLeft = -42.0
	var maxRight = 23.0
	
	# Reflect the target if it goes past our maxes
	if startRot.y + targetRot.y > maxRight or startRot.y + targetRot.y < maxLeft:
		targetRot.y *= -1
	
	# Get the rotation time
	var rotationTime = abs(targetRot.y) / 20
	
	# Setup the animation and run it
	tween.interpolate_property(sensor, "rotation_degrees", startRot, startRot + targetRot, rotationTime,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func start_new_game():
	SceneManager.go_to_level_1()


func push_view_to_stack(view):
	# Make the current view invisible
	viewStack[viewStack.size() - 1].visible = false
	
	# Add the view to the stack
	viewStack.append(view)
	
	# Make the view visible
	view.visible = true


func pop_view_from_stack():
	# Pop and hide the last view
	viewStack.pop_back().visible = false
	
	# Set the last view in the stack to be visible
	viewStack[viewStack.size() - 1].visible = true


""" GETTERS """

func get_main_menu():
	return $Menus/MenuContainer/MainMenu


func get_level_select():
	return $Menus/MenuContainer/LevelSelect


func get_load_level():
	return $Menus/MenuContainer/LoadLevel


func get_save_game_list():
	return $Menus/MenuContainer/LoadLevel/SaveGameList


""" SIGNALS """

func _on_NewGame_pressed():
	start_new_game()


func _on_load_game():
	if selectedFilePath != "":
		SavingManager.load_game(selectedFilePath)


func _on_LevelSelect_pressed():
	push_view_to_stack(get_level_select())


func _on_LoadGameMenu_pressed():
	push_view_to_stack(get_load_level())


func _on_QuitGame_pressed():
	# Quit the game
	get_tree().quit()


func _on_Back_pressed():
	pop_view_from_stack()


func _on_SaveGameList_file_selected(fileName, fileNameActual, filePath):
	selectedFilePath = filePath


func _on_Delete_pressed():
	# Delete the currently selected file, if it's there
	if selectedFilePath != "":
		SavingManager.delete_saved_game(selectedFilePath)


func _on_Tween_tween_completed(object, key):
	$Sentinel/Timer.start()


func _on_Timer_timeout():
	run_idle()
