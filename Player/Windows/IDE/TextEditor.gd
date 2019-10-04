extends TextEdit


func font_size_increase():
	set_font_size(get_font_size() + 1)


func font_size_decrease():
	var newFontSize = get_font_size() - 1
	
	# Cap the size at FONT_SIZE_MINIMUM
	if newFontSize >= Constants.FONT_SIZE_MINIMUM:
		set_font_size(newFontSize)


func hide_rows():
	
	var startLine = 0
	var startColumn = 0
	
	var previouslyFound = []
	
	# Loop until we get 0, 0
	while true:
		
		# Find the hide rows tags
		var colAndLine = search(Constants.HIDE_ROWS, SEARCH_MATCH_CASE, startLine, startColumn)
		
		# If we found nothing, break out of the loop
		if colAndLine.size() == 0:
			break
		
		# Update the start line and column
		startColumn = colAndLine[0]
		startLine = colAndLine[1]
		
		# Make the unique id for what we found
		var found = str(startLine) + "-" + str(startColumn)
		
		# If this is the first search and the start col and line are 0, break out of the loop
		if found in previouslyFound:
			break
		
		# Add the found to previously found
		previouslyFound.append(found)
		
		# hide the rows using the tag line and start
		hide_rows_with_tag(startLine, startColumn)
		
		# Increment the column and set the start column to 0
		startColumn = 0
		startLine += 1


func hide_rows_with_tag(tagLine: int, tagStart: int):
	# Get the text at the line
	var line = get_line(tagLine)
	
	# Scrape off the characters until the tag start
	var tag = line.substr(tagStart, line.length() - tagStart)
	
	# Get the number at the end of the tag
	var rowsToHide = int(tag.replace(Constants.HIDE_ROWS, ''))
	
	# Hide the rows, starting with the tagLine
	for x in range(tagLine, tagLine + rowsToHide):
		# If the line contains a do not edit tag
		var xLine = get_line(x)
		if (Constants.DO_NOT_EDIT_START in xLine or
			Constants.DO_NOT_EDIT_END in xLine):
			# Continue, we don't want to hide it
			continue
		# Otherwise hide the line
		else:
			set_line_as_hidden(x, true)


func _ready():
	
#	set_line_as_hidden(10, true)
#	set_draw_fold_gutter(true)
#	is_drawing_fold_gutter()
	
	var reservedWordColor = Color.orange
	
	# Classes
	add_keyword_color("abstract", reservedWordColor)
	add_keyword_color("class", reservedWordColor)
	add_keyword_color("extends", reservedWordColor)
	add_keyword_color("import", reservedWordColor)
	add_keyword_color("implements", reservedWordColor)
	add_keyword_color("enum", reservedWordColor)
	add_keyword_color("instanceof", reservedWordColor)
	add_keyword_color("interface", reservedWordColor)
	add_keyword_color("native", reservedWordColor)
	add_keyword_color("package", reservedWordColor)
	
	# Functions
	add_keyword_color("void", reservedWordColor)
	add_keyword_color("static", reservedWordColor)
	add_keyword_color("public", reservedWordColor)
	add_keyword_color("private", reservedWordColor)
	add_keyword_color("protected", reservedWordColor)
	add_keyword_color("super", reservedWordColor)
	add_keyword_color("synchronized", reservedWordColor)
	add_keyword_color("volatile", reservedWordColor)
	add_keyword_color("transient", reservedWordColor)
	
	# Errors, if, else, try etc
	add_keyword_color("this", reservedWordColor)
	add_keyword_color("if", reservedWordColor)
	add_keyword_color("else", reservedWordColor)
	add_keyword_color("switch", reservedWordColor)
	add_keyword_color("case", reservedWordColor)
	add_keyword_color("try", reservedWordColor)
	add_keyword_color("catch", reservedWordColor)
	add_keyword_color("throw", reservedWordColor)
	add_keyword_color("throws", reservedWordColor)
	add_keyword_color("finally", reservedWordColor)
	add_keyword_color("return", reservedWordColor)
	
	# VARIABLES AND PRIMITIVES
	add_keyword_color("new", reservedWordColor)
	add_keyword_color("int", reservedWordColor)
	add_keyword_color("float", reservedWordColor)
	add_keyword_color("double", reservedWordColor)
	add_keyword_color("boolean", reservedWordColor)
	add_keyword_color("byte", reservedWordColor)
	add_keyword_color("char", reservedWordColor)
	add_keyword_color("long", reservedWordColor)
	add_keyword_color("null", reservedWordColor)
	add_keyword_color("short", reservedWordColor)
	add_keyword_color("true", reservedWordColor)
	add_keyword_color("false", reservedWordColor)
	add_keyword_color("final", reservedWordColor)
	add_keyword_color("const", reservedWordColor)
	
	# LOOPS AND BREAKS
	add_keyword_color("for", reservedWordColor)
	add_keyword_color("do", reservedWordColor)
	add_keyword_color("while", reservedWordColor)
	add_keyword_color("goto", reservedWordColor)
	add_keyword_color("default", reservedWordColor)
	add_keyword_color("break", reservedWordColor)
	add_keyword_color("continue", reservedWordColor)
	add_keyword_color(";", reservedWordColor)
	
#	add_keyword_color(Constants.DO_NOT_EDIT_START, Color(1, 0, 0))
#	add_keyword_color(Constants.DO_NOT_EDIT_END, Color(1, 0, 0))
	
	# Comments
	add_color_region("//", "\n", Color.darkgray, true)
	add_color_region("/*", "*/", Color(0.38, 0.59, 0.33))
	
	# Strings and Characters
	add_color_region("\"", "\"", Color(0.416, 0.53, 0.35))
	add_color_region("'", "'", Color(0.416, 0.53, 0.35))

""" GETTERS """

func get_font_size():
	return get("custom_fonts/font").get_size()


""" SETTERS """

func set_text(newText: String):
	text = newText
	
	hide_rows()


# Move cursor to where it was last time the editor closed
func set_focus(line: int, column: int):
	
	grab_focus()
	
	cursor_set_line(line)
	cursor_set_column(column)


func set_font_size(fontSize: int):
	get("custom_fonts/font").set_size(fontSize)


""" SIGNALS """

func _on_TextEditor_text_changed():
	hide_rows()
