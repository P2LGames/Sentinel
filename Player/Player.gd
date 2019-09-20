extends Spatial

# Current camera
var camera = null

# Entities
var pressedKeys = []
var selectedEntities = []
var inspectedEntity = null
var isSelectingMultiple = false

# ide and output
var outputRepopup = false
var ide = null

# Input and views
var shouldProcessInput = false
var viewStack = []

signal game_pause()
signal game_resume()
signal game_save()
signal game_quit()

func _ready():
	# Get the ide
	ide = get_ide()
	
	# Connect myself to the scene manager so I know when a game has started
	SceneManager.connect("game_start", self, "_on_game_start")
	SceneManager.connect("new_scene", self, "_on_new_scene")


func game_pause():
	# Emit the pause game signals
	emit_signal("game_pause")
	
	# Show the menus container
	get_menu_container().visible = true
	
	# Hide the ingame UI, show the pause menu
	push_view_to_stack(get_pause_menu())
	
	# Pause the scene
	get_tree().paused = true


func game_resume():
	# Emit the pause game signal
	emit_signal("game_resume")
	
	# Hide the menus container
	get_menu_container().visible = false
	
	# Hide the ingame UI, show the pause menu
	pop_view_from_stack()
	
	# Unpause the scene
	get_tree().paused = false


func game_save(fileName):
	# Save the game
	SavingManager.save_game(fileName)
	
	# Remove the text from the line edit
	get_save_game_line_edit().text = ""
	get_save_game_line_edit().emit_signal("text_changed", "")
	
	# Go back to the pause menu
	pop_view_from_stack()
	
	# Update the save game list
	get_save_game_list().update()


""" INPUT """

func _process(delta):
	if shouldProcessInput:
		handle_input()


func _physics_process(delta):
	if shouldProcessInput:
		handle_mouse_inputs()


func _unhandled_key_input(event):
	# If we should process input
	if not shouldProcessInput:
		return
	
	# If we pressed the key
	if event.pressed:
		# And the input is not in our pressed keys
		if not pressedKeys.has(event.scancode):
			# Add the key
			pressedKeys.append(event.scancode)
			
			# Set the input of our entities
			handle_key_input(event.scancode, event.pressed)
	# Otherwise, we released the key
	else:
		# If the pressed keys has the scancode
		if pressedKeys.has(event.scancode):
			# Then remove the scancode
			pressedKeys.erase(event.scancode)
			
			# And set the input of our entities
			handle_key_input(event.scancode, event.pressed)


func handle_key_input(code: int, pressed: int):
	# Loop through all of hte selected entities
	for entity in selectedEntities:
		# If we can send them the key input, then send it
		if entity.has_method("send_key_input"):
			entity.send_key_input(code, pressed)


func handle_input():
	# Show editor if tab is pressed
	if not ide.visible and Input.is_action_just_pressed("show_ide"):
		ide_show()
	# Show the output if tilde is pressed
	elif (not ide.visible 
		and not get_output_popup().visible 
		and Input.is_action_just_pressed("show_output")):
		output_show()
	# Pause the game if escape is pressed
	elif (not ide.visible 
		and not get_output_popup().visible 
		and not get_pause_menu().visible
		and Input.is_action_just_pressed("hide_window")):
		game_pause()
	elif (get_pause_menu().visible
		and Input.is_action_just_pressed("hide_window")):
		game_resume()
	
	# If we want to select multiple people we can
	isSelectingMultiple = Input.is_action_pressed("select_multiple")


func handle_mouse_inputs():
	# Handle user mouse events
	if Input.is_action_just_pressed("left_click"):
		# Get the clicked entity
		var clickedEntity = get_clicked_entity()
		
		# See if we can select that entity
		if clickedEntity != null and clickedEntity.has_method("_select"):
			# Then we left clicked on an entity, select it
			left_clicked_on_entity(clickedEntity)
		else:
			deselect()
	# Right Click
	elif Input.is_action_just_released("right_click"):
		right_click(0)
	elif Input.is_action_just_pressed("right_click"):
		right_click(1)
	# Q Pressed and IDE is invisible
	elif not ide.visible and Input.is_action_just_pressed("inspect_entity"):
		# Get the clicked entity
		var clickedEntity = get_clicked_entity()
		
		# See if we can select that entity
		if clickedEntity:
			# Then we left clicked on an entity, select it
			inspect_entity(clickedEntity)


func right_click(pressed: int):
	# Get the clicked point
	var clickedPoint = get_clicked_point()
	
	# If it is null, stop
	if clickedPoint == null:
		return
	
	# Loop through all of hte selected entities
	for entity in selectedEntities:
		# If we can send them the click input, then send it
		if entity.has_method("send_click_input"):
			entity.send_click_input(clickedPoint.x, clickedPoint.z, pressed)


func get_clicked_point():
	# Get the physics world
	var physicsSpace = get_world().direct_space_state
	
	# Get the mouse position
	var mousePosition = get_viewport().get_mouse_position()
	
	# Get the camera origin and target
	var from = camera.project_ray_origin(mousePosition)
	var to = from + camera.project_ray_normal(mousePosition) * Constants.CLICK_RAY_LENGTH
	
	# Cast a ray
	var result = physicsSpace.intersect_ray(from, to)
	
	# If we intersected something
	if result:
		return result.position
	else: 
		return null


""" ENTITY HANDLING """

func get_clicked_entity():
	# Get the physics world
	var physicsSpace = get_world().direct_space_state
	
	# Get the mouse position
	var mousePosition = get_viewport().get_mouse_position()
	
	# Get the camera origin and target
	var from = camera.project_ray_origin(mousePosition)
	var to = from + camera.project_ray_normal(mousePosition) * Constants.CLICK_RAY_LENGTH
	
	# Cast a ray
	var result = physicsSpace.intersect_ray(from, to)
	
	# If we intersected something
	if result:
		return result.collider
	else: 
		return null


func deselect():
	# If we are not selecting multiple
	if not isSelectingMultiple:
		# Deselect all selected entities
		for entity in selectedEntities:
			entity._deselect()
		
		# Clear the selectedEntities
		selectedEntities.clear()


func left_clicked_on_entity(clickedEntity):
	deselect()
	
	# If we clicked on somene we had selected, and we are selecting multiple
	if clickedEntity in selectedEntities and isSelectingMultiple:
		# Deselect him
		clickedEntity._deselect()
		
		# Remove the entity from our selection
		selectedEntities.erase(clickedEntity)
	# Otherwise, select the entity
	else:
		# If we are not selectable, stop
		if not clickedEntity.is_selectable():
			return
		
		# Call select on the entity (Highlights him)
		clickedEntity._select()
	
		# Add the entity to my list of selected entities
		selectedEntities.append(clickedEntity)
		
		# If there is only one entity in selected entities, make him our inspected entity
		if selectedEntities.size() == 1:
			set_inspected_entity(clickedEntity)


func inspect_entity(clickedEntity):
	# Get the mouse position
	var mousePosition = get_viewport().get_mouse_position()
	
	# Get the inspect UI
	var inspectUI = get_inspect_ui()
	
	# Attempt to get the inspect items from the entity we clicked on
	if clickedEntity.has_method("_set_inspect_items"):
		# Remove all it's items
		for x in range(inspectUI.get_item_count()):
			inspectUI.remove_item(0)
		
		# Set the inspectUI items from the clicked entity
		clickedEntity._set_inspect_items(inspectUI)
	else:
		return
	
	# Set the inspected entity to this one
	set_inspected_entity(clickedEntity)
	
	# Move the UI to the mouse and pop it up
	inspectUI.rect_position = mousePosition
	inspectUI.popup()


""" UI HANDLING """


func ide_show():
	# Show the IDE
	ide.popup()
	
	# Hide the output popup and track if it is visible
	outputRepopup = get_output_popup().visible
	get_output_popup().hide()
	
	# Update the pause button
	update_pause_button()


func ide_hide():
	# If we want to show our popup, do so
	if outputRepopup:
		get_output_popup().popup()
	
	# Set output visible to false
	outputRepopup = false
	
	# Update the pause button
	update_pause_button()


func ide_update_files():
	ide.update_file_tree()


func output_show():
	# Get the output popup
	var popup = get_output_popup()
	
	# Get the mouse position
	var mousePosition = get_viewport().get_mouse_position()
	
	# Move the popup to the mouse position
	popup.rect_position = mousePosition
	
	# Show the popup
	popup.popup()
	
	# Update the pause button
	update_pause_button()


func output_hide():
	# Update the pause button
	update_pause_button()


func push_view_to_stack(view):
	# Make the current view invisible
	if viewStack.size() > 0:
		viewStack[viewStack.size() - 1].visible = false
	
	# Add the view to the stack
	viewStack.append(view)
	
	# Make the view visible
	view.visible = true


func pop_view_from_stack():
	# Pop and hide the last view
	viewStack.pop_back().visible = false
	
	# Set the last view in the stack to be visible
	if viewStack.size() > 0:
		viewStack[viewStack.size() - 1].visible = true


func update_pause_button():
	# If the ide or output popup is visible, disable the pause button
	if ide.visible or get_output_popup().visible:
		get_pause_game_button().disabled = true
	# Otherwise, enable the button
	else:
		get_pause_game_button().disabled = false


""" GETTERS """

func get_inspect_ui():
	return $OutputPopupLayer/Inspect


func get_inspected_entity():
	return inspectedEntity


func get_inspected_entity_id():
	return inspectedEntity.get_reprogrammable_id()

 
func get_ide():
	if ide == null:
		return $IDE/IDE
	else:
		return ide


func get_ide_layer():
	return $IDE


func get_output_popup():
	return $OutputPopupLayer/OutputPopup


func get_game_ui():
	return $Menus/GameUI


func get_menu_container():
	return $Menus/MenusContainer


func get_pause_menu():
	return $Menus/MenusContainer/PauseMenu


func get_save_menu():
	return $Menus/MenusContainer/SaveMenu


func get_quit_menu():
	return $Menus/MenusContainer/QuitMenu


func get_confirmation_dialog():
	return $Menus/ConfirmOverwritePopup


func get_save_game_line_edit():
	return $Menus/MenusContainer/SaveMenu/LineEditContainer/LineEdit


func get_save_game_list():
	return $Menus/MenusContainer/SaveMenu/SaveGameList


func get_pause_game_button():
	return $Menus/GameUI/PauseGame


func get_button_pressed_sound():
	return $ButtonPressed


""" SETTERS """

func set_inspected_entity(entity):
	# If the entity is the inspected entity already, stop
	if entity == inspectedEntity:
		return
	
	# Get the output text edit
	var ideOutputText = ide.get_output_text_node()
	
	# Get the output popup
	var popup = get_output_popup()
	
	# Get the output text edit
	var popupOutputText = popup.get_output_text_node()
	
	# If we already have an inspected entity
	if inspectedEntity:
		# Get the reprogrammable component
		var reprogrammableComponent = inspectedEntity.get_reprogrammable_component()
		
		# Disconnect him from the print message in the output text
		reprogrammableComponent.disconnect("message_printed", 
				ideOutputText, "_on_TargetEntity_print_message")
		
		# Disconnect the class changed from the ide
		reprogrammableComponent.disconnect("class_changed", 
				ide, "_on_TargetEntity_class_changed")
		
		# Disconnect the output stuff from the output text edit as well
		reprogrammableComponent.disconnect("message_printed", 
				popupOutputText, "_on_TargetEntity_print_message")
		
		# Disconnect the display name change from the popup
		inspectedEntity.disconnect("display_name_changed", 
				popup, "_on_TargetEntity_name_changed")
	
	# Set the entity
	inspectedEntity = entity
	
	# Get the reprogrammable component
	var reprogrammableComponent = inspectedEntity.get_reprogrammable_component()
	
	# Set the IDE target name and type
	ide.set_target_name(inspectedEntity.get_display_name())
	ide.set_target_type(inspectedEntity.get_type())
	ide.set_target_class(inspectedEntity.get_current_class())
	
	# Get the output text
	var outputText = reprogrammableComponent.get_current_output_text()
	
	# Pass the current output to the text edit
	ideOutputText.set_output(outputText)
	
	# Connect the new messages to the text edit
	reprogrammableComponent.connect("message_printed", ideOutputText, "_on_TargetEntity_print_message")
	
	# Connect the class changed to the output label
	reprogrammableComponent.connect("class_changed", ide, "_on_TargetEntity_class_changed")
	
	# Pass the current output to the text edit
	popupOutputText.set_output(outputText)
	
	# Connect the new messages to the popup
	reprogrammableComponent.connect("message_printed", 
		popupOutputText, "_on_TargetEntity_print_message")
	
	# Connect the name change to the popup
	inspectedEntity.connect("display_name_changed", popup, "_on_TargetEntity_name_changed")
	
	# Set the popup's window name
	popup.set_window_title(inspectedEntity.get_display_name())


func set_inspected_entity_name(text: String):
	if inspectedEntity and inspectedEntity.has_method("set_display_name"):
		inspectedEntity.set_display_name(text)


""" SIGNALS """

func _on_game_start():
	# Add the game UI to the view
	push_view_to_stack(get_game_ui())
	
	# We should now be processing input
	shouldProcessInput = true


func _on_game_save():
	var fileName = get_save_game_line_edit().text
	var fileNameActual = fileName + Constants.SAVE_FILE_EXTENSION
	
	# Check to see if we can save the game
	var savedGames = SavingManager.get_saved_games()
	
	# If the file name is in the saved games keys
	if fileNameActual in savedGames.keys():
		# Then the player is trying to overwrite a save, ensure they want to do this
		get_confirmation_dialog().set_file_name(fileName)
		get_confirmation_dialog().popup()
		
		# Stop here
		return
	
	# Save the game
	game_save(fileName)


func _on_game_save_overwrite():
	# Get the file name
	var fileName = get_save_game_line_edit().text
	
	# Save the game
	game_save(fileName)


func _on_Inspect_id_pressed(ID):
	# Edit was clicked
	if ID == Constants.INSPECT_ITEMS.EDIT_CODE:
		ide_show()
		
	# Popup ID was clicked
	elif ID == Constants.INSPECT_ITEMS.VIEW_OUTPUT:
		output_show()


func _on_IDE_closing():
	ide_hide()


func _on_OutputPopup_closing():
	output_hide()


func _on_PauseGame_pressed():
	game_pause()


func _on_Resume_pressed():
	game_resume()


func _on_QuitGame_pressed():
	emit_signal("game_quit")
	
	# clear all the current variables
	inspectedEntity = null
	selectedEntities.clear()
	pressedKeys.clear()
	
	# We should not process user input
	shouldProcessInput = false
	
	# Hide the menus container
	get_menu_container().visible = false
	
	# We should not have anything in our ui
	for ui in viewStack:
		ui.visible = false
	viewStack.clear()
	
	# Unpause the game
	get_tree().paused = false
	
	# Change this to have a UI that prompts them for confirmation
	SceneManager.go_to_main_menu()


func _on_Back_pressed():
	pop_view_from_stack()


func _on_SaveGameMenu_pressed():
	push_view_to_stack(get_save_menu())


func _on_QuitGameMenu_pressed():
	push_view_to_stack(get_quit_menu())


func _on_AnyButton_pressed():
	get_button_pressed_sound().play()


func _on_new_scene(scene):
	# Connect to the scene pause and resume if they are there
	if scene.has_method("_on_game_pause"):
		connect("game_pause", scene, "_on_game_pause")
	if scene.has_method("_on_game_resume"):
		connect("game_resume", scene, "_on_game_resume")
	
	# BUTTON SETUP
	# Loop through all of the buttons
	var buttons = get_tree().get_nodes_in_group("Button")
	
	for button in buttons:
		# Make sure it isn't already connected to the sound
		if "_on_AnyButton_pressed" in button.get_signal_connection_list("pressed"):
			continue
		
		button.connect("pressed", self, "_on_AnyButton_pressed")





