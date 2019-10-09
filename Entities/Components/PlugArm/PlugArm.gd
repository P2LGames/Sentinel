extends "res://Entities/Components/Component.gd"

const ORDER_TYPES = {
	PLUG_IN = 0,
	PLUG_OUT = 1,
	RECOMPILE = 2
}

var targetsInArea = []
var target = null

func _ready():
	pass


func _process(delta):
	parse_orders()


func parse_orders():
	# If we have orders and we aren't executing an order, consume an order
	while len(orders) > 0:
		# Manager the orders
		if orders[0].type == ORDER_TYPES.PLUG_IN:
			plug_in()
		if orders[0].type == ORDER_TYPES.PLUG_OUT:
			plug_out()
		elif orders[0].type == ORDER_TYPES.RECOMPILE:
			# Get the file path from the parameter
			recompile(orders[0].parameter.get_string_from_ascii())
		
		orders.remove(0)


func plug_in():
	"""
	Gets the first entity in our area, call it E.
	Sets the target of the Player to E.
	Gets the code of E.
	Set the IDEs code to that code.
	Popup the IDE.
	"""
	# Make sure that we have something in the target area
	if targetsInArea.size() == 0:
		robot.print_message("\nPlug Arm Error: No targets to plug in to.\n", Constants.MESSAGE_TYPE.ERROR)
		return
	
	# Get the first target
	target = targetsInArea[0]
	
	# Copy the target's code into the player's code directory
	var filePath = target.get_current_class_path()
	var dir := Directory.new()
	if not dir.dir_exists(Constants.PLAYER_CODE_DIR_ACCESSED):
		dir.make_dir(Constants.PLAYER_CODE_DIR_ACCESSED)
	
	var newFilePath = Constants.PLAYER_CODE_DIR_ACCESSED + filePath.get_file()
	if not dir.file_exists(newFilePath):
		print(filePath)
		print(newFilePath)
		dir.copy(filePath, newFilePath)
	
	# Update the file tree of the IDE
	Player.ide_update_files()
	
	# Setup the player IDE and show the IDE
	Player.set_inspected_entity(target)
	Player.get_ide().set_selected_file(newFilePath)
	Player.ide_show()


func plug_out():
	"""
	Sets the target to null, and allows the robot to move again.
	"""
	target = null


func recompile(filePath: String):
	"""
	Recompiles the code of the target entity to the file that was given.
	
	Fails if there is no target entity.
	"""
	if target == null:
		robot.print_message("Plug Arm Error: No targets to recompile.", Constants.MESSAGE_TYPE.ERROR)
	
	var entityId = target.get_reprogrammable_id()
	Player.get_ide().recompile_entity_from_file(target, entityId, filePath)


""" SIGNALS """

func _on_Area_body_entered(body):
	# Make sure the body has the plugable node
	if body.has_node("IsPlugable") and body.isReprogrammable:
		targetsInArea.append(body)


func _on_Area_body_exited(body):
	# Make sure the body has the plugable node
	if body.has_node("IsPlugable") and body.isReprogrammable:
		targetsInArea.erase(body)
		
		# If the body that left was the target, we want to stop showing stuff to the player
		if body == target and Player.get_inspected_entity() == target:
			plug_out()
			Player.set_inspected_entity(null)
