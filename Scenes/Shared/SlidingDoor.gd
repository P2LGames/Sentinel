extends Spatial

export var doorClosed = true
export var openOffset = Vector3(-2, 0, 0)
export var openSpeed = 2.0

onready var door = $Door
onready var origin = door.translation




signal door_opened()
signal door_closed()

func open_door():
	# If the door is already open, stop
	if not doorClosed:
		return
	
	# The door is now open
	doorClosed = false
	emit_signal("door_opened")
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(door, get_tween(), origin + openOffset, openSpeed)


func close_door():
	# If the door is already closed, stop
	if doorClosed:
		return
	
	# The door is now closed
	doorClosed = true
	emit_signal("door_closed")
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(door, get_tween(), origin, openSpeed)


""" GETTERS """

func get_tween():
	return $Tween