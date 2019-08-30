extends Node

""" PLAYER """

const CLICK_RAY_LENGTH = 1000


""" IDE AND CODE """

const GENERIC_CODE_DIR = "res://Player/OriginalCode/"
const PLAYER_CODE_DIR = "user://Code/"

const LEVEL_1_CODE_DIR = "res://Scenes/Level_1/Level_1_Code/"

const HIDE_ROWS = "// HIDE ROWS:" # Put number at end to hide that many rows
const DO_NOT_EDIT_START = '// DO NOT EDIT BELOW THIS LINE'
const DO_NOT_EDIT_END = '// DO NOT EDIT ABOVE THIS LINE'
const PERMISSIONS_TAG = "//// *PERMISSION"
const PERMISSIONS_TAG_END = "*END_PERMISSION"
const READ_ONLY = "r"
const WRITE = "w"
const NO_ACCESS = "n"

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

""" SAVING INFORMATION/PATHS """

const GAME_DATA = "user://game_data/"

const IDE_DIRECTORY = GAME_DATA + "ide_metadata/"
const PLAYER_SAVE_DIR = GAME_DATA + "saves/"

const IDE_RECT_FILE = IDE_DIRECTORY + "ide_rect"
const OUTPUT_RECT_FILE = IDE_DIRECTORY + "output_rect"
const IDE_METADATA_FILE = IDE_DIRECTORY + "ide_metadata"

const SAVE_FILE_TYPE = ".save"

""" LAYERS """

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