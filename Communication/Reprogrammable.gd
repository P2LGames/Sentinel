extends Node

export (String, "Robot") var entityType = "Robot"
# Default and current classes
export var defaultCodePath = Constants.LEVEL_1_CODE_DIR
export var defaultFile: String = ""

onready var defaultFilePath: String = FileManager.join(defaultCodePath, defaultFile)
onready var currentFilePath: String = FileManager.join(defaultCodePath, defaultFile)
onready var defaultClass: String = defaultFile.get_basename()
onready var currentClass: String = defaultFile.get_basename()

var entityId: int = -1
var ready: bool = false
var hasLoaded: bool = true
var registerMessageSent: bool = false

var currentOutput := Array()

signal message_printed(printMessage)
signal class_changed(newClass)


func _ready():
	if get_parent().notReprogrammable:
		# We are processing
		set_process(false)


func print_message(message: String, type: int):
	# Create the print message
	var printMessage = Models.PrintMessage(message, type)
	
	# Apped the message to the current output
	currentOutput.append(printMessage)
	
	# If we have passed the 200 lines, start removing lines
	if currentOutput.size() > 200:
		currentOutput.remove(0)
	
	# Emit the message printed
	emit_signal("message_printed", printMessage)


func _process(delta: float):
	# If we have not sent our register message, keep trying to send it
	if not registerMessageSent:
		registerMessageSent = CommunicationManager.register_entity(get_parent(), Constants.TYPE_TO_TYPE_ID[entityType])
	# Otherwise, see if we need loading, if we do, wait until we are ready
	elif not hasLoaded and ready:
		# Try to recompile his code
		Player.get_ide().recompile_entity_from_file(get_parent(), 
			int(entityId), currentFilePath)
		
		hasLoaded = true
	# Otherwise, meaning we sent the message, stop trying to send it, and turn process off
	elif hasLoaded:
		set_process(false)


""" GETTERS """

func get_current_output_text():
	return currentOutput


func get_current_class():
	return currentClass


func get_default_class():
	return defaultClass


""" SETTERS """

func set_id(newId: int):
	# Set our new id
	entityId = newId
	
	# We are now ready to send and recieve messages
	ready = true


func set_current_class(_class: String):
	currentClass = _class
	
	# Emit a signal saying that the class changed
	emit_signal("class_changed", _class)


func set_current_file_path(filePath: String):
	currentFilePath = filePath


""" PERSISTENCE """

func save():
	var saveData = {
		"currentClass": currentClass,
		"currentFilePath": currentFilePath
	}
	
	return saveData


func load_from_data(data: Dictionary):
	currentClass = data["currentClass"]
	currentFilePath = data["currentFilePath"]
	
	# If the current class path is not equal to the default
	if currentFilePath != defaultFilePath:
		# We have not yet completed our load in
		hasLoaded = false
		
		# Set process to true
		set_process(true)




