extends "res://Entities/GenericEntity.gd"

const COMMAND_ID_PROCESS = 0
const COMMAND_ID_INPUT = 1

const ATTACHMENT_POSITIONS = {
	SELF = 0,
	HEAD = 1,
	BASE = 2,
	LEFT = 3,
	RIGHT = 4,
	FRONT = 5,
	BACK = 6
}

const INPUT_TYPES = {
	PLAYER_KEY = 0,
	PLAYER_MOUSE = 1
}

const ORDER_TYPES = {
	PRINT = 0, # PRINT:
}

var positionToAttachment = {}

var orders = []

var movement = Vector3.ZERO
var processing = false

func _ready():
	# Super call to ready
	._ready()
	
	var reprogrammable = get_reprogrammable_component()
	
	# Our default class is RobotDefault
	reprogrammable.defaultClass = "RobotDefault"
	reprogrammable.currentClass = "RobotDefault"
	
	# Setup the default path
	var defaultPath = FileManager.join(Constants.PLAYER_CODE_DIR, "OriginalCode/RobotDefault.java")
	reprogrammable.defaultClassPath = defaultPath
	reprogrammable.currentClassPath = defaultPath
	
	# Setup my attachments
	setup_attachments()


func _process(delta):
	# We can print
	if orders.size() > 0:
		if ORDER_TYPES.PRINT in orders[0]:
			print(orders[0].split(":")[1])
			orders.remove(0)
	
	# If we are ready to send stuff, and we haven't processed, process!
	if is_reprogrammable_ready() and not processing:
		processing = true
		
		CommunicationManager.command(get_reprogrammable_id(), COMMAND_ID_PROCESS, false, [])


func _physics_process(delta):
	
	if movement != Vector3.ZERO:
		print(movement)
		print(global_transform.origin)
		move_and_slide(movement)


""" INPUT """

func _select():
	# Highlight ourselves
	get_selection_indicator().visible = true


func _deselect():
	# Unhighlight ourselves
	get_selection_indicator().visible = false


func send_key_input(code: int, pressed: int):
	var bytes: PoolByteArray = []
	
	# Attach the position that the input is coming from
	bytes += Util.int2bytes(ATTACHMENT_POSITIONS.SELF)
	
	# Attach the type of input
	bytes += Util.int2bytes(INPUT_TYPES.PLAYER_KEY)
	
	# Attach the input values, in this case, 0's
	bytes += Util.int2bytes(code)
	bytes += Util.int2bytes(pressed)
	
	# Send it all to the server
	CommunicationManager.command(get_reprogrammable_id(), COMMAND_ID_INPUT, true, bytes)


""" GETTERS """

func get_selection_indicator():
	return $SelectionIndicator


func get_attachment_container():
	return $AttachmentContainer


func get_attachment_positions():
	return get_attachment_container().get_children()


""" SETTERS """

func set_movement(movement: Vector3):
	self.movement = movement


func _set_inspect_items(inspectUI: PopupMenu):
	# Set the display name
	inspectUI.add_separator(self.displayName)
	
	# Call the super method
	._set_inspect_items(inspectUI)


func set_processing(value: bool):
	processing = value


""" ATTACHMENTS """

func setup_attachments():
	# Clear our list of attachments and our dictionary
	positionToAttachment = {}
	
	# Add the robot
	add_attachment(ATTACHMENT_POSITIONS.SELF, self)
	
	# Get all of the attachment positions
	var attachmentPositions = get_attachment_positions()
	
	# Setup our position to attachment with the nodes we just got
	for attachmentPosition in attachmentPositions:
		# Get the position tag and the attachment
		var positionId = attachmentPosition.get_attachment_position()
		var attachment = attachmentPosition.get_attachment()
		
		# Even if the attachment is null, add it
		add_attachment(positionId, attachment)


func add_attachment(position: int, attachment):
	# Add the attachment to our list of attachments
	positionToAttachment[position] = attachment
	
	# Set the attachment's robot to be myself
	if attachment != null and attachment.has_method("set_robot"):
		attachment.set_robot(self)


""" ORDER HANDLING """

func _handle_command(commandId: int, value: PoolByteArray):
	# Process command
	if commandId == COMMAND_ID_PROCESS:
		var orderBytes := value
		
		while orderBytes.size() > 0:
			# Get the attachment position and the order type
			var attachmentPosition: int = Util.bytes2int(PoolByteArray(Util.slice_array(orderBytes, 0, 4)))
			var orderType: int = Util.bytes2int(PoolByteArray(Util.slice_array(orderBytes, 4, 8)))
			
			# Get the message length
			var messageLength: int = Util.bytes2int(PoolByteArray(Util.slice_array(orderBytes, 8, 12)))
			
			# Get the message bytes
			var messageBytes := PoolByteArray(Util.slice_array(orderBytes, 12, 12 + messageLength))
			
			# Route the order with the position
			route_order(attachmentPosition, orderType, messageBytes)
			
			# Set the order bytes to no longer have the order we just pulled out of it
			orderBytes = PoolByteArray(Util.slice_array(orderBytes, 12 + messageLength))
		
		# We have indeed processed
		processing = false
	# Input command
	elif commandId == COMMAND_ID_INPUT:
		pass


func route_order(attachmentPosition: int, orderType: int, messageBytes: PoolByteArray):
	var attachment = positionToAttachment[attachmentPosition]
	
	# If we have an attachment at the given position
	if attachment != null:
		# Pass the ordertype and the message bytes
		attachment.pass_order(orderType, messageBytes)
	# Otherwise, we want to throw an error for the user
	else:
		print_error(Constants.ERROR_CODE.NO_ATTACHMENT, "No attachment at this location, can't pass order")


func pass_order(orderType: int, orderBytes: PoolByteArray):
	if orderType == ORDER_TYPES.PRINT:
		print_message(orderBytes.get_string_from_ascii(), Constants.MESSAGE_TYPE.NORMAL)


func print_error(error: int, message: String):
	var mess = "Error Code: " + str(error) + ". " + message
	
	# Print the error
	print_message(mess, Constants.MESSAGE_TYPE.ERROR)


""" PERSISTENCE """

func save():
	# Save our data
	var saveData = .save()
	
	# Save the reprogrammable stuff
	saveData["reprogrammableData"] = get_reprogrammable_component().save()
	
	# Save the orders in each component
	saveData["attachmentData"] = {}
	for pos in positionToAttachment.keys():
		if pos == ATTACHMENT_POSITIONS.SELF or positionToAttachment[pos] == null:
			continue
		
		saveData["attachmentData"][pos] = positionToAttachment[pos].save()
	
	# Return the save data
	return saveData


func load_from_data(data: Dictionary):
	# Load in the parent data
	.load_from_data(data)
	
	# Clear the current information
	positionToAttachment = {}
	
	# Load the reprogrammable stuff
	get_reprogrammable_component().load_from_data(data["reprogrammableData"])
	
	# Load component orders
	var attachmentData = data["attachmentData"]
	print(attachmentData)
	for pos in attachmentData.keys():
		# Create a new attachment using the name and path
		var attachment = load(attachmentData[pos]["filename"]).instance()
		get_node(attachmentData[pos]["parent"]).add_child(attachment)
		
		# Pass the attachment its load data
		attachment.load_from_data(attachmentData[pos])
		
		# Add the attachment to the position to attachment dict
		positionToAttachment[int(pos)] = attachment
		
		# If they have the set robot, set them to be ourselves
		if attachment.has_method("set_robot"):
			attachment.set_robot(self)
			


""" SIGNALS """

