extends MeshInstance

onready var origin = translation

var offset = Vector3(0, -0.05, 0)
var speed = 0.2

var isToggled = false

var currentBodies = []

signal toggle_on()
signal toggle_off()


func toggle_on():
	# If we are already toggled, stop
	if isToggled:
		return
	
	isToggled = true
	
	# Emit our toggled signal
	emit_signal("toggle_on")
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(self, get_tween(), origin + offset, speed)


func toggle_off():
	# If we are not toggled, stop
	if not isToggled:
		return
	
	isToggled = false
	
	# Emit our toggled signal
	emit_signal("toggle_off")
	
	# Tween from where the door is currently
	Util.tween_to_target_from_current(self, get_tween(), origin, speed)


func update_plate():
	# If there are things on the plate
	if currentBodies.size() > 0:
		# Toggle it on
		toggle_on()
	# Otherwise toggle it off
	else:
		toggle_off()


""" GETTERS """

func get_tween():
	return $Tween


""" SIGNALS """

func _on_Area_body_entered(body):
	currentBodies.append(body)
	
	update_plate()


func _on_Area_body_exited(body):
	currentBodies.erase(body)
	
	update_plate()
