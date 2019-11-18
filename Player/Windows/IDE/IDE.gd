extends WindowDialog

var currentFile = null
var currentFilePath: String = ""

var itemPathToFile: Dictionary = {}

var loaded = false
onready var savedPosition = rect_global_position

signal file_dirtied(filePath)


func _ready():
	# Ensure the user code dir is created
	var dir = Directory.new()
	if not dir.dir_exists(Constants.PLAYER_CODE_DIR):
		dir.make_dir(Constants.PLAYER_CODE_DIR)
	
	# Load in previous data
	load_rect_information()
	
	# Setup the root of the file tree
#	get_file_tree().create_item()
	get_file_tree().set_hide_root(true)
	
	update_file_tree()
	
	# No looping
	set_process(false)


func _process(delta):
	"""Process will only run while the ide is visible"""
	
	# Input handling
	if Input.is_action_just_pressed("ide_save"):
		save_file()
	elif Input.is_action_just_pressed("ide_recompile"):
		recompile()
	elif Input.is_action_just_pressed("hide_window"):
		hide()
	elif Input.is_action_just_pressed("font_size_increase"):
		get_text_editor().font_size_increase()
		get_output_text_node().font_size_increase()
	elif Input.is_action_just_pressed("font_size_decrease"):
		get_text_editor().font_size_decrease()
		get_output_text_node().font_size_decrease()
	
	if rect_global_position != savedPosition:
		# Save it's position...
		savedPosition = rect_global_position
		
		save_rect_information()


func save_file():
	if currentFile == null:
		return
	
	save_focus()
	
	get_file_tree().file_saved(currentFilePath)
	
	currentFile.save_to_disk()


func save_all_files():
	pass


func recompile():
	if currentFile == null or Player.get_inspected_entity() == null:
		return
	
	# Save the current file
	save_file()
	
	# Get the entity id, file path, class name and file text
	var targetEntityId = Player.get_inspected_entity_id()
	var filePath = currentFile.get_file_path()
	var className = currentFile.get_class_name()
	var fileText = get_text_editor().text
	
	# If the inspected entity exists and we have a class name
	if targetEntityId != null and className != null:
		# Recompile his code with this one
		CommunicationManager.file_update(targetEntityId, -1, filePath, className, fileText)
		
		# Set the current class folder
		Player.get_inspected_entity().get_reprogrammable_component().currentFilePath = currentFilePath


func recompile_entity_from_file(entity, entityId, filePath):
	# Get the ide file
	var ideFile = get_file_tree().get_file_from_path(filePath)
	
	# If the ide file is null, stop
	if ideFile == null:
		return
	
	# Get the class name and file text
	var className = ideFile.get_class_name()
	var fileText = ideFile.get_text()
	
	# If the inspected entity exists and we have a class name
	if className != null:
		# Recompile his code with this one
		CommunicationManager.file_update(entityId, -1, filePath, className, fileText)
		
		# Set the class folder
		entity.get_reprogrammable_component().currentFilePath = filePath


func save_focus():
	if currentFile:
		currentFile.set_focus_line(get_text_editor().cursor_get_line())
		currentFile.set_focus_col(get_text_editor().cursor_get_column())


func save_rect_information():
	# If we are loaded then save
	if loaded:
		SavingManager.save_ide_rect(Rect2(rect_global_position, rect_size))


func save_metadata():
	if loaded:
		SavingManager.save_ide_metadata()


func load_rect_information():
	# Load in the rect info from the manager
	var newRect = SavingManager.load_ide_rect()
	
	# If it is null, stop
	if newRect == null:
		return
	
	# Otherwise, set our position and size from the rect
	rect_global_position = newRect.position
	savedPosition = newRect.position
	rect_size = newRect.size
	
	loaded = true


func update_file_tree():
	get_file_tree().set_root_to_path(Constants.PLAYER_CODE_DIR)


""" GETTERS """

func get_target_name():
	return $LeftBar/EntityData/EntityName/TargetName


func get_target_type_label():
	return $LeftBar/EntityData/EntityType/Type


func get_target_class_label():
	return $LeftBar/EntityData/EntityClass/Class


func get_text_editor():
	return $TextEditor


func get_output_text_node():
	return $OutputArea/OutputText


func get_output_label():
	return $OutputArea/OutputLabel


func get_file_tree():
	return $LeftBar/FileTree


func get_recompile_button():
	return $LeftBar/Buttons/RecompileButton


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


# Show or hide the code editor
func set_visible(value: bool):
	# If we are visible, and going to hide, save the current focus
	if visible:
		save_focus()
	
	# Hide or show
	visible = value
	
	# If we are now visible, set the focus
	if visible:
		set_focus()


func set_selected_file(path: String):
	# Get the file tree and select the given item
	get_file_tree().select_tree_item_with_path(path)


""" SIGNALS """

func _on_RecompileButton_pressed():
	recompile()


func _on_CloseButton_pressed():
	hide()


func _on_save_all_files():
	for file in itemPathToFile.values():
		file.save_to_disk()


func _on_TextEditor_text_changed():
	if not currentFile:
		return
	
	# Get the new text
	var newText = get_text_editor().text
	
	# Check if it is valid
	if currentFile.is_valid_code(newText):
		# If it is, then set the current file's display text!
		currentFile.set_display_text(newText)
		
		# Save the user's focus
		save_focus()
		
		# Emit the dirtied signal
		emit_signal("file_dirtied", currentFilePath)
	# Otherwise, undo whatever just happened...
	else:
		# Don't let the user write invalid code
		# UNDO!
		get_text_editor().undo()


func _on_TextEditor_cursor_changed():
	if not currentFile:
		return
	
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


func _on_IDE_resized():
	save_rect_information()


func _on_FileTree_file_selected(file, filePath):
	# Update the current file and path
	currentFile = file
	currentFilePath = filePath
	
	# If the file is not a .java, we can't recompile it
	if file._fileType != "java":
		get_recompile_button().disabled = true
	# Otherwise, we can
	else:
		get_recompile_button().disabled = false
	
	# Set the text to the current file
	get_text_editor().set_text(currentFile.get_display_text())


func _on_IDE_about_to_show():
	# Should process
	set_process(true)


func _on_IDE_popup_hide():
	set_process(false)
