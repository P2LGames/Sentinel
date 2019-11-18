extends "res://Entities/GenericEntity.gd"

export var notReprogrammable = false
export var displayName = ""

var isReprogrammable = false

signal display_name_changed(newName)

func _ready():
	# Setup the reprogrammable
	if get_node("Reprogrammable"):
		isReprogrammable = true


func death():
	if isDead:
		return
	
	.death()
	
	# If we are dead now, we want to remove
	# ourselves from the reprogrammable entity list
	if isDead and isReprogrammable:
		var entityId = get_reprogrammable_id()
		CommunicationManager.disconnect_entity(entityId)


func _handle_command(commandId: int, value: PoolByteArray):
	pass


func print_message(message: String, type: int):
	# If we are reprogrammable, pass the print message to the reprogrammable node
	if isReprogrammable:
		get_node("Reprogrammable").print_message(message, type)


""" ENTITY ID AND COMMUNICATION """

func get_reprogrammable_component():
	if isReprogrammable:
		return get_node("Reprogrammable")
	
	return null


func get_reprogrammable_id():
	# If the reprogrammable exists, get its entityId
	if isReprogrammable:
		return get_reprogrammable_component().entityId
	
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


func get_default_class():
	# If the reprogrammable exists, get its default class
	if isReprogrammable != null:
		return get_reprogrammable_component().defaultClass
	
	# Otherwise, return null
	return null


func get_current_file_path():
	# If the reprogrammable exists, get its current class
	if isReprogrammable != null:
		return get_reprogrammable_component().currentFilePath
	
	# Otherwise, return null
	return null


func set_current_class(_class: String):
	# If the reprogrammable exists, get its current class
	if isReprogrammable != null:
		return get_reprogrammable_component().set_current_class(_class)
	
	# Otherwise, return null
	return null


func set_current_file_path(filePath: String):
	# If the reprogrammable exists, get its current class
	if isReprogrammable != null:
		return get_reprogrammable_component().set_current_file_path(filePath)
	
	# Otherwise, return null
	return null


""" ENTITY PERSISTENCE """

func save():
	var basisQuat = transform.basis.get_rotation_quat()
	var saveData = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"name": name,
		"displayName": get_display_name(),
		"posX": global_transform.origin.x,
		"posY": global_transform.origin.y,
		"posZ": global_transform.origin.z,
		"basisX": basisQuat.x,
		"basisY": basisQuat.y,
		"basisZ": basisQuat.z,
		"basisW": basisQuat.w
	}
	
	return saveData


func load_from_data(data: Dictionary):
	name = data["name"]
	displayName = data["displayName"]
	
	global_transform.origin = Vector3(data["posX"], data["posY"], data["posZ"])
	transform.basis = Basis(Quat(data["basisX"], data["basisY"], data["basisZ"], data["basisW"]))


""" INSPECTION """

func get_display_name() -> String:
	return displayName


func get_type() -> String:
	# If we are reprogrammable
	if isReprogrammable:
		# Get the entity type from that
		return get_reprogrammable_component().entityType
	
	# Otherwise, return an empty string
	return ""


func set_display_name(displayName: String):
	# Update the display name
	self.displayName = displayName
	
	# Emit a signal saying the name was changed
	emit_signal("display_name_changed", displayName)


func _set_inspect_items(inspectUI: PopupMenu):
	"""Fills the popup menu with all of the things you can view in this entity."""
	
	# If we have a reprogrammable, add the edit code item
	if isReprogrammable:
		inspectUI.add_item("Edit Code", Constants.INSPECT_ITEMS.EDIT_CODE)
		inspectUI.add_item("View Output", Constants.INSPECT_ITEMS.VIEW_OUTPUT)