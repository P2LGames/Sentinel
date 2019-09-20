extends Spatial

export (int, "SELF", "HEAD", "BASE", "LEFT", "RIGHT", "FRONT", "BACK") var attachmentPosition = 0

func get_attachment_position():
	return attachmentPosition

func get_attachment():
	for child in get_children():
		if child.has_method("pass_order"):
			return child
	
	return null