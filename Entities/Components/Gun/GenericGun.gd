extends "res://Entities/Components/Component.gd"

const ORDER_TYPES = {
	SHOOT = 0,
	RELOAD = 1
}

export(PackedScene) var Bullet
export var ammoMax = 1
export var ammoCurrent = 1


func _process(delta):
	parse_orders()


func parse_orders():
	# If we have orders and we aren't executing an order, consume an order
	while len(orders) > 0:
		# Manager the orders
		if orders[0].type == ORDER_TYPES.SHOOT:
			shoot()
		if orders[0].type == ORDER_TYPES.RELOAD:
			reload()
		
		orders.remove(0)


func shoot():
	"""Shoot the bullet in the direction the gun is facing.
	"""
	# Create the bullet and add it to our current scene
	var b = Bullet.instance()
	SceneManager.currentScene.add_child(b)
	
	# Start the bullet off at the tip
	var tip = get_gun_tip()
	b.start(tip.global_transform.origin, -tip.global_transform.basis.y)


func reload():
	"""Reload the gun to max ammo
	"""
	pass


""" GETTERS """

func get_gun_tip():
	return $Joint/Inner/Outer

