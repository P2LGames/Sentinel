extends KinematicBody

export var healthMax: float = 100
export var healthCurrent: float = 100
export var selectable = true


""" ENTITY INTERACTION """

func is_selectable():
	return selectable


func _select():
	pass


func _deselect():
	pass
