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

var displayName = "Robot 1"

var attachments = []
var positionToAttachment = {}
var possibleOrders = {}

var orders = []

var movement = Vector2.ZERO
var move = 0
var rotate = 0
var prevMove = 0
var prevRotate = 0
var hasProcessed = false


func _ready():
	# Setup my possible orders
	possibleOrders[self] = ORDER_TYPES.values()
	
	# Setup my attachments
	setup_attachments()
	
	set_process(true)


func _process(delta):
	# We can print
	if orders.size() > 0:
		if ORDER_TYPES.PRINT in orders[0]:
			print(orders[0].split(":")[1])
			orders.remove(0)
	
	# If we are ready to send stuff, and we haven't processed, process!
	if is_reprogrammable_ready() and not hasProcessed:
		hasProcessed = true
		
		CommunicationManager.command(get_reprogrammable_id(), COMMAND_ID_PROCESS, false, [])


func _physics_process(delta):
	
	var motion = move_and_slide(movement)


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
	return $SpriteContainer/SelectionIndicator


func get_attachment_container():
	return $SpriteContainer/AttachmentContainer


func get_attachment_positions():
	return get_attachment_container().get_children()


func _get_display_name() -> String:
	return displayName


""" SETTERS """

func set_movement(movement: Vector2):
	self.movement = movement


func set_input(code: int, action: int):
	# Send the input command to the server
	send_key_input(code, action)


func _set_display_name(displayName: String):
	self.displayName = displayName


func _set_inspect_items(inspectUI: PopupMenu):
	# Set the display name
	inspectUI.add_separator(self.displayName)
	
	# Call the super method
	._set_inspect_items(inspectUI)


""" ATTACHMENTS """

func setup_attachments():
	# Clear our list of attachments and our dictionary
	attachments = []
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
	attachments.append(attachment)
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
		hasProcessed = false
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


""" SIGNALS """

