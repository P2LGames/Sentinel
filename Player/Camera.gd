extends Camera

var viewportSize: Vector2
var sensitivity = 0.3
var edgeBuffer = 10

var bounds: Rect2

func _ready():
	var map = get_tree().get_nodes_in_group("Map")[0]
	
	var mapPosition2D = Vector2(map.global_transform.origin.x, map.global_transform.origin.z)
	var mapSize = Vector2(map.cell_size.x * 20, map.cell_size.z * 12)
	
	bounds = Rect2(mapPosition2D, mapSize)
	
	
	# Make sure we are looping
	set_process(true)
	
	viewportSize = get_viewport().size

func _process(delta):
	
	var mousePos = get_viewport().get_mouse_position()
	var toTranslate = Vector3.ZERO
	
	if mousePos.x >= viewportSize.x - edgeBuffer:
		toTranslate.x = sensitivity
	elif mousePos.x <= edgeBuffer:
		toTranslate.x = -sensitivity
	
	if mousePos.y >= viewportSize.y - edgeBuffer:
		toTranslate.z = sensitivity
	elif mousePos.y <= edgeBuffer:
		toTranslate.z = -sensitivity
	
	var position = global_transform.origin
	# Move our position
	position += toTranslate
	# Bound the position
	if position.x > bounds.size.x:
		position.x = bounds.size.x
	if position.z > bounds.size.y:
		position.z = bounds.size.y
	
	if position.x < bounds.position.x:
		position.x = bounds.position.x
	if position.z < bounds.position.y:
		position.z = bounds.position.y
	
	global_transform.origin = position
	
#	if toTranslate != Vector3.ZERO:
#		translate(toTranslate)
	
	
	
