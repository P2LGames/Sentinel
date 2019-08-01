extends KinematicBody2D

func _handle_command(commandId: int, value: PoolByteArray):
	pass


func print_message(message: String, type: int):
	# If we are reprogrammable
	if get_node("Reprogrammable"):
		# Pass the print message to the reprogrammable node
		get_node("Reprogrammable").print_message(message, type)


##### ENTITY ID AND COMMUNICATION #####

func _get_entity_id():
	return ""


##### ENTITY INTERACTION #####

func _select():
	pass


func _deselect():
	pass


##### INSPECTION #####

func _get_display_name() -> String:
	return ""


func get_type() -> String:
	# If we are reprogrammable
	if get_node("Reprogrammable"):
		# Get the entity type from that
		return get_node("Reprogrammable").entityType
	
	# Otherwise, return an empty string
	return ""


func _set_display_name(displayName: String):
	pass


func _set_inspect_items(inspectUI: PopupMenu):
	"""Fills the popup menu with all of the things you can view in this entity."""
	
	# If we have a reprogrammable, add the edit code item
	if get_node("Reprogrammable"):
		inspectUI.add_item("Edit Code", Constants.INSPECT_ITEMS.EDIT_CODE)