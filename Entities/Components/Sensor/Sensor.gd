extends "res://Entities/Components/Component.gd"

const ORDER_TYPES = {
	SCAN = 0,
	GET_MAP = 1,
	GET_POSITION = 2,
	TOGGLE_POLLING = 10
}

export var scanSpeed: float = 0.5

var waitForPoll = false
var timeSinceScan = 0.0

var map
var mapSize = Vector2.ZERO
var mapCellSize

var bodiesInArea = []

func _ready():
	# Get the level
	var levelArray = get_tree().get_nodes_in_group("Level")
	
	# If there is one
	if levelArray.size() > 0:
		# Get the map and the map size from the level
		map = levelArray[0].get_map()
		mapSize = levelArray[0].mapSize
		mapCellSize = map.cell_size.x


func _process(delta):
	# Update scan last
	timeSinceScan += delta
	
	parse_orders()
	
	if waitForPoll:
		return
	
	if timeSinceScan > scanSpeed:
		# Reset time since last scan
		timeSinceScan = 0.0
		
		# Scan
		scan()


func parse_orders():
	# If we have orders and we aren't executing an order, consume an order
	while len(orders) > 0:
		# If this is a scan order
		if orders[0].type == ORDER_TYPES.SCAN:
			scan()
		# If this is a get map order
		elif orders[0].type == ORDER_TYPES.GET_MAP:
			get_map()
		# If this is a get map order
		elif orders[0].type == ORDER_TYPES.GET_POSITION:
			get_position()
		# If it toggle polling order
		elif orders[0].type == ORDER_TYPES.TOGGLE_POLLING:
			# Toggle wether or not we are waiting for the poll
			waitForPoll = not waitForPoll
		
		orders.remove(0)


func scan():
	"""
	Sends a list of the positions of bodies that are in the current scan area.
	Format:
		position (int)
		type (int)
		numBodies (int)
		positionX (list(float)) for each body
		positionY (Z) (list(float)) for each body
	"""
	var bytes: PoolByteArray = []
	
	# Attach the position that the input is coming from
	bytes += Util.int2bytes(attachmentPosition)
	
	# Attach the type of input
	bytes += Util.int2bytes(Constants.INPUT_TYPES.SENSOR_SCAN)
	
	# Attach the size of the body list
	bytes += Util.int2bytes(bodiesInArea.size())
	
	# Loop through the bodies, and attach their positions as floats
	for body in bodiesInArea:
		var positionRelativeSelf = body.global_transform.origin - global_transform.origin
		bytes += Util.float2bytes(positionRelativeSelf.x)
		bytes += Util.float2bytes(positionRelativeSelf.z * -1)
	
	# Send the bytes off
	robot.send_input(bytes)


func get_map():
	"""
	Sends a double array of the map data, 0 is walkable, 1 is blocked
	Format:
		position (int)
		type (int)
		sizeX (int)
		sizeY (Z) (int)
		walkable (list(byte)) 0 or 1
	"""
	var bytes: PoolByteArray = []
	
	# Attach the position that the input is coming from
	bytes += Util.int2bytes(attachmentPosition)
	
	# Attach the type of input
	bytes += Util.int2bytes(Constants.INPUT_TYPES.SENSOR_GET_MAP)
	
	# Attach the max size
	bytes += Util.int2bytes(int(mapSize.x))
	bytes += Util.int2bytes(int(mapSize.y))
	
	var xSize = int(mapSize.x) / 2
	var ySize = int(mapSize.y) / 2
	
	# Loop through x and y
	for x in range(-xSize, xSize):
		for y in range(ySize, -ySize, -1):
			# If the cell is -1, then we can walk through it
			if map.get_cell_item(x, 1, y) == -1:
				bytes.append(0)
			# Otherwise, we can't, it's a 1
			else:
				bytes.append(1)
			
	# Send the bytes off
	robot.send_input(bytes)


func get_position():
	"""
	Sends a list of the positions of bodies that are in the current scan area.
	Format:
		position (int)
		type (int)
		positionX (float)
		positionY (Z) (float)
	"""
	var bytes: PoolByteArray = []
	
	# Attach the position that the input is coming from
	bytes += Util.int2bytes(attachmentPosition)
	
	# Attach the type of input
	bytes += Util.int2bytes(Constants.INPUT_TYPES.SENSOR_POSITION)
	
	# Attach the size of the body list
	var posX = global_transform.origin.x + mapSize.x / 2 * mapCellSize
	var posY = -1 * global_transform.origin.z + mapSize.y / 2 * mapCellSize
	print(posX, " ", posY)
	var xBytes = Util.float2bytes(posX)
	var yBytes = Util.float2bytes(posY)
	bytes += xBytes
	bytes += yBytes
	
	for x in xBytes:
		print(x)
	
	print()
	for x in yBytes:
		print(x)
	
	# Send the bytes off
	robot.send_input(bytes)


""" GETTERS """

func _get_type() -> int:
	return Constants.ATTACHMENT_TYPES.SENSOR


""" PERSISTENCE """

func save():
	var saveData = .save()
	
	return saveData


func load_from_data(data: Dictionary):
	pass


func _on_Area_body_entered(body):
	if body != robot:
		bodiesInArea.append(body)


func _on_Area_body_exited(body):
	if body != robot:
		bodiesInArea.erase(body)
