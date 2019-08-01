extends Sprite
	
const ORDER_TYPES = {
	MOVE = 0, # MOVE:
	ROTATE_BY = 1, # ROTATE_BY:
	ROTATE_TO = 2, # ROTATE_TO:
	ROTATE_LEFT = 3,
	ROTATE_RIGHT = 4,
	STOP_ROTATION = 5,
	STOP_MOVEMENT = 6,
}

var robot

var orders = []

var currOrders = {
	move = 0,
	rotate = [-1, 0]
}

var moveSpeed = 160.0
var turnSpeed = 4.5

var currentTurnAmount = 0.0
onready var startPosition = position

func _ready():
	set_process(true)


func _process(delta):
	
	parse_orders()
	
	handle_movement()
	
	handle_rotation(delta)


func parse_orders():
	# If we have orders and we aren't executing an order, consume an order
	while len(orders) > 0:
		# If this is a stop move order
		if orders[0].type == ORDER_TYPES.STOP_MOVEMENT:
			# Then stop the movement
			currOrders.move = 0
		# If this is a stop rotation order
		elif orders[0].type == ORDER_TYPES.STOP_ROTATION:
			# Then stop the rotation
			currOrders.rotate = [-1, 0]
		# If it is a move order, 
		elif orders[0].type == ORDER_TYPES.MOVE:
			# Get the move amount from the second part of the order
			var moveAmount = Util.bytes2float(orders[0].parameter)
			
			# Set the move in the current orders to this
			currOrders.move = moveAmount
			
			# Setup start position
			startPosition = global_position
		# Handle rotate by orders
		elif orders[0].type == ORDER_TYPES.ROTATE_BY:
			# Get the order rotate amount
			var rotateAmount = Util.bytes2float(orders[0].parameter)
			
			# Setup the rotate order
			currOrders.rotate = [orders[0].type, rotateAmount]
		# Handle rotate to orders
		elif orders[0].type == ORDER_TYPES.ROTATE_TO:
			# Setup the order parameter
			var rotateParam
			# If there are more than 4 bytes, then its a string
			if orders[0].parameter.size() > 4:
				rotateParam = orders[0].parameter.get_string_from_ascii()
				print(rotateParam)
			# Otherwise, it's a float defining the angle wa 
			else:
				rotateParam = Util.bytes2float(orders[0].parameter)
			
			# Set the order
			currOrders.rotate = [orders[0].type, rotateParam]
		# Handle left and right
		elif orders[0].type == ORDER_TYPES.ROTATE_LEFT or orders[0].type == ORDER_TYPES.ROTATE_RIGHT:
			# Set the order
			currOrders.rotate = [orders[0].type, 0]
		
		orders.remove(0)


func handle_movement():
	var movement = Vector2.ZERO
	
	# Otherwise, execute the current order
	if currOrders.move != 0:
		
		# Get the move direction
		var moveDirection = currOrders.move / abs(currOrders.move)
		
		# Get the movement vector
		movement = Vector2(moveSpeed * moveDirection, 0).rotated(global_rotation - PI / 2)
		
		# If the distance is greater than the amount we wanted to move, stop
		if startPosition.distance_to(global_position) > abs(currOrders.move):
			currOrders.move = 0
	
	
	# Move ourselves
#	robot.move_and_slide(movement)
	robot.set_movement(movement)

func handle_rotation(delta: float):
	
	if currOrders.rotate[0] == ORDER_TYPES.ROTATE_BY:
		# Get how much we want to rotate
		var rotateAmount = currOrders.rotate[1]
		
		# Get the rotation direction
		var rotationDirection = rotateAmount / abs(rotateAmount)
		
		# Rotate in that direction
		var rotationValue = rotateInDirection(delta, rotationDirection)
		
		# Add our rotation value to our current turn amount
		currentTurnAmount += abs(rotationValue)
		
		# If we have rotated enough, stop ourselves and reset our values
		if currentTurnAmount >= abs(rotateAmount):
			currOrders.rotate[0] = ""
			currentTurnAmount = 0.0
	# If the order it to rotate to...
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_TO:
		pass
	# Rotate left
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_LEFT:
		rotateInDirection(delta, -1)
	# Rotate right
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_RIGHT:
		rotateInDirection(delta, 1)


func rotateInDirection(delta: float, direction: int):
	# Get the rotation value
	var rotationValue = delta * turnSpeed * direction
	
	# Rotate ourselves
	robot.rotate(rotationValue)
	
	# Return how much we rotated
	return rotationValue


##### GETTERS #####

func get_robot():
	return robot


func get_type():
	return Constants.ATTACHMENT_TYPES.WHEELS


##### SETTERS #####

func set_robot(robot):
	self.robot = robot


##### ATTACHMENT FUNCTIONS #####

func pass_order(orderType: int, orderBytes: PoolByteArray):
#	print("Order Type: ", orderType)
	var order = Models.Order(orderType, orderBytes)
	orders.append(order)