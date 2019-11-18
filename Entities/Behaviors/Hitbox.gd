extends Area


func _ready():
	if not get_parent().has_method("take_damage"):
		print("ERROR: Parent of hitbox must have the method \"take_damage\"")


func take_damage(damage: float):
	get_parent().take_damage(damage)
