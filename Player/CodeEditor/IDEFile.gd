class_name IDEFile

# Messages that the user sees
const DO_NOT_EDIT_START = '// DO NOT EDIT BELOW THIS LINE'
const DO_NOT_EDIT_END = '// DO NOT EDIT ABOVE THIS LINE'

var _origPath
var _currPath
var _className
var _entityId
var _focusLine
var _focusCol
var _text = ""
var _displayText = ""

var allAccessParts = []
var requiredParts = []


func _init(fileName, className, entityId):
	self._origPath = "res://Player/OriginalCode/" + fileName
	self._currPath = "res://Player/CurrentCode/" + fileName
	self._className = className
	self._entityId = entityId
	self._focusLine = 0
	self._focusCol = 0
	
	var fileReader = File.new()
	var fileWriter = File.new()
	
	# If the files doesn't exist, make it
	# If we haven't edited/created this file before, the current code is the same as the original code
	if !fileWriter.file_exists(self._currPath):
		fileWriter.open(self._currPath, File.WRITE)
		fileReader.open(self._origPath, File.READ)
		self._text = fileReader.get_as_text()
		
		fileWriter.store_line(self._text)
	# Otherwise, set the unsaved text to the current code
	else:
		fileReader.open(self._currPath, File.READ)
		self._text = fileReader.get_as_text()
	
	fileWriter.close()
	fileReader.close()
	
	setup_display_text()


# Given a file, generate the text that a user will see
func setup_display_text():
	# A list of groups of text tagged by what the user can do with that text
	allAccessParts = determine_access()
	requiredParts = []
	
	_displayText = ""
	
	for part in allAccessParts:
		# Don't show the user if they don't have access
		if part.label == "NOACCESS":
			continue
		# Show the user but tell them that they can't edit and add text to list of immutable text chunks
		elif part.label == "READONLY":
			var readOnlyText = DO_NOT_EDIT_START + part.text + DO_NOT_EDIT_END
			_displayText += readOnlyText
			requiredParts.append(readOnlyText)
		# Show the user the text normally
		elif part.label == "READWRITE":
			_displayText += part.text
	
	return _displayText


# Reverse the create_display_text function, given what the user has typed generate the source code
func create_code_from_display_text():
	var userCode = _displayText
	var ret = []
	
	# Iterate through the list of original chunks of text and fill in any gaps with changes from the user
	for part in allAccessParts:
		# User did not see this chunk, so it is unchanged
		if part.label == "NOACCESS":
			ret.append(part)
			
		elif part.label == "READONLY":
			
			var index = userCode.find(DO_NOT_EDIT_END) + DO_NOT_EDIT_END.length()
			
			userCode = userCode.substr(index, userCode.length() - index)
			
			ret.append(part)
		# Get either the rest of the text or the text until the next READONLY chunk
		# (This will fail if the user types the DO_NOT_EDIT_START string in their code)
		elif part.label == "READWRITE":
			if userCode.find(DO_NOT_EDIT_START) < 0:
				ret.append({'label': 'READWRITE', 'text': userCode})
				break
			else:
				var index = userCode.find(DO_NOT_EDIT_START) - 1
				var newCode = userCode.substr(0, index)
				userCode = userCode.substr(index, userCode.length() - index)
				ret.append({'label': 'READWRITE', 'text': newCode})
	
	recreate_code(ret)


# Recreate the source code file based on the new chunks. This should be the inverse of determine_access()
func recreate_code(labeledPieces):
	var text = ''
	
	for piece in labeledPieces:
		var newText = '//// *'
		newText += piece.label# + '\n'
		newText += piece.text
		text += newText
	
	self._text = text


# Check that the 'do not edit' parts have not been changed
func is_valid_code(text: String):
	# Loop through each part of the code
	for part in requiredParts:
		# If we can't find a specific required part in the code, then return false
		if text.find(part) < 0:
			return false
	
	# Otherwise, we found all the parts we needed to find in required, true!
	return true
	
	# FIXME we should also check that the number of instances of the DO_NOT_EDIT_START string
	# is what we expect so we don't fail to regenerate code if the user typed it themselves


# Overwrite current code with original code
func reset_code():
	# Create a reader and a writer
	var fileReader = File.new()
	var fileWriter = File.new()
	
	# Open both files to the current and original path
	fileReader.open(_origPath, File.READ)
	fileWriter.open(_currPath, File.WRITE)
	
	# Set the text to the read file
	self._text = fileReader.get_as_text()
	
	# Setup the display text
	setup_display_text()
	
	# Store the new text
	fileWriter.store_line(self._text)
	
	# Close the reader and writer
	fileWriter.close()
	fileReader.close()


# Save the copy of the code currently loaded in the game
func save_to_disk():
	# Create the code from the display text
	create_code_from_display_text()
	
	# Write a new file with the text
	var fileWriter = File.new()
	fileWriter.open(self._currPath, File.WRITE)
	fileWriter.store_line(self._text)


# Split up the source code file in chunks based on what the user can do with each chunk. Determined by comments in the source file
func determine_access():
	var text = self._text
	# All access deliminators should start with '//// *'
	
	var pieces = text.split('//// *', false)
	var labeledPieces = []
	
	for piece in pieces:
		var label = 'UNKNOWN'
		var code = ''
		
		for accessType in ['NOACCESS', 'READONLY', 'READWRITE']:
			if piece.begins_with(accessType):
				label = accessType
				code = piece.substr(accessType.length(), piece.length() - accessType.length())
#				print("CODE: ", code)
		
		labeledPieces.push_back({'label': label, 'text': code})
	
	return labeledPieces


""" GETTERS """

func get_text():
	return self._text


func get_display_text():
	return self._displayText


func get_orig_path():
	return self._origPath


func get_curr_path():
	return self._currPath


func get_class_name():
	return self._className


func get_focus_line():
	return self._focusLine


func get_focus_col():
	return self._focusCol


""" SETTERS """

func set_focus_line(line: int):
	self._focusLine = line


func set_focus_col(col: int):
	self._focusCol = col


func set_text(newText: String):
	self._text = newText


func set_display_text(newText: String):
	self._displayText = newText
