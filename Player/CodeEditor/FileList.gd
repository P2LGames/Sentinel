extends ItemList


# Add file name to the list of items
func add_file(file):
	add_item(file.get_class_name())


# If a file has been changed, append an asterisk to its name
func file_dirtied(index):
	# Get the old text
	var oldText = self.get_item_text(index)
	
	# Add the asterisk if it isn't already there
	if !oldText.ends_with('*'):
		self.set_item_text(index, oldText + '*')


# If a file has been saved, remove the asterisk from its name
func file_saved(index):
	# get the old text
	var oldText = self.get_item_text(index)
	
	# Strip off the asterisk
	if oldText.ends_with('*'):
		self.set_item_text(index, oldText.substr(0, oldText.length() - 1))


func save_all_files():
	for i in range(self.get_item_count()):
		self.file_saved(i)


""" SIGNALS """


func _on_IDE_file_dirtied(index):
	file_dirtied(index)
