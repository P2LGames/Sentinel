extends Spatial

var viewStack = []

var selectedFile = ""
var selectedFilePath = ""

func _ready():
	# Add the main menu to the stack
	viewStack.append(get_main_menu())
	
	# Copy the generic code over
	FileManager.copy_dir(Constants.GENERIC_CODE_DIR, Constants.PLAYER_CODE_DIR)


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
	return $Menus/MainMenu


func get_level_select():
	return $Menus/LevelSelect


func get_load_level():
	return $Menus/LoadLevel


func get_save_game_list():
	return $Menus/LoadLevel/SaveGameList


""" SIGNALS """

func _on_NewGame_pressed():
	start_new_game()


func _on_load_game():
	print(selectedFilePath)
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
