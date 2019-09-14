extends Camera

var viewportSize: Vector2
var sensitivity = 0.3
var edgeBuffer = 10

var bounds: Rect2
var canMoveH = true
var canMoveV = true

func _ready():
	var map = get_tree().get_nodes_in_group("Map")[0]
	
	var mapPosition2D = Vector2(map.global_transform.origin.x, map.global_transform.origin.z)
	var mapSize = Vector2(map.cell_size.x * 40, map.cell_size.z * 40)
	mapPosition2D -= mapSize / 2
	
	# Set the boounds
	bounds = Rect2(mapPosition2D, mapSize)
	
	# Make sure we are looping
	set_process(true)
	
	# Get the viewport size
	viewportSize = get_viewport().size

func _process(delta):
	# If we can't move, stop
	if not canMoveH and not canMoveV:
		return
	
	# Get the mouse position
	var mousePos = get_viewport().get_mouse_position()
	
	# Setup to translate based on where the mouse is
	var toTranslate = Vector3.ZERO
	
	# If the mouse is near any edge, then add to translate
	if canMoveH:
		if mousePos.x >= viewportSize.x - edgeBuffer:
			toTranslate.x = sensitivity
		elif mousePos.x <= edgeBuffer:
			toTranslate.x = -sensitivity
	
	if canMoveV:
		if mousePos.y >= viewportSize.y - edgeBuffer:
			toTranslate.z = sensitivity
		elif mousePos.y <= edgeBuffer:
			toTranslate.z = -sensitivity
	
	# Get our position
	var position = global_transform.origin
	
	# Move our position
	position += toTranslate
	
	# Bound the position
	if position.x > bounds.size.x + bounds.position.x:
		position.x = bounds.size.x + bounds.position.x
	elif position.x < bounds.position.x:
		position.x = bounds.position.x
	
	if position.z > bounds.size.y + bounds.position.y:
		position.z = bounds.size.y + bounds.position.y
	elif position.z < bounds.position.y:
		position.z = bounds.position.y
	
	# Set our position
	global_transform.origin = position


""" SETTERS """

func set_bounds_with_area(area: Area):
	# Get the position and size of the area
	var position = Vector2(area.global_transform.origin.x, area.global_transform.origin.z)
	var areaSize = Vector2(area.scale.x, area.scale.z)
	
	# Set the bounds with the found position and area
	set_bounds(position, areaSize)


func set_bounds(position: Vector2, areaSize: Vector2):
	# If the size is less than 0.1, then just lock the camera
	if areaSize <= Vector2(0.11, 0.11):
		# Bind to position
		canMoveH = false
		canMoveV = false
		
		# Set the position to the position of the area, excluding y
		global_transform.origin = Vector3(position.x, global_transform.origin.y, position.y)
	# Check to see if we should bind the x
	elif areaSize.x <= 0.11:
		# Bind to x position
		canMoveH = false
		canMoveV = true
		
		# Set the position to the position of the area, excluding y
		global_transform.origin = Vector3(position.x, global_transform.origin.y, global_transform.origin.y)
		
		# Offset the position to be the bottom left, with size being top right
		position -= areaSize / 2
		
		# Set the bounds
		bounds = Rect2(position, areaSize)
	# Check to see if we should bind the y
	elif areaSize.y <= 0.11:
		# Bind to y position
		canMoveH = true
		canMoveV = false
		
		# Set the position to the position of the area, excluding y
		global_transform.origin = Vector3(global_transform.origin.x, global_transform.origin.y, position.y)
		
		# Offset the position to be the bottom left, with size being top right
		position -= areaSize / 2
		
		# Set the bounds
		bounds = Rect2(position, areaSize)
	# Otherwise, bind the camera to the area given
	else:
		# We can in fact move the camera
		canMoveH = true
		canMoveV = true
		
		# Offset the position to be the bottom left, with size being top right
		position -= areaSize / 2
		
		# Set the bounds
		bounds = Rect2(position, areaSize)
