extends Tree


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


""" GETTERS """

func get_path_from_item(item: TreeItem):
	var filePath = ""
	var loopItem = item
	
	# While the loop item has a parent
	while loopItem.get_parent():
		# Update the filePath
		filePath = "/" + loopItem.get_text(0) + filePath
		
		# Set the loop item to the parent
		loopItem = loopItem.get_parent()
	
	# Return the file path
	return filePath


func get_tree_item_from_path(itemPath):
	print("Looking for: ", itemPath)
	# Split the path
	var splitPath = itemPath.split("/")
	
	# Get the root's first child
	var child = get_root().get_children()
	
	# Track the last valid child
	var lastValidChild = child
	
	# Loop through each part in the path
	for x in splitPath.size() - 1:
		# Get the part
		var part = splitPath[x]
		print("Part: ", part)
		
		# If the part is empty, skip it
		if part == "":
			continue
		
		# While the child's text does not equal the part
		while child.get_text(0) != part:
			child = child.get_next()
		
		# If the child as a child, and we aren't at the end of the path
		if child.get_children() and x != splitPath.size() - 1:
			child = child.get_children()
		else:
			return child
	
	# Return the child
	return child


""" SIGNALS """


func _on_IDE_file_dirtied(filePath):
	file_dirtied(filePath)