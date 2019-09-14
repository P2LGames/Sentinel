extends Tree

var IDEFile = load("res://Player/Windows/IDE/IDEFile.gd")

var itemToFile: Dictionary = {}
var rootPath := ""

signal file_selected(file, filePath)

# If a file has been changed, append an asterisk to its name
func file_dirtied(filePath: String):
	# Get the item from the filePath
	var treeItem = get_tree_item_from_path(filePath)
	
	# Get the old text
	var oldText = treeItem.get_text(0)
	
	# Add the asterisk if it isn't already there
	if !oldText.ends_with('*'):
		treeItem.set_text(0, oldText + '*')


# If a file has been saved, remove the asterisk from its name
func file_saved(filePath: String):
	# Get the item from the filePath
	var treeItem = get_tree_item_from_path(filePath)
	
	# Get the old text
	var oldText = treeItem.get_text(0)
	
	# Strip off the asterisk
	if oldText.ends_with('*'):
		treeItem.set_text(0, oldText.substr(0, oldText.length() - 1))


func select_tree_item_with_path(itemPath: String):
	# Get the item from the path
	var item = get_tree_item_from_path(itemPath)
	
	# Select it
	item.select(0)


func add_directory(root: TreeItem, dirPath: String, createNew: bool = true):
	# Create the folder item
	var folder = root
	if createNew:
		folder = create_item(root)
	
	# Set the folder to the file name
	var folderName = FileManager.get_file_name(dirPath)
	folder.set_text(0, folderName)
	
	# Create a new directory to list out files in the folders
	var dir = Directory.new()
	dir.open(dirPath)
	
	# Begin listing the files in the directory
	dir.list_dir_begin(true, true)
	
	# While true...
	while true:
		# Get the next file
		var file = dir.get_next()
		
		# If it was empty, stop
		if file == "":
			break
		
		# Get the file path
		var filePath = FileManager.join(dirPath, file)
		
		# If the file is a directory
		if dir.dir_exists(filePath):
			# Then recurse through it as well
			add_directory(folder, filePath)
		# Otherwise, it's a file, add it as a file and get the file name
		else:
			# Get the file name
			var fileSplit = file.split(".")
			var fileName = fileSplit[0]
			print(fileSplit)
			
			# Create a tree item with it, with folder as the parent
			var treeItem = create_item(folder)
			treeItem.set_text(0, fileName)
			
			# Create a new ide file
			var newIDEFile = IDEFile.new(filePath, fileName, fileSplit[1])
	
			# Save it to our dictionary
			itemToFile[treeItem] = newIDEFile
	
	# End the listing
	dir.list_dir_end()


""" GETTERS """

func get_path_from_item(item: TreeItem):
	"""
	Gets the path to a file given a specific item.
	The root of the tree is represented by '/'.
	But the path returned includes the 'rootPath' at the beginning.
	
	Parameters:
		item (TreeItem): The item to get the path from
	
	return:
		itemPath (String): The path to the given item (file)
	"""
	var filePath = ""
	var loopItem = item
	
	# While the loop item has a parent
	while loopItem.get_parent():
		# Update the filePath
		filePath = "/" + loopItem.get_text(0) + filePath
		
		# Set the loop item to the parent
		loopItem = loopItem.get_parent()
	
	# Return the file path
	return FileManager.join(rootPath, filePath)


func get_tree_item_from_path(itemPath: String):
	"""
	Gets the item (file) using the given item (file) path.
	The beginning of the path should match 'rootPath'.
	It will be replaced with and empty string to get a root of '/'.
	
	Returns the root if the path is invalid.
	
	Parameters:
		itemPath (String): The path to the item (file)
	
	return:
		item (TreeItem): The item found from the given path
	"""
	# Replace the root with nothing
	itemPath = itemPath.replace(rootPath, "")
	
	# If the item path is a slash, or empty, return root
	if itemPath == "/" or itemPath == "":
		return get_root()
	
	# Split the path
	var splitPath = itemPath.split("/")
	print(splitPath)
	
	# Get the root's first child
	var child = get_root().get_children()
	
	# Track the last valid child
	var lastValidChild = child
	
	# Loop through each part in the path
	for x in range(splitPath.size()):
		# Get the part
		var part = splitPath[x]
		
		# If the part is empty, skip it
		if part == "":
			continue
		
		# While the child's text does not equal the part
		while child.get_text(0) != part:
			child = child.get_next()
			
			# If the child is null, return the root
			if child == null:
				return get_root()
		
		# If the child has a child, and we aren't at the end of the path
		if child.get_children() and x != splitPath.size() - 1:
			child = child.get_children()
		else:
			return child
	
	# Return the child
	return child


func get_file_from_path(filePath: String):
	# Get the item
	var item = get_tree_item_from_path(filePath)
	
	# Use the item to get the file, it it's there
	if item in itemToFile.keys():
		return itemToFile[item]
	else:
		return null


""" SETTERS """

func set_root_to_path(dirPath: String):
	# Clear the current elements
	clear()
	
	# Set the root path
	rootPath = dirPath
	
	# Create a root item
	create_item()
	
	# Add the first directory
	add_directory(get_root(), dirPath, false)


""" SIGNALS """


func _on_IDE_file_dirtied(filePath):
	file_dirtied(filePath)


func _on_FileTree_item_selected():
	# Get the selected item
	var selectedItem = get_selected()
	
	# Get the item path
	var filePath = get_path_from_item(selectedItem)
	
	# If the item to file dictionary has the selected item
	if selectedItem in itemToFile.keys():
		# Emit the file selected signal with the given item
		emit_signal("file_selected", itemToFile[selectedItem], filePath)
