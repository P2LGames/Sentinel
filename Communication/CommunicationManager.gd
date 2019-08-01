extends Node

# Our models and constants
const FrameworkModels = preload("res://Communication/CommunicationModels.gd")

# The current placeholder ID to use
var currPlaceholderId = 0

# Map of our entities
var entityMap := Dictionary()
var entityPlaceholderMap := Dictionary()

# Client variables
const HOST = "localhost"
const PORT = 6789
var client = StreamPeerTCP.new()

var serverSetup = false

# A list of messages to send to the server
var toSend = []


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
	if responseType == FrameworkModels.RequestType.ENTITY_SETUP:
		entity_setup_handler(responseData)
	elif responseType == FrameworkModels.RequestType.ENTITY_REGISTER:
		entity_register_handler(responseData)
	elif responseType == FrameworkModels.RequestType.COMMAND:
		command_handler(responseData)
	elif responseType == FrameworkModels.RequestType.FILE_UPDATE:
		file_update_handler(responseData)


func entity_setup_handler(responseData: PoolByteArray):
	"""Handles all setup responses"""
	# If the first byte is a 1, then the setup was successful
	if responseData[0] == 1:
		print('Server is set up!')
		serverSetup = true
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


func file_update_handler(responseData: PoolByteArray):
	"""Handles file update responses"""
	# If the first byte is a 1, then the command was successful
	if responseData[0] == 1:
		# Parse out the placeholder and entity id
		var entityIdArray = PoolByteArray(Util.slice_array(responseData, 2, 6))
		var commandIdArray = PoolByteArray(Util.slice_array(responseData, 6, 10))
		
		# Parse the command and entity id out of the arrays
		var entityId = Util.bytes2int(entityIdArray)
		var commandId = Util.bytes2int(commandIdArray)
		
		# Print a messsage
		entityMap[str(entityId)].print_message("Recompile Successful!\n", 
			Constants.MESSAGE_TYPE.NORMAL)
	else:
		# Get the entity and command id from the failed register request
		var entityId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 2, 6)))
		var commandId = Util.bytes2int(PoolByteArray(Util.slice_array(responseData, 6, 10)))
		
		# Slice off the first two values and the two ints, they are the failure short, etc
		var stringData = PoolByteArray(Util.slice_array(responseData, 10))
		
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
	# Create the request
	var commandRequest = FrameworkModels.create_command_request(entityId, commandId, hasParameter, parameter)
	
	# Send the request to the server
	return send_message(commandRequest)


func file_update(entityId: int, commandId: int, className: String, fileContents: String) -> bool:
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
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		# Loop through the things to send and send them
		for msg in toSend:
#			print("Sending Message: ", msg)
			var error = client.put_data(msg)
			if error != 0:
				print("Error: ", error)
		
		# Clear the messages for the next loop
		toSend.clear()
	
		# Get the number of bytes we can read in
		var bytesAvailable = client.get_available_bytes()
		# If we have bytes, get them and process them
		if bytesAvailable > 0:
			# Get the response type as a byte
			var responseType = int(client.get_16())
#			print(responseType)
			
			# Get the byte count
			var byteCount = int(client.get_32())
#			print(byteCount)
			
			# Read the number of bytes into a array
			var responseArray = client.get_data(byteCount)
			
			# Get the error code if there was one
			var errorCord = responseArray[0]
			
			# Store the bytes for use
			var responseBytes = responseArray[1]
			
			route_response(responseType, responseBytes)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		client.disconnect_from_host()
		
		get_tree().quit()
