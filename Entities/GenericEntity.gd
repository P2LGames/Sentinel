extends KinematicBody

var isReprogrammable = false

func _ready():
	# Setup the reprogrammable
	if get_node("Reprogrammable"):
		isReprogrammable = true


func _handle_command(commandId: int, value: PoolByteArray):
	pass


func print_message(message: String, type: int):
	# If we are reprogrammable
	if isReprogrammable:
		# Pass the print message to the reprogrammable node
		get_node("Reprogrammable").print_message(message, type)


##### ENTITY ID AND COMMUNICATION #####

func get_reprogrammable_component():
	if isReprogrammable:
		return get_node("Reprogrammable")


func get_reprogrammable_id():
	# If the reprogrammable exists, get its entityId
	if isReprogrammable:
		return int(get_reprogrammable_component().entityId)
	
	# Otherwise, return null
	return null


func is_reprogrammable_ready():
	# If the reprogrammable exists, get its entityId
	if isReprogrammable:
		return get_reprogrammable_component().ready
	
	# Otherwise, return null
	return null


func get_current_class():
	# If the reprogrammable exists, get its current class
	if isReprogrammable != null:
		return get_reprogrammable_component().currentClass
	
	# Otherwise, return null
	return null


func set_current_class(_class: String):
	# If the reprogrammable exists, get its current class
	if isReprogrammable != null:
		return get_reprogrammable_component().set_current_class(_class)
	
	# Otherwise, return null
	return null


func get_default_class():
	# If the reprogrammable exists, get its default class
	if isReprogrammable != null:
		return get_reprogrammable_component().defaultClass
	
	# Otherwise, return null
	return null


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
	if isReprogrammable:
		# Get the entity type from that
		return get_reprogrammable_component().entityType
	
	# Otherwise, return an empty string
	return ""


func _set_display_name(displayName: String):
	pass


func _set_inspect_items(inspectUI: PopupMenu):
	"""Fills the popup menu with all of the things you can view in this entity."""
	
	# If we have a reprogrammable, add the edit code item
	if isReprogrammable:
		inspectUI.add_item("Edit Code", Constants.INSPECT_ITEMS.EDIT_CODE)
		inspectUI.add_item("View Output", Constants.INSPECT_ITEMS.VIEW_OUTPUT)