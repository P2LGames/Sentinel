extends "res://Entities/Components/Component.gd"

export var isPlugablePath = ""

func _ready():
	pass


func set_robot(robot, position: int):
	# Set the robot and our attachment position
	.set_robot(robot, position)
	
	# We also want to add a behavior to the robot
	var behavior = load(isPlugablePath)
	robot.add_child(behavior.instance())
	