
const RequestType = {
	ENTITY_SETUP = 0,
	ENTITY_REGISTER = 1,
	ENTITY_UPDATE = 2,
	
	COMMAND = 10,
	COMMAND_ERROR = 11,

	FILE_GET = 20,
	FILE_UPDATE = 21,
	UNRECOGNIZED = -1
}

const CommandError = {
	TIMEOUT = 0
}

const GetFileType = {
	FILE = "FILE",
	FUNCTION = "FUNCTION",
	LINE_RANGE = "LINE_RANGE",
	TAG = "TAG"
}

const EntitySetupData = {
	Robot = {
		type = 0,
		_class = "entity.Robot"
	}
}

const entityId = "entityId"
const value = "value"
const command = "command"

const messageType = "type"
const messageData = "serializedData"
const messageError = "errorMessage"

const entity_entityType = "entityType"
const entity_placeholderId = "placeholderId"
const entity_packagePrefix = "entity."

const file_packagePrefix = "command."
const file_package_prefix = "command."

static func create_entity_setup_request():
	# Setup the entity data
	var entitySetupData = ""
	# Loop through each entity type in the setup data and compile our string to send
	for setupData in EntitySetupData.values():
		entitySetupData += String(setupData.type) + ":" + setupData._class
	
	# Get the bytes for the entity setup data
	var setupBytes = entitySetupData.to_ascii()
	
	# Get the length of the data in bytes
	var dataLengthInBytes = Util.int2bytes(setupBytes.size())
	
	# Compile all the bytes into one pool array
	var bytes = PoolByteArray()
	bytes = Util.pad_with_bytes(bytes, 1)
	bytes.append(RequestType.ENTITY_SETUP)
	bytes += dataLengthInBytes
	bytes += setupBytes
	
	# Return the byte array
	return bytes

static func create_entity_register_request(entityType: int, placeholderId: int):
	# Setup our register bytes, including our entityId and placeholderId
	var registerBytes = PoolByteArray()
	registerBytes += Util.int2bytes(entityType)
	registerBytes += Util.int2bytes(placeholderId)
	
	# Get the length of the data in bytes
	var dataLengthInBytes = Util.int2bytes(registerBytes.size())
	
	# Compile all the bytes into one pool array
	var bytes = PoolByteArray()
	bytes = Util.pad_with_bytes(bytes, 1)
	bytes.append(RequestType.ENTITY_REGISTER)
	bytes += dataLengthInBytes
	bytes += registerBytes
	
	# Return the byte array
	return bytes

static func create_command_request(entityId: int, commandId: int, hasParameter: bool, parameter: PoolByteArray):
	# Setup our register bytes, including our entityId and placeholderId
	var commandBytes = PoolByteArray()
	commandBytes += Util.int2bytes(entityId)
	commandBytes += Util.int2bytes(commandId)
	
	# If we have a parameter
	if hasParameter:
		# Add on a byte saying we do
		commandBytes.append(1)
		# Add on a 0 to make it a short, but keep the range of the byte (0...255)
		commandBytes = Util.pad_with_bytes(commandBytes, 1)
		# Add on the parameter bytes
		commandBytes += parameter
	else:
		# Otherwise add on a byte saying we don't
		commandBytes.append(0)
	
	# Get the length of the data in bytes
	var dataLengthInBytes = Util.int2bytes(commandBytes.size())
	
	# Compile all the bytes into one pool array
	var bytes = PoolByteArray()
	bytes = Util.pad_with_bytes(bytes, 1)
	bytes.append(RequestType.COMMAND)
	bytes += dataLengthInBytes
	bytes += commandBytes
	
	# Return the byte array
	return bytes


static func create_file_update_request(entityId: int, commandId: int, filePath: String, 
	className: String, fileContents: String):
	# Setup our register bytes, including our entityId and placeholderId
	var fileUpdateBytes = PoolByteArray()
	fileUpdateBytes += Util.int2bytes(entityId)
	fileUpdateBytes += Util.int2bytes(commandId)
	
	# Turn each string into a byte array
	var filePathBytes = filePath.to_ascii()
	var classNameBytes = (file_package_prefix + className).to_ascii()
	var fileContentsBytes = fileContents.to_ascii()
	
	# Add the lengths of each and the byte array
	fileUpdateBytes += Util.int2bytes(filePathBytes.size())
	fileUpdateBytes += filePathBytes
	fileUpdateBytes += Util.int2bytes(classNameBytes.size())
	fileUpdateBytes += classNameBytes
	fileUpdateBytes += Util.int2bytes(fileContentsBytes.size())
	fileUpdateBytes += fileContentsBytes
	
	# Get the length of the data in bytes
	var dataLengthInBytes = Util.int2bytes(fileUpdateBytes.size())
	
	# Compile all the bytes into one pool array
	var bytes = PoolByteArray()
	bytes = Util.pad_with_bytes(bytes, 1)
	bytes.append(RequestType.FILE_UPDATE)
	bytes += dataLengthInBytes
	bytes += fileUpdateBytes
	
	# Return the byte array
	return bytes

static func bundle_request(requestType, serializedRequest):
	var serverRequest = {}
	
	serverRequest[messageType] = requestType
	serverRequest[messageData] = serializedRequest
	
	return JSON.print(serverRequest)

static func create_entityRequest(entityClass: String, placeholderId: String):
	var request = {}
	
	request["entityType"] = entity_packagePrefix + entityClass
	request["placeholderId"] = placeholderId
	
	return JSON.print(request)
	
	
static func create_commandRequest(entityId: String, command: String, parameters: Array, udata: String):
	var request = {}
	
	request["entityId"] = entityId
	request["command"] = command
	request["parameters"] = parameters
	request["udata"] = udata
	
	return JSON.print(request)

static func create_entityUpdateRequest(entityId: String, entityClass: String, fieldsToUpdate: Dictionary):
	# fieldsToUpdate = Dictionary<field = String, fieldValue = Obj>
	var request = {}
	
	request["entityId"] = entityId
	request["entityClass"] = entity_packagePrefix + entityClass
	request["fieldsToUpdate"] = fieldsToUpdate
	
	return JSON.print(request)

static func create_fileGetRequest(fileName: String):
	var request = {}
	
	request["fileName"] = file_packagePrefix + fileName
	
	return JSON.print(request)

static func create_fileUpdateRequest(entityId: String, entityClass: String, 
					newCode: String, methodName: String, paramTypes: Array):
	var request = {}
	
	request["entityId"] = entityId
	request["className"] = file_packagePrefix + entityClass
	request["fileContents"] = newCode
	request["command"] = methodName
	request["methodName"] = methodName
	request["parameterTypesStrings"] = paramTypes
	
	return JSON.print(request)










