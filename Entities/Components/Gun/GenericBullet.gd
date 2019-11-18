extends "res://Entities/ReprogrammableEntity.gd"

export var speed = 20
export var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


func start(_position: Vector3, _direction: Vector3):
	# Setup position and direction to move in
	self.look_at(_direction, Vector3.UP)
	self.translation = _position
	
	# Start looping
	set_process(true)


func _process(delta):
	var toMove = self.global_transform.basis.z * speed * delta
	move_and_collide(toMove)


func _on_Bullet_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(damage)
		death()


func _on_Bullet_body_entered(body):
	"""Called when we enter the map, or another static object"""
	death()


func _on_Lifetime_timeout():
	"""Explode if we have been alive for too long"""
	death()
