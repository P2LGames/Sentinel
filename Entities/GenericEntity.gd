extends KinematicBody

export var healthMax: float = 100
export var healthCurrent: float = 100
export var selectable = true
export var invulnerable = false
export var isDead = false

func take_damage(damage: float):
	# If we are invulnerable, stop
	if invulnerable:
		return
	
	# Handle taking damage
	healthCurrent -= damage
	if healthCurrent < 0:
		death()


func death():
	if isDead:
		return
	
	isDead = true
	
	call_deferred("queue_free")


""" ENTITY INTERACTION """

func is_selectable():
	return selectable


func _select():
	pass


func _deselect():
	pass
