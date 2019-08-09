extends TextEdit

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
	
	# Comments
	add_color_region("//", "\n", Color.darkgray, true)
	add_color_region("/*", "*/", Color(0.38, 0.59, 0.33))
	
	# Strings
	add_color_region("\"", "\"", Color(0.416, 0.53, 0.35))


# Move cursor to where it was last time the editor closed
func set_focus(line: int, column: int):
	
	grab_focus()
	
	cursor_set_line(line)
	cursor_set_column(column)
