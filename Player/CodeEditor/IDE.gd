extends Panel

var IDEFile = load("res://Player/CodeEditor/IDEFile.gd")

var currentFile = null
var currentFilePath: String = ""

var files = []
var itemPathToFile: Dictionary = {}

signal file_dirtied(filePath)
signal closing()

func _ready():
	# Setup the root of the file tree
	get_file_tree().create_item()
	get_file_tree().set_hide_root(true)
	
	add_directory(Constants.GENERIC_CODE_DIR)
	
	# Set ourselves to be invisible
	visible = false
	
	# Select the first file
	get_file_tree().get_root().get_children().get_children().select(0)
	#file_selected(1)
	
	# Process
	set_process(true)


func _process(delta):
	# If there is no file, then stop
	if currentFile == null:
		return
	
	if Input.is_action_just_pressed("ide_save"):
		save_file()


func _unhandled_key_input(event):
	if visible:
		accept_event()


# Revert to default code and reset focus
func reset_code():
	# If our current file is null, do nothing
	if currentFile == null:
		return
	
	currentFile.reset_code()
	
	# Set the editor text
	get_text_editor().text = currentFile.get_display_text()
	
	# Set the focus line and column
	currentFile.set_focus_line(0)
	currentFile.set_focus_col(0)
	
	# Set the focus in the new text
	set_focus()


func add_directory(dir: String):
	# Create the folder item
	var fileTree = get_file_tree()
	var folder = fileTree.create_item(fileTree.get_root())
	
	# Set the folder to the file name
	var folderName = Util.get_file_name(dir)
	folder.set_text(0, folderName)
	
	# Get the files in the original code
	var files = get_files_in_directory(dir)
	
	# Add each file to our list
	for file in files:
		# Get the file name
		var fileName = file.split(".")[0]
		
		# Create a new ide file
		var newIDEFile = IDEFile.new(dir, file, fileName)
		
		# Create a tree item with it, with folder as the parent
		var treeItem = fileTree.create_item(folder)
		treeItem.set_text(0, fileName)
		
		# Create the item's path
		var itemPath = fileTree.get_path_from_item(treeItem)
		
		# Save it to our dictionary
		itemPathToFile[itemPath] = newIDEFile


# When a file is selected, code editor should load it
func file_selected():
	# Get the selected item
	var selectedItem = get_file_tree().get_selected()
	
	# Get the item path
	var itemPath = get_file_tree().get_path_from_item(selectedItem)
	
	# Set the current file and the item path to it
	if itemPath in itemPathToFile.keys():
		# Set the current file and the file path
		currentFile = itemPathToFile[itemPath]
		currentFilePath = itemPath
		
		# Set the text to the current file
		get_text_editor().text = currentFile.get_display_text()


# Show or hide the code editor
func toggle_visibility():
	# If we are visible, and going to hide, save the current focus
	if visible:
		save_focus()
	
	# Hide or show
	visible = !visible
	
	# If we are now visible, set the focus
	if visible:
		set_focus()


func save_file():
	save_focus()
	
	get_file_tree().file_saved(currentFilePath)
	
	currentFile.save_to_disk()


func save_all_files():
	pass


# Remember where the user was focused
func save_focus():
	if currentFile:
		currentFile.set_focus_line(get_text_editor().cursor_get_line())
		currentFile.set_focus_col(get_text_editor().cursor_get_column())


""" GETTERS """

func get_target_name():
	return $LeftBar/EntityName/TargetName


func get_target_type_label():
	return $LeftBar/EntityType/Type


func get_target_class_label():
	return $LeftBar/EntityClass/Class


func get_text_editor():
	return $TextEditor


func get_output_text_node():
	return $OutputArea/OutputText


func get_output_label():
	return $OutputArea/OutputLabel


func get_file_list():
	return $LeftBar/FileList


func get_file_tree():
	return $LeftBar/FileTree


func get_files_in_directory(fileDirectory):
	var files = []
	var dir = Directory.new()
	
	# Open new directory
	dir.open(fileDirectory)
	
	# Begin listing the files in the directory
	dir.list_dir_begin()
	
	# While there are still files, 
	while true:
		# Get the next file
		var file = dir.get_next()
		
		# If it was empty, stop
		if file == "":
			break
		
		# As long as the file doesn't start with a period, add it
		elif not file.begins_with("."):
			files.append(file)
	
	# End the listing
	dir.list_dir_end()
	
	# Return all files in the directory
	return files


""" SETTERS """

func set_target_name(text: String):
	get_target_name().text = text
	
	set_output_label_text(text)


func set_output_label_text(text: String):
	get_output_label().text = "Output: " + text


func set_target_type(type: String):
	get_target_type_label().text = type


func set_target_class(_class: String):
	get_target_class_label().text = _class


func set_focus():
	# If we don't have a file selected yet
	if currentFile == null:
		return
	
	# Get the line and column
	var line = currentFile.get_focus_line()
	var col = currentFile.get_focus_col()
	
	# Set the focus from that line and column
	get_text_editor().set_focus(line, col)


""" SIGNALS """

func _on_ResetButton_pressed():
	reset_code()


func _on_RecompileButton_pressed():
	# Save the current file
	save_file()
	
	# Get the entity id
	var targetEntityId = Player.get_inspected_entity_id()
	
	# Get the class name
	var className = currentFile.get_class_name()
	
	# Get the file text
	var fileText = currentFile.get_text()
	
	# If the inspected entity exists and we have a class name
	if targetEntityId != null and className != null:
		# Recompile his code with this one
		CommunicationManager.file_update(targetEntityId, -1, className, fileText)


func _on_CloseButton_pressed():
	toggle_visibility()
	
	# Emit closing signal
	emit_signal("closing")


func _on_save_all_files():
	for file in files:
		file.save_to_disk()


func _on_TextEditor_text_changed():
	# Get the new text
	var newText = get_text_editor().text
	
	# Check if it is valid
	if currentFile.is_valid_code(newText):
		# If it is, then set the current file's display text!
		currentFile.set_display_text(newText)
		
		# Save the user's focus
		save_focus()
		
		# Emit the dirtied signal
		print(currentFilePath)
		emit_signal("file_dirtied", currentFilePath)
	# Otherwise, undo whatever just happened...
	else:
		# Don't let the user write invalid code
		# UNDO!
		get_text_editor().undo()


func _on_TextEditor_cursor_changed():
	currentFile.set_focus_line(get_text_editor().cursor_get_line())
	currentFile.set_focus_col(get_text_editor().cursor_get_column())


func _on_SaveButton_pressed():
	save_file()


func _on_TargetName_text_changed(newText):
	# Set the inspected entity's name with the new text
	Player.set_inspected_entity_name(newText)
	
	# Set the output label name
	set_output_label_text(newText)


func _on_TargetEntity_class_changed(newClass):
	set_target_class(newClass)


func _on_FileTree_item_selected():
	file_selected()
