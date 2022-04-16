class_name IDEFile

var _filePath
var _className
var _fileType
var _focusLine
var _focusCol
var _text = ""
var _displayText = ""

var permissionParts = []
var hiddenPartsCount = 0
var requiredParts = []
var requiredStarting = ""
var requiredEnding = ""
var requiredWhole = ""

var permissionsLevel = 0


func _init(filePath: String, className: String, fileType: String):
	self._filePath = filePath
	self._className = className
	self._fileType = fileType
	self._focusLine = 0
	self._focusCol = 0
	
	# Create a new directory to make sure the code dir exists
	var currentCodePath := Directory.new()
	
	# Make sure the code directory exists
	if not currentCodePath.dir_exists(Constants.PLAYER_CODE_DIR):
		currentCodePath.make_dir(Constants.PLAYER_CODE_DIR)
	
	# Create new file reader
	var fileReader = File.new()
	
	# Open it up
	fileReader.open(self._filePath, File.READ)
	
	# Get the text of the file
	self._text = fileReader.get_as_text()
	
	# Close our file streams
	fileReader.close()
	
	# Setup display text
	setup_display_text()


# Given a file, generate the text that a user will see
func setup_display_text():
	# A list of groups of text tagged by what the user can do with that text
	permissionParts = determine_permissions()
	requiredParts = []
	requiredStarting = ""
	requiredEnding = ""
	requiredWhole = ""
	
	_displayText = ""
	
	var addDoNotEditToWrite = false
	var hasFoundWrite = false
	var requiredText = ""
	
	for x in range(permissionParts.size()):
		var part = permissionParts[x]
		
		# Don't show the user if they don't have access
		if part.permission == Constants.NO_ACCESS:
			# Get the row count in the part's text, subtract 1 so it does not include the tag in front of it
			var rowCount = part.text.split('\n').size()
			
			# Setup the read only text
			var readOnlyText = Constants.HIDE_ROWS + str(rowCount) + part.text
			
			# Add the read only to the display text, it will be hidden due to the tag
			_displayText += readOnlyText
			
			# If we have not found a write yet
			if not hasFoundWrite:
				# Add the required text to the required starting
				requiredStarting += readOnlyText
			# Otherwise, add it to the required text
			else:
				requiredText += readOnlyText
			
		# Show the user but tell them that they can't edit and add text to list of immutable text chunks
		elif part.permission == Constants.READ_ONLY:
			# Add info to immutable text chunks
			var readOnlyText = part.text
			
			# Want to write the do not edit text above only if there is a write above me
			var y = x
			# Line break is always required, unless there was a NO ACCESS before this read
			var lineBreakRequired = true
			while y > 0:
				# Decrement y
				y -= 1
				
				# If we find a write before us
				if permissionParts[y].permission == Constants.WRITE:
					# Add the do not edit text
					readOnlyText = Constants.DO_NOT_EDIT_START + readOnlyText
					
					# If the line break is required
					if lineBreakRequired:
						# Find the first line break
						var index = _displayText.find_last('\n')
						
						# If we have not found a write yet
						if not hasFoundWrite:
							# Add the required text to the required starting
							requiredStarting += _displayText.substr(index, _displayText.length() - index)
						# Otherwise, add it to the required text
						else:
							requiredText += _displayText.substr(index, _displayText.length() - index)
					
					break
				# Otherwise, if we find a read first, stop, the other read will handle the write above
				elif permissionParts[y].permission == Constants.READ_ONLY:
					break
				# Otherwise, if we found a no access, then stop the line break from being added
				elif permissionParts[y].permission == Constants.NO_ACCESS:
					lineBreakRequired = false
			
			# Add it to the display text
			_displayText += readOnlyText
			
			# If we have not found a write yet
			if not hasFoundWrite:
				# Add the required text to the required starting
				requiredStarting += readOnlyText
			# Otherwise, add it to the required text
			else:
				requiredText += readOnlyText
			
			# Add do not edit to the next write
			addDoNotEditToWrite = true
			
		# Show the user the text normally
		elif part.permission == Constants.WRITE:
			# If this is the first write
			var isFirstWrite = not hasFoundWrite
			
			# We have found a write
			hasFoundWrite = true
			
			# If we have accumulated required text
			if addDoNotEditToWrite:
				# If this is the first write, add the tag to the required starting
				if isFirstWrite:
					requiredStarting += Constants.DO_NOT_EDIT_END + "\n"
				#Otherwise, just add the tag to the required text
				else:
					requiredText += Constants.DO_NOT_EDIT_END + "\n"
				
				# Don't want to add do not edit anymore
				addDoNotEditToWrite = false
				
				# And add the same to the display
				_displayText += Constants.DO_NOT_EDIT_END
			
			# If there is required text
			if requiredText != "":
				# Add the required text to our required parts
				requiredParts.append(requiredText)
				
				# Erase the required text
				requiredText = ""
			
			# Add the part's text to the display
			_displayText += part.text
	
	# If the required text is not empty, then the last permission was not write
	if requiredText != "":
		# If we did not find a write at all
		if not hasFoundWrite:
			# Clear all the other required parts parts
			requiredParts.clear()
			requiredStarting = ""
			
			# Make the whole text required
			requiredWhole = _displayText
		else:
			# Set the required ending to the required text
			requiredEnding = requiredText
	
#	print("Required Start: ", requiredStarting)
#	print()
#	print("Required End: ", requiredEnding)
#	print()
#	print("Required Parts: ", requiredParts)
	
	return _displayText


# Reverse the create_display_text function, given what the user has typed generate the source code
func create_code_from_display_text():
	var userCode = _displayText
	
	var currentIndex = 0
	
	var addDoNotEditToWrite = false
	var hadRequiredText = false
	
	for x in range(permissionParts.size()):
		var part = permissionParts[x]
		
		# Don't show the user if they don't have access
		if part.permission == Constants.NO_ACCESS:
			# Get the row count in the part's text
			var rowCount = part.text.split('\n').size()
			
			# Get the tag that we will need to find
			var tag = Constants.HIDE_ROWS + str(rowCount)
			
			# Set the current index to the found index + 1
			var textAndIndex = find_first_and_replace(userCode, currentIndex, tag, part.permissionsTag)
			userCode = textAndIndex[0]
			currentIndex = textAndIndex[1] + part.permissionsTag.length() + part.text.length()
			
			# We had required text
			hadRequiredText = true
			
		# Show the user but tell them that they can't edit and add text to list of immutable text chunks
		elif part.permission == Constants.READ_ONLY:
			# Add info to immutable text chunks
			var readOnlyText = part.text
			
			# Want to write the do not edit text above only if there is a write above me
			var y = x
			var readHadTag = false
			while y > 0:
				# Decrement y
				y -= 1
				
				# If we find a write before us
				if permissionParts[y].permission == Constants.WRITE:
					# This read part had a tag
					readHadTag = true
					
					# Then find and replace that string
					var textAndIndex = (find_first_and_replace(userCode, currentIndex, 
						Constants.DO_NOT_EDIT_START, part.permissionsTag))
					userCode = textAndIndex[0]
					currentIndex = textAndIndex[1] + part.permissionsTag.length() + part.text.length()
					
					break
				# Otherwise, if we find a read first, stop, the other read will handle the write above
				elif permissionParts[y].permission == Constants.READ_ONLY:
					break
			
			# If we did not have a tag
			if not readHadTag:
				# Then we want to find the text in this permssion part
				var partIndex = userCode.find(part.text, currentIndex)
				#print("Text at index: ", userCode.substr(currentIndex, part.text.length()))
				
				# And add the tag to the front of it
				userCode = userCode.insert(partIndex, part.permissionsTag)
				
				# Set the current index
				currentIndex = partIndex + part.permissionsTag.length() + part.text.length()
			
			# Has required text if we are here
			hadRequiredText = true
			
			# Add do not edit to the next write
			addDoNotEditToWrite = true
			
		# Show the user the text normally
		elif part.permission == Constants.WRITE:
			# If the write is the first thing
			if x == 0:
				# If the code starts with a break
				if userCode.begins_with('\n'):
					# Insert the permission text at the beginning
					userCode = userCode.insert(0, part.permissionsTag)
				# Otherwise, add the permission with the break
				else:
					userCode = userCode.insert(0, part.permissionsTag + '\n')
					
					# Add 1 more character to factor in the line break
					currentIndex += 1
				
				currentIndex += part.permissionsTag.length()
				
				# Continue to next loop
				continue
			
			# If we want to add a not not edit
			if addDoNotEditToWrite:
				# Don't want to add do not edit anymore
				addDoNotEditToWrite = false
				
				# Find and replace the tag
				var textAndIndex = find_first_and_replace(userCode, currentIndex, 
					Constants.DO_NOT_EDIT_END, part.permissionsTag)
				userCode = textAndIndex[0]
				currentIndex = textAndIndex[1] + part.permissionsTag.length()
			# Otherwise, if the permission above me is a NO ACCESS
			elif permissionParts[x - 1].permission == Constants.NO_ACCESS:
				# Write the permissions text at the current index
				userCode = userCode.insert(currentIndex, part.permissionsTag)
				
				# Move the current index up
				currentIndex += part.permissionsTag.length()
			
			# If the permission above me was another write, then don't even try to find where to put the tag..
			# Users could have destroyed it
	
	return userCode


func find_first_and_replace(text: String, startIndex: int, find: String, replace: String):
	# Create a new version of the text
	var replacedText = text
	
	# Replace the tag with the one in the permission part
	var foundIndex = text.find(find, startIndex)
	
	# If the found index is -1
	if foundIndex == -1:
		# Return the original stuff
		return [text, startIndex]
	
	# Remove the tag
	replacedText.erase(foundIndex, find.length())
	
	# Add the old tag
	replacedText = replacedText.insert(foundIndex, replace)
	
	# Return the index of the find
	return [replacedText, foundIndex]


# Check that the 'do not edit' parts have not been changed
func is_valid_code(text: String):
	# If we have a required text, just use that
	if requiredWhole != "":
		return text == requiredWhole
	
	# If we have a starting or an ending, make sure they are correct
	if requiredStarting != "":
		if not text.begins_with(requiredStarting):
			return false
	if requiredEnding != "":
		if not text.ends_with(requiredEnding):
			return false
	
	# Loop through each part of the code
	for part in requiredParts:
		# If we can't find a specific required part in the code, then return false
		if text.find(part) < 0:
			return false
	
	# Otherwise, we found all the parts we needed to find in required, true!
	return true
	
	# FIXME we should also check that the number of instances of the DO_NOT_EDIT_START string
	# is what we expect so we don't fail to regenerate code if the user typed it themselves


# Save the copy of the code currently loaded in the game
func save_to_disk():
	# Create the code from the display text
	_text = create_code_from_display_text()
	
	# Write a new file with the text
	var fileWriter = File.new()
	fileWriter.open(self._filePath, File.WRITE)
	fileWriter.store_line(_text)


# Split up the source code file in chunks based on what the user can do with each chunk. Determined by comments in the source file
func determine_permissions():
	# Get the text
	var text = self._text
	# All access deliminators should start with '//// *'
	
	# Split the text up into pieces baed on the permissions tag
	var pieces = text.split(Constants.PERMISSIONS_TAG, false)
	
	# And track the labeled pieces
	var labeledPieces = []
	
	# Loop through each piece and parse out its permissions
	for piece in pieces:
		var piecePermission = 'u'
		var code = ''
		
		# Get the string all the way to the *END tag
		# Split it, get the access level
		# Find the permission tag end
		var endOfPermissions = piece.find(Constants.PERMISSIONS_TAG_END)
		
		# Get the permissions tag
		var permissionsTag = (Constants.PERMISSIONS_TAG + 
			piece.substr(0, endOfPermissions) + Constants.PERMISSIONS_TAG_END)
		
		# Get a substring to that point
		var permissionsString = piece.substr(0, endOfPermissions)
		
		# Get the permission from the permissions string
		piecePermission = get_permission(permissionsString.strip_edges())
		
		# If the piece is hidden
		if piecePermission == Constants.NO_ACCESS:
			# Increment the hidden parts
			hiddenPartsCount += 1
		
		# Get the code
		code = piece.substr(piece.find("\n"), piece.length())
		
		# Track the labeled pieces
		labeledPieces.push_back({ 'permission': piecePermission, 'text': code, 
			'options': -1, 'permissionsTag': permissionsTag })
	
	# Return the labeled pieces
	return labeledPieces


func permissions_sort(a, b):
	if a[1] < b[1]:
		return true
	return false

""" GETTERS """

func get_text():
	return self._text


func get_display_text():
	return self._displayText


func get_file_path():
	return self._filePath


func get_class_name():
	return self._className


func get_focus_line():
	return self._focusLine


func get_focus_col():
	return self._focusCol


func get_first_displayed_permission():
	# Loop through the permission parts
	for part in permissionParts:
		# If we find one that is different from no access
		if part.permission != Constants.NO_ACCESS:
			# Return it
			return part.permission
	
	# Return an empty string if we find nothing
	return ""


func get_last_displayed_permission():
	# Get the index of the last permission part
	var i = permissionParts.size() - 1
	
	# Loop backwards
	while i >= 0:
		var part = permissionParts[i]
		# If we find one that is different from no access
		if part.permission != Constants.NO_ACCESS:
			# Return it
			return part.permission
		
		# Decrement
		i -= 1
	
	# Return an empty string if we find nothing
	return ""


func get_permission(permissionsString: String):
	print(self._filePath)
	if permissionsString == '':
		return 'u'
	
	# Track the permissions
	var permissions = []
	
	# Get each permission part
	var permissionParts = permissionsString.split(":")
	
	# Loop through it all
	for part in permissionParts:
		# Split the part to get the permissions tag and level
		var tagAndLevel = part.split(",")
		
		# Append each permission to the permissions
		permissions.append([tagAndLevel[0], int(tagAndLevel[1])])
	
	# Sort the permissions based on permission level
	permissions.sort_custom(self, "permissions_sort")
	
	# Track the best valid permission
	var bestValidPermission = permissions[0]
	
	# Find the one that matches or is the closest to the permissionsLevel
	for permission in permissions:
		# If the permission is still in range
		if permission[1] <= permissionsLevel:
			# Then it is our new best permission
			bestValidPermission = permission
		# Otherwise, stop, we won't find a better one
		else:
			break
	
	# Return the best permission based on our level
	return bestValidPermission[0]


""" SETTERS """

func set_focus_line(line: int):
	self._focusLine = line


func set_focus_col(col: int):
	self._focusCol = col


func set_text(newText: String):
	self._text = newText


func set_display_text(newText: String):
	self._displayText = newText
