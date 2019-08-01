extends Node

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
	EDIT_CODE = 1
}

const ERROR_CODE = {
	NO_ATTACHMENT = 1
}

var MASK_BIT_TO_NAME = {}
var NAME_TO_BIT_MASK = {}

var LAYER = {
	UNITS = "Units",
	TERRAIN = "Terrain"
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