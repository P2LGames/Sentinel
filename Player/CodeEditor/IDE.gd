extends Panel

var IDEFile = load("res://Player/CodeEditor/IDEFile.gd")

var currentFile = null
var currentIndex: int = -1

var files = []

signal file_dirtied(index)

func _ready():
	# Get the files in the original code
	var originalCodeFiles = get_files_in_directory(get_file_directory())
	
	# Count the files
	var fileCount = 1
	
	# Add each file to our list
	for file in originalCodeFiles:
		add_file(file, file.split(".")[0], String(fileCount))
	
	# Set ourselves to be invisible
	visible = false
	
	# Select the first file
	get_file_list().select(1)
	file_selected(1)
	
	# Process
	set_process(true)


func _process(delta):
	# If there is no file, then stop
	if currentFile == null:
		return
	
	handle_input()


func handle_input():
	
	if Input.is_action_just_pressed("ide_save"):
		save_file()


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


# Add file to list of files
func add_file(fileName, className, entityId):
	files.append(IDEFile.new(fileName, className, entityId))
	get_file_list().add_file(files[files.size() - 1])


# When a file is selected, code editor should load it
func file_selected(index):
	currentFile = files[index]
	currentIndex = index
	
	# Get the current file display text
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
	
	get_file_list().file_saved(currentIndex)
	
	currentFile.save_to_disk()


func save_all_files():
	pass


# Remember where the user was focused
func save_focus():
	currentFile.set_focus_line(get_text_editor().cursor_get_line())
	currentFile.set_focus_col(get_text_editor().cursor_get_column())


""" GETTERS """

func get_target_name():
	return $LeftBar/GridContainer/TargetName


func get_target_type_label():
	return $LeftBar/GridContainer/Type


func get_text_editor():
	return $TextEditor


func get_file_list():
	return $LeftBar/FileList


func get_file_directory():
	return "res://Player/OriginalCode/"


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


func set_target_type(type: String):
	get_target_type_label().text = type


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
		emit_signal("file_dirtied", currentIndex)
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


func _on_FileList_item_selected(index):
	file_selected(index)


func _on_TargetName_text_changed(new_text):
	# Set the inspected entity's name with the new text
	Player.set_inspected_entity_name(new_text)
