extends Node


# The client we send messages with
var client

# Called when the node enters the scene tree for the first time.
func _ready():
	client = get_tree().get_root().get_node("Scene/TCPClient")
	
	
	
