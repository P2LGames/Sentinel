extends Node

# Our models and constants
const FrameworkModels = preload("res://Communication/CommunicationModels.gd")

# The current placeholder ID to use
var currPlaceholderId = 0

# Map of our entities
var entityMap := Dictionary()
var entityPlaceholderMap := Dictionary()

# Client variables
#const HOST = "localhost"
const HOST = "pgframework.westus.azurecontainer.io"
const PORT = 5545
var client = StreamPeerTCP.new()

var serverSetup = false
var running = false

# A list of messages to send to the server
var toSend = []

signal setup_complete()
signal failed_to_connect()


func _ready():
	# We want this node to loop
	set_process(true)
	
	# Connect to the host
	client.connect_to_host(HOST, PORT)
	
	# Send the setup data as soon as we are connected
	var setupData = FrameworkModels.create_entity_setup_request()
	toSend.append(setupData)

##### MESSAGE ROUTING #####

func route_response(responseType: int, responseData: PoolByteArray):
	# Run the entity setup no matter what
	if responseType == FrameworkModels.RequestType.ENTITY_SETUP:
		print("Setting up server")
		entity_setup_handler(responseData)
	
	# If we aren't running, don't route other responses
	if not running:
		return
	
	if responseType == FrameworkModels.RequestType.ENTITY_REGISTER:
		entity_register_handler(responseData)
	elif responseType == FrameworkModels.RequestType.COMMAND:
		command_handler(responseData)
	elif responseType == FrameworkModels.RequestType.COMMAND_ERROR:
		command_error_handler(responseData)
	elif responseType == FrameworkModels.RequestType.FILE_UPDATE:
		file_update_handler(responseData)


func entity_setup_handler(responseData: PoolByteArray):
	"""Handles all setup responses"""
	# If the first byte is a 1, then the setup was successful
	if responseData[0] == 1:
		serverSetup = true
		print("Server setup!")
		
		# Emit the server setup complete signal
		emit_signal("setup_complete")
	else:
		# Slice off the first two values of the byte array
		var stringData: PoolByteArray = []
		for i in range(2, responseData.size()):
			stringData.append(responseData[i])
		
		# Turn the error data into a string and print it
		var errorString = String(stringData)
		print(errorString)


func entity_register_handler(responseData: PoolByteArray):
	"""Handles all registration responses"""
	# If the first byte is a 1, then the setup was successful
	if responseData[0] == 1:
		# Parse out the placeholder and entity id
		var placeholderIdArray = PoolByteArray(Util.slice_array(responseData, 2, 6))
		var entityIdArray = PoolByteArray(Util.slice_array(responseData, 6, 10))
		
		# Parse the placeholder and entityId out of the arrays
		var placeholderId = Util.bytes2int(placeholderIdArray)
		var entityId = Util.bytes2int(entityIdArray)
		print("Placeholder: ", placeholderId, " EntityId: ", entityId)
		
		var entity = entityPlaceholderMap[str(placeholderId)]
		entity.get_node("Reprogrammable").set_id(str(entityId))
		
		# Save the new id
		entityMap[str(entityId)] = entity
		
		# Delete the old mapping in the placeholder
		entityPlaceholderMap.erase(str(placeholderId))
	else:
		# Get the placeholder id from the failed register request
		var placeholderId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 2, 6)))
		
		# Slice off the first 6 values of the byte array, they are the failure short and placeholder id
		var stringData = PoolByteArray(Util.slice_array(responseData, 6))
		
		# Turn the error data into a string and print it
		var errorString = "Register Error: " + stringData.get_string_from_ascii()
		
		# Pass the error and string to the entity
		entityPlaceholderMap[str(placeholderId)].print_message(errorString, 
			Constants.MESSAGE_TYPE.ERROR)


func command_handler(responseData: PoolByteArray):
	"""Handles all command responses"""
	# If the first byte is a 1, then the command was successful
	if responseData[0] == 1:
		# Parse out the placeholder and entity id
		var entityIdArray = PoolByteArray(Util.slice_array(responseData, 2, 6))
		var commandIdArray = PoolByteArray(Util.slice_array(responseData, 6, 10))
		
		# Parse the command and entity id out of the arrays
		var entityId = Util.bytes2int(entityIdArray)
		var commandId = Util.bytes2int(commandIdArray)
		
		# Get the command's return value
		var value = PoolByteArray(Util.slice_array(responseData, 10))
		
		if str(entityId) in entityMap.keys():
			# Get the entity from the placeholder map, have it save its new id
			var entity = entityMap[str(entityId)]
		
			# Make sure he has the _handle_command method
			if entity.has_method("_handle_command"):
				# Send him the command and the return value of that command
				entity._handle_command(commandId, value)
			# If he doesn't throw an error
			else:
				print("ERROR: Reprogrammable entities must have the _handle_command(commandId: int, value: PoolByteArray) method")
		else:
			print("ERROR: Entity does not exist, ", entityId)
	else:
		# Get the entity and command id from the failed register request
		var entityId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 2, 6)))
		var commandId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 6, 10)))
		
		# Slice off the first two values and the two ints, they are the failure short, etc
		var stringData = PoolByteArray(Util.slice_array(responseData, 10))
		
		# Turn the error data into a string and print it
		var errorString = "Command Error: " + stringData.get_string_from_ascii()
		
		# Pass the error and string to the entity
		entityMap[str(entityId)].print_message(errorString, 
			Constants.MESSAGE_TYPE.ERROR)


func command_error_handler(responseData: PoolByteArray):
	"""Handles all command error responses"""
	# Get the type of command error
	var errorType = int(responseData[0])
	
	# Parse out the placeholder and entity id
	var entityIdArray = PoolByteArray(Util.slice_array(responseData, 2, 6))
	var commandIdArray = PoolByteArray(Util.slice_array(responseData, 6, 10))
	
	# Parse the command and entity id out of the arrays
	var entityId = Util.bytes2int(entityIdArray)
	var commandId = Util.bytes2int(commandIdArray)
	
	# Get the command's return value
	var errorMessageData = PoolByteArray(Util.slice_array(responseData, 10))
	var errorMessage = "Timeout: " + errorMessageData.get_string_from_ascii() + "\n"
	
	# Get the entity from the placeholder map, have it save its new id
	var entity = entityMap[str(entityId)]
	
	# Pass the error to the entity
	entityMap[str(entityId)].print_message(errorMessage, 
		Constants.MESSAGE_TYPE.ERROR)
	
	# It is no longer processing, all threads were closed in the framework
	if entity.has_method("set_processing"):
		entity.set_processing(false)
	

func file_update_handler(responseData: PoolByteArray):
	"""Handles file update responses"""
	# If the first byte is a 1, then the update was successful
	if responseData[0] == 1:
		# Parse the command and entity id out of the arrays
		var entityId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 2, 6)))
		var commandId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 6, 10)))
		
		# Get the class name length
		var classNameLength = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 10, 14)))
		
		# Get the class name
		var classPackage := PoolByteArray(Util.slice_array(responseData, 14, 14 + classNameLength)).get_string_from_ascii()
		var classPackageSplit = classPackage.split(".")
		var className = classPackageSplit[classPackageSplit.size() - 1]
		
		# Print a messsage
		entityMap[str(entityId)].print_message("\nRecompile Successful, class swapped to " + className + "!\n", 
			Constants.MESSAGE_TYPE.NORMAL)
		
		# Change the entity's current class
		entityMap[str(entityId)].set_current_class(className)
	else:
		# Get the entity and command id from the failed register request
		var entityId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 2, 6)))
		var commandId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 6, 10)))
		
		# Get the class name length
		var errorStringLength = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 10, 14)))
		
		# Slice off the first two values and the two ints, they are the failure short, etc
		var stringData = PoolByteArray(Util.slice_array(responseData, 14 + errorStringLength))
		
		# Turn the error data into a string and print it
		var errorString = "File Update Error: " + stringData.get_string_from_ascii() + "\n"
		
		# Pass the error and string to the entity
		entityMap[str(entityId)].print_message(errorString, 
			Constants.MESSAGE_TYPE.ERROR)


""" MESSAGE SENDING """

func add_entity(newEntity):
	"""Add the entity to our map, and return the current placeholder.
	
	Parameters:
		newEntity (Entity): The entity to add with a reprogrammable component
	"""
	# Increment the placeholder
	currPlaceholderId += 1
	
	# Map the entity to the current placeholder
	entityPlaceholderMap[str(currPlaceholderId)] = newEntity
	
	# Return the current placeholder id
	return currPlaceholderId


func register_entity(newEntity, entityTypeId: int) -> bool:
	"""Register the entity with the server and track it via our entityMap.
	
	Parameters:
		newEntity (Entity): The entity to register with a reprogrammable component
		entityType (int): The type of entity to register
	
	Return:
		Whether or not the message was actually sent
	"""
	# Add the entity to our map and get it's placeholder id
	var placeholderId = add_entity(newEntity)
	
	# Create the request
	var registerRequest = FrameworkModels.create_entity_register_request(entityTypeId, placeholderId)
	
	# Send the request to the server
	return send_message(registerRequest)


func command(entityId: int, commandId: int, hasParameter: bool, parameter: PoolByteArray) -> bool:
	# If the entityId is -1, then they are not setup yet, don't send anything
	if entityId == -1:
		return false
	
	# Create the request
	var commandRequest = FrameworkModels.create_command_request(entityId, commandId, hasParameter, parameter)
	
	# Send the request to the server
	return send_message(commandRequest)


func file_update(entityId: int, commandId: int, className: String, fileContents: String) -> bool:
	# If the entityId is -1, then they are not setup yet, don't send anything
	if entityId == -1:
		return false
	
	# Create the request
	var fileUpdateRequest = FrameworkModels.create_file_update_request(entityId, commandId, className, fileContents)
	
	# Send the request to the server
	return send_message(fileUpdateRequest)


func send_message(msg: PoolByteArray) -> bool:
	# If the server is setup, send the message, otherwise, don't
	if serverSetup:
		toSend.append(msg)
	
	# Return whether or not the message was sent
	return serverSetup


""" LOOPING """
            
func _process(delta):
	# Ensure the connection worked
	if serverSetup and client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print("Server changed to CONNECTING")
		serverSetup = false
	elif serverSetup and client.get_status() == StreamPeerTCP.STATUS_ERROR:
		print("Server changed to ERROR")
		serverSetup = false
	elif serverSetup and client.get_status() == StreamPeerTCP.STATUS_NONE:
		print("Server changed to NONE")
		serverSetup = false
	
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		# Loop through the things to send and send them
		for msg in toSend:
#			print("Sending Message: ", msg)
			var error = client.put_data(msg)
			
			if error != 0:
				print("Send Error: ", error)
		
		# Clear the messages for the next loop
		toSend.clear()
	
		# Get the number of bytes we can read in
		var bytesAvailable = client.get_available_bytes()
		
		# If we have bytes, get them and process them
		if bytesAvailable > 0:
			# Get the response type as a byte
			var responseType = int(client.get_16())
			if responseType != FrameworkModels.RequestType.COMMAND:
				print("Response Type: ", responseType)
			
			# Get the byte count
			var byteCount = int(client.get_32())
			if responseType != FrameworkModels.RequestType.COMMAND:
				print("Byte Count: ", byteCount)
			
			# If the byte count is less or equal to 0
			if byteCount <= 0:
				# Continue, nothing to read
				return
			
			# Read the number of bytes into a array
			var responseArray = client.get_data(byteCount)
			
			# Get the error code if there was one
			var errorCord = responseArray[0]
			if errorCord != 0:
				print(errorCord)
			
			# Store the bytes for use
			var responseBytes = responseArray[1]
			
			route_response(responseType, responseBytes)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		client.disconnect_from_host()
		
		get_tree().quit()


func stop_running():
	# Not running
	running = false
	
	# Clear to send
	toSend.clear()
	
	# Clear the maps
	entityMap = {}
	entityPlaceholderMap = {}


""" SIGNALS """

func _on_ConnectionTimeout_timeout():
	# Check to see if the client is connected
	if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		emit_signal("failed_to_connect")
