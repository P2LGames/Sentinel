extends Node

export (String, "Robot") var entityType = "Robot"

var entityId: String = ""
var ready: bool = false
var registerMessageSent: bool = false

var currentOutput := Array()

# Default and current classes
var defaultClass: String = ""
var currentClass: String = ""

signal message_printed(printMessage)
signal class_changed(newClass)


func _ready():
	# We are processing
	set_process(true)


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
	# Otherwise, meaning we sent the message, stop trying to send it, and turn process off
	else:
		set_process(false)


""" GETTERS """

func get_current_output_text():
	return currentOutput


func get_current_class():
	return currentClass


func get_default_class():
	return defaultClass


""" SETTERS """

func set_id(newId: String):
	# Set our new id
	entityId = newId
	
	# We are now ready to send and recieve messages
	ready = true


func set_current_class(_class: String):
	print("Setting new class: " + _class)
	
	currentClass = _class
	
	# Emit a signal saying that the class changed
	emit_signal("class_changed", _class)


""" PERSISTENCE """

func save():
	var saveData = {
		"currentClass": currentClass
	}
	
	return saveData


func load_from_data(data: Dictionary):
	currentClass = data["currentClass"]





