extends Node2D

export (PackedScene) var OutputPopup

var camera

var pressedKeys = []
var selectedEntities = []
var inspectedEntity

var isSelectingMultiple = false

var outputRepopup = false

func _ready():
	pass


func _process(delta):
	handle_input()


func _physics_process(delta):
	handle_mouse_inputs()


""" INPUT """

func _unhandled_key_input(event):
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
	print(str(code) + " " + str(pressed))
	# Loop through all of hte selected entities
	for entity in selectedEntities:
		# If we can send them the key input, then send it
		if entity.has_method("send_key_input"):
			entity.send_key_input(code, pressed)


func handle_input():

	# Show editor if escape is pressed
	if Input.is_action_just_pressed("ui_focus_next"):
		
		if not get_ide().visible:
			get_ide().toggle_visibility()
	
	# If we want to select multiple people we can
	isSelectingMultiple = Input.is_action_pressed("select_multiple")


func handle_mouse_inputs():
	# Handle user mouse events
	if not get_ide().visible and Input.is_action_just_pressed("left_click"):
		# Get the clicked entity
		var clickedEntity = get_clicked_entity()
		
		# See if we can select that entity
		if clickedEntity != null and clickedEntity.has_method("_select"):
			# Then we left clicked on an entity, select it
			left_clicked_on_entity(clickedEntity)
		elif clickedEntity == null:
			deselect()
	# Right Click
	elif Input.is_action_just_pressed("right_click"):
		pass
	# Q Pressed and IDE is invisible
	elif not get_ide().visible and Input.is_action_just_pressed("inspect_entity"):
		# Get the clicked entity
		var clickedEntity = get_clicked_entity()
		
		# See if we can select that entity
		if clickedEntity:
			# Then we left clicked on an entity, select it
			inspect_entity(clickedEntity)


func get_clicked_entity():
	# Get the mouse position
	var mousePosition = camera.get_global_mouse_position()
	
	# Check if anything is intersecting my mouse position
	var result = get_world_2d().get_direct_space_state().intersect_point(mousePosition, 1, [],
		Constants.NAME_TO_BIT_MASK[Constants.LAYER.UNITS])
	print(result)
	# If we intersected something
	if result:
		return result[0].collider
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
		# Call select on the entity (Highlights him)
		clickedEntity._select()
	
		# Add the entity to my list of selected entities
		selectedEntities.append(clickedEntity)


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
		
		# Setup the ide for the clicked entity
		setup_ide_for_entity(clickedEntity)
	else:
		return
	
	# Move the UI to the mouse and pop it up
	inspectUI.rect_position = mousePosition
	inspectUI.popup()


func setup_ide_for_entity(targetEntity):
	# Get the ide
	var ide = get_ide()
	
	# Get the output text edit
	var outputTextEdit = ide.get_output_text_node()
	
	# If we already have an inspected entity
	if inspectedEntity:
		# Disconnect him from the print message in the output text
		inspectedEntity.get_node("Reprogrammable").disconnect("message_printed", 
				outputTextEdit, "_on_TargetEntity_print_message")
		
		# Disconnect the class changed from the ide
		inspectedEntity.get_node("Reprogrammable").disconnect("class_changed", 
				ide, "_on_TargetEntity_class_changed")
	
	# Set our inspectedEntity
	inspectedEntity = targetEntity
	
	# Set the IDE target name and type
	ide.set_target_name(inspectedEntity._get_display_name())
	ide.set_target_type(inspectedEntity.get_type())
	ide.set_target_class(inspectedEntity.get_current_class())
	
	# Get the output text
	var outputText = inspectedEntity.get_node("Reprogrammable").get_current_output_text()
	
	# Pass the current output to the text edit
	outputTextEdit.set_output(outputText)
	
	# Connect the new messages to the text edit
	inspectedEntity.get_node("Reprogrammable").connect("message_printed", outputTextEdit, "_on_TargetEntity_print_message")
	
	# Connect the class changed to the output label
	inspectedEntity.get_node("Reprogrammable").connect("class_changed", ide, "_on_TargetEntity_class_changed")


func create_output_for_inspected_entity():
#	# Create a new popup
#	var popup = OutputPopup.instance()
#
#	# Add the popup to the canvas
#	get_output_popup_layer().add_child(popup)
	
	# Get the output popup
	var popup = get_output_popup()
	
	# Get the output text edit
	var outputTextNode = popup.get_output_text_node()
	
	# Get the output text
	var outputText = inspectedEntity.get_reprogrammable_component().get_current_output_text()
	
	# Pass the current output to the text edit
	outputTextNode.set_output(outputText)
	
	# Connect the new messages to the popup
	inspectedEntity.get_node("Reprogrammable").connect("message_printed", 
		popup.get_output_text_node(), "_on_TargetEntity_print_message")
	
	# Connect the name change to the popup
	inspectedEntity.connect("display_name_changed", popup, "_on_TargetEntity_name_changed")
	
	# Set the popup's window name
	popup.set_window_title(inspectedEntity._get_display_name())
	
	# Get the mouse position
	var mousePosition = get_viewport().get_mouse_position()
	
	# Move the popup to the mouse position
	popup.rect_position = mousePosition
	
	# Show the popup
	popup.popup()


""" GETTERS """

func get_inspect_ui():
	return $CanvasLayer/Inspect


func get_inspected_entity():
	return inspectedEntity


func get_inspected_entity_id():
	return int(inspectedEntity.get_node("Reprogrammable").entityId)


func get_ide():
	return $CanvasLayer/IDE


func get_ide_layer():
	return $CanvasLayer


func get_output_popup():
	return $OutputPopupLayer/OutputPopup


""" SETTERS """

func set_inspected_entity(entity):
	inspectedEntity = entity


func set_inspected_entity_name(text: String):
	if inspectedEntity and inspectedEntity.has_method("_set_display_name"):
		inspectedEntity._set_display_name(text)


""" SIGNALS """

func _on_Inspect_id_pressed(ID):
	# Edit was clicked
	if ID == Constants.INSPECT_ITEMS.EDIT_CODE:
		# Show the IDE
		get_ide().toggle_visibility()
		
		# Hide the output popup and track if it is visible
		outputRepopup = get_output_popup().visible
		get_output_popup().hide()
		
	# Popup ID was clicked
	elif ID == Constants.INSPECT_ITEMS.VIEW_OUTPUT:
		create_output_for_inspected_entity()


func _on_IDE_closing():
#	get_output_popup_container().visible = true
	if outputRepopup:
		get_output_popup().popup()
	
	# Set output visible to false
	outputRepopup = false
