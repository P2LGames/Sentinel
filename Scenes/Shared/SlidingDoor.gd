extends Spatial

export var doorClosed = true
export var openOffset = Vector3(-2, 0, 0)
export var openSpeed = 2.0

onready var door = $Door
onready var origin = door.translation

var poweredBy = []

signal door_opened()
signal door_closed()

func open_door():
	# If the door is already open, stop
	if not doorClosed:
		return
	
	# The door is now open
	doorClosed = false
	emit_signal("door_opened")
	get_move_sound().play()
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(door, get_tween(), origin + openOffset, openSpeed)


func close_door():
	# If the door is already closed, stop
	if doorClosed:
		return
	
	# The door is now closed
	doorClosed = true
	emit_signal("door_closed")
	get_move_sound().play()
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(door, get_tween(), origin, openSpeed)


func add_powering_obj(obj):
	poweredBy.append(obj)
	
	if poweredBy.size() > 0:
		open_door()


func remove_powering_obj(obj):
	poweredBy.erase(obj)
	
	if poweredBy.size() == 0:
		close_door()


""" GETTERS """

func get_tween():
	return $Tween


func get_move_sound():
	return $MoveSound
