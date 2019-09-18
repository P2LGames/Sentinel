extends Spatial

var robot
var attachmentPosition = -1

var orders = []

""" ATTACHMENT FUNCTIONS """

func _pass_order(orderType: int, orderBytes: PoolByteArray):
	pass


""" GETTERS """

func get_robot():
	return robot


func _get_type() -> int:
	return -1


""" SETTERS """

func set_robot(robot, position: int):
	self.robot = robot
	attachmentPosition = position


""" ATTACHMENT FUNCTIONS """

func pass_order(orderType: int, orderBytes: PoolByteArray):
	var order = Models.Order(orderType, orderBytes)
	orders.append(order)


""" PERSISTENCE """

func save():
	var localPath = str(get_parent().get_path()).replace(str(robot.get_path()), "")
	
	# Save the data required to make this component function
	var saveData = {
		"filename": get_filename(),
		"parent": localPath,
		"orders": orders
	}
	
	return saveData


func load_from_data(data: Dictionary):
	orders = data["orders"]