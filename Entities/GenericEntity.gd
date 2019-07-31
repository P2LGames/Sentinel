extends KinematicBody2D

func _handle_command(commandId: int, value: PoolByteArray):
	pass

##### ENTITY ID #####

func get_entity_id():
	return ""

##### ENTITY INTERACTION #####

func select():
	pass

func deselect():
	pass

##### INSPECTION #####

func set_inspect_items(inspectUI: PopupMenu):
	"""
	Fills the popup menu with all of the things you can view in this entity.
	"""
	pass