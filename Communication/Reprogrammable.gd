extends Node

export (String, "Robot") var entityType = "Robot"

var entityId: String = ""
var ready: bool = false
var registerMessageSent: bool = false

var currentOutput := Array()

signal message_printed(printMessage)

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


func set_id(newId: String):
	# Set our new id
	entityId = newId
	# We are now ready to send and recieve messages
	ready = true


func get_current_output():
	return currentOutput




