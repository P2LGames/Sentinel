extends TextEdit

func _ready():
	
#	set_line_as_hidden(10, true)
#	set_draw_fold_gutter(true)
#	is_drawing_fold_gutter()
	
	# FIXME put syntax highlighting customiazation here
	#clear_colors()
	#add_color_region("(", ")", Color(0.39, 0.58, 0.93, 1))
	#add_keyword_color("for", Color(0.55, 0, 0.55, 1))
	#theme.function_color = theme.font_color
#	add_color_region(DO_NOT_EDIT_START, DO_NOT_EDIT_END, Color.red)
#	can_fold(10)
	pass


# Move cursor to where it was last time the editor closed
func set_focus(line: int, column: int):
	
	grab_focus()
	
	print(line)
	cursor_set_line(line)
	cursor_set_column(column)
