extends Node

var currentScene = null

const MAIN_MENU = "res://Scenes/MainMenu/MainMenu.tscn"
const LEVEL_1 = "res://Scenes/Level_1/Level_1.tscn"

var loadData = null

signal game_start()
signal new_scene(scene)


func _ready():
	var root = get_tree().get_root()
	
	# Get the first scene to be loaded
	currentScene = root.get_child(root.get_child_count() - 1)
	
	emit_signal("new_scene", currentScene)


func go_to_main_menu():
	go_to_scene(MAIN_MENU)


func go_to_level_1():
	go_to_scene(LEVEL_1)


func load_scene_with_data(path, data):
	# Set the load data
	loadData = data
	
	# Go to the desired scene
	go_to_scene(path)


func go_to_scene(path):
	
	# Clear all data to read and to send
	CommunicationManager.toSend.clear()
	
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	
	call_deferred("_deferred_go_to_scene", path)


func _deferred_go_to_scene(path):
	# Remove all entities from the communication manager
	CommunicationManager.stop_running()
	
	# It is now safe to remove the current scene
	currentScene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	currentScene = s.instance()
	
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(currentScene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(currentScene)
	
	# A new scene has begun
	emit_signal("new_scene", currentScene)
	
	# If the scene is a map
	if currentScene.has_method("is_map"):
		# Then the game is afoot
		emit_signal("game_start")
	
	# If we have load data
	if loadData != null:
		# Use it to load in persistent entities in the map
		currentScene.load_from_data(loadData)
		
		# Clear the load data
		loadData = null



