extends GridMap

func _ready():
	# Set the player's camera
	Player.camera = get_camera()


""" GETTERS """

func get_camera():
	return $Camera


func is_map():
	return true


""" PERSITENCE """

func save():
	# Return the path of the level
	return get_filename()
