extends Spatial

var viewStack = []


func _ready():
	# Add the main menu to the stack
	viewStack.append(get_main_menu())


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


""" SIGNALS """

func _on_NewGame_pressed():
	start_new_game()


func _on_PlayLevel_pressed():
	pass # Replace with function body.


func _on_LoadGame_pressed():
	# Load the selected game
	pass # Replace with function body.


func _on_LevelSelect_pressed():
	push_view_to_stack(get_level_select())


func _on_LoadGameMenu_pressed():
	push_view_to_stack(get_load_level())


func _on_QuitGame_pressed():
	# Quit the game
	get_tree().quit()


func _on_Back_pressed():
	pop_view_from_stack()