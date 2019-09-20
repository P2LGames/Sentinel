extends "res://Entities/Components/Component.gd"

const ORDER_TYPES = {
	PLUG_IN = 0,
	RECOMPILE = 1
}

var targetsInArea = []

func _ready():
	pass


func _process(delta):
	parse_orders()


func parse_orders():
	# If we have orders and we aren't executing an order, consume an order
	while len(orders) > 0:
		# If this is a scan order
		if orders[0].type == ORDER_TYPES.SCAN:
			plug_in()
		# If this is a get map order
		elif orders[0].type == ORDER_TYPES.GET_MAP:
			recompile()
		
		orders.remove(0)


func plug_in():
	"""
	Gets the first entity in our area, call it E.
	Sets the target of the Player to E.
	Gets the code of E.
	Set the IDEs code to that code.
	Popup the IDE.
	"""
	pass


func recompile():
	pass


""" SIGNALS """

func _on_Area_body_entered(body):
	targetsInArea.append(body)


func _on_Area_body_exited(body):
	targetsInArea.erase(body)
