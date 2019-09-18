extends Spatial

var mapSize = Vector2(50, 50)

func _ready():
	# Set the player's camera
	Player.camera = get_camera()
	
	# Set the communication manager to run
	CommunicationManager.running = true


func load_from_data(data: Array):
	# Clear the current persistent entities
	var saveNodes = get_tree().get_nodes_in_group("Persist")
	for i in saveNodes:
		i.queue_free()
	
	# Loop through the data
	for objectData in data:
		# Firstly, we need to create the object and add it to the tree and set its position.
		var newObject = load(objectData["filename"]).instance()
		get_node(objectData["parent"]).add_child(newObject)
		
		# If the object has the method load_from_data, call it with the remaining data
		if newObject.has_method("load_from_data"):
			newObject.load_from_data(objectData)


""" GETTERS """

func get_camera():
	return $Camera


func get_map():
	return $Map


func is_map():
	return true


""" PERSITENCE """

func save():
	# Return the path of the level
	return get_filename()
