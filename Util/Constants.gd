extends Node

const GENERIC_CODE_DIR = "res://Player/OriginalCode/"
const PLAYER_CODE_DIR = "user://Code/"

const LEVEL_1_CODE_DIR = "res://Scenes/Level_1/Level_1_Code/"

const TYPE_TO_TYPE_ID = {
	Robot = 0
}

const ATTACHMENT_TYPES = {
	WHEELS = "WHEELS",
	ARM = "ARM",
	GUN = "GUN",
	SENSOR = "SENSOR"
}

const ATTACHMENT_POSITIONS = {
	SELF = "SELF",
	HEAD = "HEAD",
	BASE = "BASE",
	ARM_ONE = "ARM_ONE",
	ARM_TWO = "ARM_TWO",
	FRONT = "FRONT",
	BACK = "BACK"
}

const INSPECT_ITEMS = {
	EDIT_CODE = 1,
	VIEW_OUTPUT = 2
}

const ERROR_CODE = {
	NO_ATTACHMENT = 1
}

var MASK_BIT_TO_NAME = {}
var NAME_TO_BIT_MASK = {}

const LAYER = {
	UNITS = "Units",
	TERRAIN = "Terrain"
}

const MESSAGE_TYPE = {
	NORMAL = 0,
	ERROR = 1
}


func _ready():
	setup_physics_masks()


func setup_physics_masks():
	for i in range(1, 21):
	
		var layerName = ProjectSettings.get_setting(
			str("layer_names/2d_physics/layer_", i))
	
		if not layerName: 
			layerName = str("Layer ", i)
		
		MASK_BIT_TO_NAME[pow(2, i-1)] = layerName
		NAME_TO_BIT_MASK[layerName] = pow(2, i-1)