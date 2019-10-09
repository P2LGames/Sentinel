extends Node

func copy_dir(from: String, to: String, overwrite: bool = false):
	var dir = Directory.new()
	
	# Make the directory in target folder
	var fromName = get_file_name(from)
	var toFolder = join(to, fromName)
	if not dir.dir_exists(toFolder):
		dir.make_dir(toFolder)
	
	# If the path exists
	if dir.open(from) == OK:
		# Start looping through the directory
		dir.list_dir_begin(true, true)
		
		# Get the file name
		var fileName = dir.get_next()
		
		# While the file name is not empty
		while (fileName != ""):
			# Get the file path
			var filePath = join(dir.get_current_dir(), fileName)
			var toFilePath = join(toFolder, fileName)
			
			# If the path is a directory
			if dir.dir_exists(filePath):
				# Then recursively copy the directory
				copy_dir(filePath, toFolder)
			# Otherwise, if the file exists, and we want to copy the file
			elif dir.file_exists(toFilePath) and overwrite:
				# Copy it!
				dir.copy(filePath, toFilePath)
			# Otherwise, if the file does not exist, copy it
			elif not dir.file_exists(toFilePath):
				# Copy it!
				dir.copy(filePath, toFilePath)
			
			# Get the next file
			fileName = dir.get_next()


func copy(from: String, to: String):
	var dir = Directory.new()
	dir.copy(from, to)


func delete(path: String):
	var dir = Directory.new()
	dir.remove(path)


func find(fileName: String, recursive: bool = true):
	return "NEEDS IMPLEMENTATION"


func get_dir_contents(path: String):
	"""
	Gets the directory contents formatted in a dictionary with the file name
	pointing to the file path.
	
	Parameters:
		path (String): The path to the directory
	
	Return:
		files (Dictionary): The fileName -> filePath formatted dictionary
	"""
	var files = {}
	
	# Create a new dir
	var dir = Directory.new()
	
	# If the path exists
	if dir.open(path) == OK:
		# Start looping through the directory
		dir.list_dir_begin(true, true)
		
		# Get the file name
		var fileName = dir.get_next()
		
		# While the file name is not empty
		while (fileName != ""):
			# Add the file to our files list
			files[fileName] = join(dir.get_current_dir(), fileName)
			
			# Get the next file
			fileName = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	# Return the files we found
	return files


func get_files_in_directory(path: String):
	"""
	Gets the directory files as a list.
	
	Parameters:
		path (String): The path to the directory
	
	Return:
		files (Array): The list of files in this folder
	"""
	var files = []
	var dir = Directory.new()
	
	# Open new directory
	dir.open(path)
	
	# Begin listing the files in the directory
	dir.list_dir_begin()
	
	# While there are still files, 
	while true:
		# Get the next file
		var file = dir.get_next()
		
		# If it was empty, stop
		if file == "":
			break
		# As long as the file doesn't start with a period, add it
		elif not file.begins_with("."):
			files.append(file)
	
	# End the listing
	dir.list_dir_end()
	
	# Return all files in the directory
	return files


func get_file_name(filePath: String):
	var splitPath = filePath.split("/")
	
	if splitPath[splitPath.size() - 1] == "" and splitPath.size() > 1:
		return splitPath[splitPath.size() - 2]
	else:
		return splitPath[splitPath.size() - 1]


func get_root_name(filePath: String):
	var splitPath = filePath.split("/")
	
	return splitPath[0]


func join(path1: String, path2: String) -> String:
	if path1.ends_with("/") and path2.begins_with("/"):
		return path1 + path2.substr(1, path2.length())
	elif path1.ends_with("/") and not path2.begins_with("/"):
		return path1 + path2
	elif not path1.ends_with("/") and path2.begins_with("/"):
		return path1 + path2
	else:
		return path1 + "/" + path2

