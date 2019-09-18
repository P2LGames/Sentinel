extends "res://Entities/Components/Component.gd"

const ORDER_TYPES = {
	MOVE = 0, # MOVE:
	ROTATE_BY = 1, # ROTATE_BY:
	ROTATE_TO = 2, # ROTATE_TO:
	ROTATE_LEFT = 3,
	ROTATE_RIGHT = 4,
	STOP_ROTATION = 5,
	STOP_MOVEMENT = 6,
	CLEAR = 7
}

var currOrders = {
	move = 0,
	rotate = [-1, 0]
}

var moveSpeed = 8.0
var turnSpeed = 4.5

var currentTurnAmount = 0.0
onready var startPosition = global_transform.origin


func _process(delta):
	if not robot:
		return
	
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
			startPosition = global_transform.origin
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
	var movement = Vector3.ZERO
	
	# Otherwise, execute the current order
	if currOrders.move != 0:
		
		# Get the move direction
		var moveDirection = currOrders.move / abs(currOrders.move)
		
		# Get the movement vector
		movement = -global_transform.basis.x * moveSpeed * moveDirection
		
		# If the distance is greater than the amount we wanted to move, stop
		if startPosition.distance_to(global_transform.origin) > abs(currOrders.move):
			currOrders.move = 0
			
			# We want to tell the cpu that we finished
			send_action_finished_event()
	
	# Move ourselves
#	robot.move_and_slide(movement)
	robot.set_movement(movement)


func handle_rotation(delta: float):
	# If the type of rotation is -1, stop
	if currOrders.rotate[0] == -1:
		return
	
	if currOrders.rotate[0] == ORDER_TYPES.ROTATE_BY:
		# Get how much we want to rotate
		var rotateAmount = currOrders.rotate[1]
		
		# Get the rotation direction
		var rotationDirection = rotateAmount / abs(rotateAmount)
		
		# Rotate in that direction
		var rotationValue = rotateInDirection(delta, rotationDirection, rotateAmount)
		
		# Add our rotation value to our current turn amount
		currentTurnAmount += abs(rotationValue)
		
		# If we have rotated enough, stop ourselves and reset our values
		if currentTurnAmount >= abs(rotateAmount):
			currOrders.rotate[0] = -1
			currentTurnAmount = 0.0
	# If the order it to rotate to...
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_TO:
		pass
	# Rotate left
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_LEFT:
		rotateInDirection(delta, 1)
	# Rotate right
	elif currOrders.rotate[0] == ORDER_TYPES.ROTATE_RIGHT:
		rotateInDirection(delta, -1)


func rotateInDirection(delta: float, direction: int, rotateAmount: float = -1):
	# Get the rotation value
	var rotationValue = delta * turnSpeed * direction
	
	# If we received a rotate amount
	if rotateAmount != -1:
		# Get the amount we still have to rotate
		var turnAmount = abs(rotateAmount - currentTurnAmount * direction) * direction
		
		# If we are turning right and the turn amount is less than rotation value
		if direction == -1 and turnAmount > rotationValue:
			# Set rotation value to turnAmout
			rotationValue = turnAmount
		# Otherwise, if we are turning left and the turn amount is greater than rotation value
		if direction == 1 and turnAmount < rotationValue:
			# Set rotation value to turnAmout
			rotationValue = turnAmount
	
	# Rotate ourselves
	robot.rotate_y(rotationValue)
	
	# Return how much we rotated
	return rotationValue


func send_action_finished_event():
	var bytes: PoolByteArray = []
	
	# Attach the position that the input is coming from
	bytes += Util.int2bytes(Constants.ATTACHMENT_POSITIONS.BASE)
	
	# Attach the type of input
	bytes += Util.int2bytes(Constants.INPUT_TYPES.ACTION_FINISHED)
	
	# Send the bytes off
	robot.send_input(bytes)


""" GETTERS """

func _get_type():
	return Constants.ATTACHMENT_TYPES.WHEELS


""" PERSISTENCE """

func save():
	var saveData = .save()
	
	# Save the data required to make this component function
	saveData["currOrders"] = currOrders
	saveData["currTurnAmount"] = currentTurnAmount
	saveData["startPosX"]  = startPosition.x
	saveData["startPosY"] = startPosition.y
	saveData["startPosZ"] = startPosition.z
	
	return saveData


func load_from_data(data: Dictionary):
	.load_from_data(data)
	
	# Load in the same data that was saved
	currOrders = data["currOrders"]
	currentTurnAmount = data["currTurnAmount"]
	
	# Set the start position for the order
	var x = data["startPosX"]
	var y = data["startPosY"]
	var z = data["startPosZ"]
	startPosition = Vector3(x, y, z)



