extends Node

signal dragging_item(item)

enum SCATTER_POSITIONS {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

const WEEKDAY_GRID_SLOTS = {"rows": 5, "columns": 4}

var drag_item: Node:
# Setter for drag_item that emits signal
	set(item):
		drag_item = item
		emit_signal("dragging_item", item)
		prints("Dragging item:", str(item.name) if item else "None")

# Grid cell size. Is overwritten on initialization
var cell_size = {
	"width": 0,
	"height": 0
}

var current_rotation = 0
var is_dragging = false

# Item shapes configuration
const ITEMS = {
	"iron": [
		[[1]],
		[[1, 1]],
		[[1, 1], [1, 1]],
		[[1, 1], [1, 1], [1, 1]],
		[[1, 1, 1]],
		[[1, 1, 1, 1]],
		[[1, 1, 1, 1, 1]]
	],
	"stone": [
		[[0, 1, 0], [1, 1, 1]],
		[[1, 0], [1, 1], [0, 1]],
		[[1, 1], [1, 1]],
		[[1]],
		[[1], [1], [1]],
		[[0, 1], [1, 1]]
	],
	"earth": [
		[[1, 1], [1, 1]],
		[[0, 1], [1, 1]],
		[[1], [1]],
		[[1]],
	],
	"water": [
		[[1, 1]],
		[[1]],
	]
}

func _ready():
	_initialize_cell_size()
	prints("Cell size initialized:", cell_size)

# Cell size initialization
func _initialize_cell_size() -> void:
	var WeekdayGridManager = get_node("/root/Main/WeekdayGridManager")
	cell_size.width = WeekdayGridManager.size.x / WEEKDAY_GRID_SLOTS.columns
	cell_size.height = WeekdayGridManager.size.y / WEEKDAY_GRID_SLOTS.rows

# Rotates shape array 90 degrees clockwise
func rotate_shape(shape: Array) -> Array:
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
