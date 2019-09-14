extends ConfirmationDialog

var fileName = ""


func set_file_name(file):
	# Save the file name
	fileName = file
	
	# Set the dialog text
	dialog_text = Constants.CONFIRM_OVERWRITE_TEXT.format({ "file": fileName })


func _on_ConfirmOverwritePopup_confirmed():
	# Clear the file name
	set_file_name("")
