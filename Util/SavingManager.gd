extends Node

""" GAME """

func save_game(saveName: String):
	# Make sure the save directory exists
	var dir := Directory.new()
	if not dir.dir_exists(Constants.PLAYER_SAVE_DIR):
		dir.make_dir(Constants.PLAYER_SAVE_DIR)
	
	# Create a save file
	var saveFile = File.new()
	
	# Open the save file
	saveFile.open(Constants.PLAYER_SAVE_DIR + saveName + Constants.SAVE_FILE_TYPE, File.WRITE)
	
	# Save the map
	var map = get_tree().get_nodes_in_group("PersistMap")[0]
	saveFile.store_line(map.save())
	
	# Get all of the persistent nodes
	var saveNodes = get_tree().get_nodes_in_group("Persist")
	
	# Loop through each one and save it as a line
	for i in saveNodes:
		var nodeData = i.save()
		saveFile.store_line(to_json(nodeData))
	
	# Close the file
	saveFile.close()


func load_game(savePath: String):
	var saveFile = File.new()
	if not saveFile.file_exists(savePath):
		return # Error! We don't have a save to load.
	
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var saveNodes = get_tree().get_nodes_in_group("Persist")
	for i in saveNodes:
		i.queue_free()
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	saveFile.open(savePath, File.READ)
	while not saveFile.eof_reached():
		var objectData = parse_json(saveFile.get_line())
		# Firstly, we need to create the object and add it to the tree and set its position.
		var newObject = load(objectData["filename"]).instance()
		get_node(objectData["parent"]).add_child(newObject)
		
		# If the object has the method load_from_data, call it with the remaining data
		if newObject.has_method("load_from_data"):
			newObject.load_from_data(objectData)
	
	# Close the file
	saveFile.close()


""" IDE """

func save_ide_rect(rect: Rect2):
	# Create a new file
	var file = File.new()
	
	# Open the path we want
	file.open(Constants.IDE_RECT_FILE, File.WRITE)
	
	save_rect(file, rect)
	
	# Close the file
	file.close()


func load_ide_rect():
	# Check to see if the file exists
	var file = File.new()
	
	# If the file does not exist, return null
	if not file.file_exists(Constants.IDE_RECT_FILE):
		return null
	
	# Open the file, it exists
	file.open(Constants.IDE_RECT_FILE, File.READ)
	
	# Read the rect from the file
	var rect = read_rect(file)
	
	# Close the file
	file.close()
	
	# Return the rect 2
	return rect


func save_ide_metadata():
	print("Saving ide metadata")


func save_output_rect(rect: Rect2):
	# Create a new file
	var file = File.new()
	
	# Open the path we want
	file.open(Constants.OUTPUT_RECT_FILE, File.WRITE)
	
	# Save the rect
	save_rect(file, rect)
	
	# Close the file
	file.close()


func load_output_rect():
	# Check to see if the file exists
	var file = File.new()
	
	# If the file does not exist, return null
	if not file.file_exists(Constants.OUTPUT_RECT_FILE):
		return null
	
	# Open the file, it exists
	file.open(Constants.OUTPUT_RECT_FILE, File.READ)
	
	# Read the rect from the file
	var rect = read_rect(file)
	
	# Close the file
	file.close()
	
	# Return the rect 2
	return rect


""" HELPERS """

func save_rect(file: File, rect: Rect2):
	# Write the position and size as 32 bit ints
	file.store_32(int(rect.position.x))
	file.store_32(int(rect.position.y))
	file.store_32(int(rect.size.x))
	file.store_32(int(rect.size.y))


func read_rect(file: File):
	# Get 4 32 bit ints
	var posX = file.get_32()
	var posY = file.get_32()
	var sizeX = file.get_32()
	var sizeY = file.get_32()
	
	# Return the rect
	return Rect2(Vector2(posX, posY), Vector2(sizeX, sizeY))


func _ready():
	var dir = Directory.new()
	
	# If the ide directory doesn't exist, make it
	if not dir.dir_exists(Constants.IDE_DIRECTORY):
		dir.make_dir(Constants.IDE_DIRECTORY)