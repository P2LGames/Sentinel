extends KinematicBody2D

func _handle_command(commandId: int, value: PoolByteArray):
	pass


##### ENTITY ID #####

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


func _get_type() -> String:
	return ""


func _set_display_name(displayName: String):
	pass


func _set_inspect_items(inspectUI: PopupMenu):
	"""Fills the popup menu with all of the things you can view in this entity."""
	pass