extends MeshInstance
	
const ORDER_TYPES = {
	SCAN = 0
}

var robot

var orders = []


func _process(delta):
	pass


""" GETTERS """

func get_robot():
	return robot


func get_type():
	return Constants.ATTACHMENT_TYPES.SENSOR


""" SETTERS """

func set_robot(robot):
	self.robot = robot


""" ATTACHMENT FUNCTIONS """

func pass_order(orderType: int, orderBytes: PoolByteArray):
	pass


""" PERSISTENCE """

func save():
	var localPath = str(get_parent().get_path()).replace(str(robot.get_path()), "")
	
	# Save the data required to make this component function
	var saveData = {
		"filename": get_filename(),
		"parent": localPath
	}
	
	return saveData


func load_from_data(data: Dictionary):
	pass