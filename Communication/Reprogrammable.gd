extends Node

export (int, "Robot") var entityType = 0

var entityId: String = ""
var ready: bool = false
var registerMessageSent: bool = false

func _ready():
	# We are processing
	set_process(true)


func _process(delta: float):
	# If we have not sent our register message, keep trying to send it
	if not registerMessageSent:
		registerMessageSent = CommunicationManager.register_entity(get_parent(), entityType)
	# Otherwise, meaning we sent the message, stop trying to send it, and turn process off
	else:
		set_process(false)


func set_id(newId: String):
	# Set our new id
	entityId = newId
	# We are now ready to send and recieve messages
	ready = true