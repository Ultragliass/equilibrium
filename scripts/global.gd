extends Node

# Item SFX types
enum SFXs {
	IRON_PLACE,
	IRON_DROP,
	WATER_PLACE,
	WATER_FLOAT,
	STONE_PLACE,
	EARTH_PLACE,
}

# Item scatter options
enum SCATTER_POSITIONS {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

# Item animation types
enum ANIMATIONS {
	SCALE,
	ROTATE,
	SCATTER
}

# Item type declarations
enum ITEM_TYPES {
	IRON,
	STONE,
	EARTH,
	WATER
}

const SFX = {
	SFXs.IRON_PLACE: preload("res://assets/sounds/sfx/iron_place.ogg"),
	SFXs.IRON_DROP: preload("res://assets/sounds/sfx/iron_drop.ogg"),
	SFXs.WATER_PLACE: preload("res://assets/sounds/sfx/water_place.ogg"),
	SFXs.WATER_FLOAT: preload("res://assets/sounds/sfx/water_float.ogg"),
	SFXs.STONE_PLACE: preload("res://assets/sounds/sfx/stone_place.ogg"),
	SFXs.EARTH_PLACE: preload("res://assets/sounds/sfx/earth_place.ogg"),
}

# Item shapes configuration
const ITEMS = {
    ITEM_TYPES.IRON: [
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1], [1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
		}},
        {"shape": [[1, 1, 1, 1, 1]], "images": {
			"h": preload("res://assets/objects/iron-H.jpg"),
			"v": preload("res://assets/objects/iron-V.jpg")
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
			"h": preload("res://assets/objects/stone-H.jpg"),
			"v": preload("res://assets/objects/stone-V.jpg")
		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/stone-H.jpg"),
			"v": preload("res://assets/objects/stone-V.jpg")
		}},
        {"shape": [[1], [1], [1]], "images": {
			"h": preload("res://assets/objects/stone-H.jpg"),
			"v": preload("res://assets/objects/stone-V.jpg")
		}},
        {"shape": [[0, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/stone_L-H.png"),
			"v": preload("res://assets/objects/stone_L-V.png")
		}},
    ],
    ITEM_TYPES.EARTH: [
        {"shape": [[1, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/earth-H.jpg"),
			"v": preload("res://assets/objects/earth-V.jpg")
		}},
        {"shape": [[0, 1], [1, 1]], "images": {
			"h": preload("res://assets/objects/earth_L-H.png"),
			"v": preload("res://assets/objects/earth_L-V.png")
		}},
        {"shape": [[1], [1]], "images": {
			"h": preload("res://assets/objects/earth-H.jpg"),
			"v": preload("res://assets/objects/earth-V.jpg")
		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/earth-H.jpg"),
			"v": preload("res://assets/objects/earth-V.jpg")
		}},
    ],
    ITEM_TYPES.WATER: [
        {"shape": [[1, 1]], "images": {
			"h": preload("res://assets/objects/water-H.jpg"),
			"v": preload("res://assets/objects/water-V.jpg")
		}},
        {"shape": [[1]], "images": {
			"h": preload("res://assets/objects/water-H.jpg"),
			"v": preload("res://assets/objects/water-V.jpg")
		}},
    ]
}

const WEEKDAY_GRID_SLOTS = {"rows": 5, "columns": 4}

var drag_preview: Node

# Grid cell size - calculated on initialization
var cell_size = {
	"width": 0,
	"height": 0
}

# Global variable to track dragging state
var is_dragging = false

@onready var background_music_player = get_node("/root/Main/BackgroundMusicPlayer")

func _ready():
	_initialize_cell_size()
	print(background_music_player)
	background_music_player.play()
	prints("Cell size initialized:", cell_size)

# Cell size initialization
func _initialize_cell_size() -> void:
	var weekday_grid_manager = get_node("/root/Main/WeekdayGridManager")
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

func _play_sfx(type: SFXs) -> void:
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = SFX[type]
	player.connect("finished", func(): player.queue_free())

	add_child(player)

	player.play()
