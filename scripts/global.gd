extends Node

enum SFXs {
    IRON_PLACE,
    IRON_DROP,
    WATER_PLACE,
    WATER_FLOAT,
    STONE_PLACE,
    EARTH_PLACE,
}

enum SCATTER_POSITIONS {
    TOP,
    BOTTOM,
    LEFT,
    RIGHT
}

enum ANIMATIONS {
    SCALE,
	ROTATE,
    SCATTER
}

enum ITEM_TYPES {
    IRON,
    STONE,
    EARTH,
    WATER
}

const SFX: Dictionary = {
	SFXs.IRON_PLACE: preload("res://assets/sounds/sfx/iron_place.ogg"),
	SFXs.IRON_DROP: preload("res://assets/sounds/sfx/iron_drop.ogg"),
	SFXs.WATER_PLACE: preload("res://assets/sounds/sfx/water_place.ogg"),
	SFXs.WATER_FLOAT: preload("res://assets/sounds/sfx/water_float.ogg"),
	SFXs.STONE_PLACE: preload("res://assets/sounds/sfx/stone_place.ogg"),
	SFXs.EARTH_PLACE: preload("res://assets/sounds/sfx/earth_place.ogg"),
}

const ITEMS: Dictionary = {
    ITEM_TYPES.IRON: [
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/iron1x1-H.png"),
			"v": preload("res://assets/objects/iron1x1-V.png")
		}},
        {"shape": [[1, 1]], "images": {
			"h": preload("res://assets/objects/iron1x2-H.png"),
			"v": preload("res://assets/objects/iron1x2-V.png")
		}},
        {"shape": [[1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/iron2x2-H.png"),
			"v": preload("res://assets/objects/iron2x2-V.png")
		}},
        {"shape": [[1, 1], [1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/iron2x3-H.png"),
			"v": preload("res://assets/objects/iron2x3-V.png")
		}},
        {"shape": [[1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron1x3-H.png"),
			"v": preload("res://assets/objects/iron1x3-V.png")
		}},
        {"shape": [[1, 1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron1x4-H.png"),
			"v": preload("res://assets/objects/iron1x4-V.png")
		}},
        {"shape": [[1, 1, 1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron1x5-H.png"),
			"v": preload("res://assets/objects/iron1x5-V.png")
		}},
    ],
    ITEM_TYPES.STONE: [
        {"shape": [[0, 1, 0], [1, 1, 1]], "images": {
			"h": preload("res://assets/objects/stone_T-H.png"),
			"v": preload("res://assets/objects/stone_T-V.png")
		}},
        {"shape": [[1, 0], [1, 1], [0, 1]], "images": {
			"h": null,
			"v": null
		}},
        {"shape": [[1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/stone2x2-H.png"),
			"v": preload("res://assets/objects/stone2x2-V.png")
		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/stone1x1-H.png"),
			"v": preload("res://assets/objects/stone1x1-V.png")
		}},
        {"shape": [[1], [1], [1]], "images": {
			"h": preload("res://assets/objects/stone1x3-H.png"),
			"v": preload("res://assets/objects/stone1x3-V.png")
		}},
        {"shape": [[0, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/stone_L-H.png"),
			"v": preload("res://assets/objects/stone_L-V.png")
		}},
    ],
    ITEM_TYPES.EARTH: [
        {"shape": [[1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/earth2x2-H.png"),
			"v": preload("res://assets/objects/earth2x2-V.png")
		}},
        {"shape": [[0, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/earth_L-H.png"),
			"v": preload("res://assets/objects/earth_L-V.png")
		}},
        {"shape": [[1], [1]], "images": {
			"h": preload("res://assets/objects/earth1x2-H.png"),
			"v": preload("res://assets/objects/earth1x2-V.png")

		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/earth1x1-H.png"),
			"v": preload("res://assets/objects/earth1x1-V.png")
		}},
    ],
    ITEM_TYPES.WATER: [
        {"shape": [[1, 1]], "images": {
			"h": preload("res://assets/objects/water1x2-H.png"),
			"v": preload("res://assets/objects/water1x2-V.png")
		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/water1x1-H.png"),
			"v": preload("res://assets/objects/water1x1-V.png")
		}},
    ]
}

const WEEKDAY_GRID_SLOTS: Dictionary = {"rows": 5, "columns": 4}

var is_dragging = false
var drag_preview: Node
var cell_size = {
	"width": 0,
	"height": 0
}

@onready var background_music_player = get_node("/root/Main/BackgroundMusicPlayer")

func _ready() -> void:
	_initialize_cell_size()
	background_music_player.play()
	prints("Cell size initialized:", cell_size)

# Helper function to initialize the cell sizes
func _initialize_cell_size() -> void:
	var weekday_grid_manager: Control = get_node("/root/Main/WeekdayGridManager")
	cell_size.width = weekday_grid_manager.size.x / WEEKDAY_GRID_SLOTS.columns
	cell_size.height = weekday_grid_manager.size.y / WEEKDAY_GRID_SLOTS.rows

# Helper function to create empty shape array
func _create_empty_shape(rows: int, cols: int) -> Array:
	var new_shape = []
	for i in range(rows):
		new_shape.append([])
		for _j in range(cols):
			new_shape[i].append(0)
	return new_shape

# Helper function to play SFX
func _play_sfx(type: SFXs) -> void:
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = SFX[type]
	player.connect("finished", func(): player.queue_free())

	add_child(player)

	player.play()
