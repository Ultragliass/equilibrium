extends Node

signal dragging_item(item)

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
		[[1]],
		[[1, 1]],
		[[1, 1], [1, 1]],
		[[1, 1], [1, 1], [1, 1]],
		[[1, 1, 1]],
		[[1, 1, 1, 1]],
		[[1, 1, 1, 1, 1]]
	],
	ITEM_TYPES.STONE: [
		[[0, 1, 0], [1, 1, 1]],
		[[1, 0], [1, 1], [0, 1]],
		[[1, 1], [1, 1]],
		[[1]],
		[[1], [1], [1]],
		[[0, 1], [1, 1]]
	],
	ITEM_TYPES.EARTH: [
		[[1, 1], [1, 1]],
		[[0, 1], [1, 1]],
		[[1], [1]],
		[[1]],
	],
	ITEM_TYPES.WATER: [
		[[1, 1]],
		[[1]],
	]
}

const WEEKDAY_GRID_SLOTS = {"rows": 5, "columns": 4}

var drag_item: Node:
# Setter for drag_item that emits a signal
	set(item):
		drag_item = item
		emit_signal("dragging_item", item)
		prints("Dragging item:", str(item.name) if item else "None")

# Grid cell size - calculated on initialization
var cell_size = {
	"width": 0,
	"height": 0
}

# Tracker for item rotation
var current_rotation = 0

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


# Rotates shape array 90 degrees clockwise
func _rotate_shape(shape: Array) -> Array:
	var rows = shape.size()
	var cols = shape[0].size()
	
	# Create empty rotated shape array
	var new_shape = _create_empty_shape(cols, rows)
	
	# Perform rotation
	for i in range(rows):
		for j in range(cols):
			new_shape[j][rows - 1 - i] = shape[i][j]
	
	prints("Shape rotated:", new_shape)
	return new_shape

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
