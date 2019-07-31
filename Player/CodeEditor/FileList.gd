extends ItemList

var current_selection = -1


# Connect needed signals
func _ready():
	pass
#	get_parent().get_child(0).connect("file_dirtied", self, "file_dirtied")
#	get_parent().get_child(0).connect("file_saved", self, "file_saved")
#	get_parent().get_child(0).connect("save_all_files", self, "save_all_files")


# Add file name to the list of items
func add_file(file):
	add_item(file.get_class_name())


# If a file has been changed, append an asterisk to its name
func file_dirtied():
	
	if current_selection != -1:
		var oldText = self.get_item_text(current_selection)
		if !oldText.ends_with('*'):
			self.set_item_text(current_selection, oldText + '*')


# If a file has been saved, remove the asterisk from its name
func file_saved(index):
	var oldText = self.get_item_text(index)
	if oldText.ends_with('*'):
		self.set_item_text(index, oldText.substr(0, oldText.length() - 1))


func save_all_files():
	for i in range(self.get_item_count()):
		self.file_saved(i)


""" SIGNALS """

func _on_FileList_item_selected(index):
	current_selection = index
	get_parent().get_parent().file_selected(index)


func _on_TextEditor_text_changed():
	file_dirtied()
