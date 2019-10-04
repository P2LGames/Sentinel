extends TextEdit

func font_size_increase():
	set_font_size(get_font_size() + 1)


func font_size_decrease():
	var newFontSize = get_font_size() - 1
	
	# Cap the size at FONT_SIZE_MINIMUM
	if newFontSize >= Constants.FONT_SIZE_MINIMUM:
		set_font_size(newFontSize)


func add_output(printMessage):
	# Add the text to the text edit
	insert_text_at_cursor(printMessage.message)
	
	# Move the cursor to the end, this will move the viewport down
	cursor_set_line(get_line_count())
	
	# TODO: Color the text depending on the type of message


func set_output(output: Array):
	# Clear the current text
	text = ""
	
	# Loop through each message in the output and add it to the text edit
	for message in output:
		add_output(message)


""" GETTERS """

func get_font_size():
	return get("custom_fonts/font").get_size()


""" SETTERS """

func set_font_size(fontSize: int):
	get("custom_fonts/font").set_size(fontSize)


""" SIGNALS """

func _on_TargetEntity_print_message(printMessage):
	add_output(printMessage)

