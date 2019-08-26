extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal cursor_changed()
signal text_changed()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_text_editor():
	return $TextEditor


""" SIGNALS """

func _on_TextEditor_cursor_changed():
	emit_signal("cursor_changed")


func _on_TextEditor_text_changed():
	emit_signal("text_changed")
