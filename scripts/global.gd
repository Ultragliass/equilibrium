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
	set(item):
		drag_item = item
		emit_signal("dragging_item", item)
	

var cell_size = {
	"width": 100,
	"height": 100
}

var current_rotation = 0
var is_dragging = false

const ITEMS = {
	"iron": [
		[[1]],

		[[1, 1]],

		[[1, 1],
		 [1, 1]],

		[[1, 1],
		 [1, 1],
		 [1, 1]],

		 [[1, 1, 1]],

		 [[1, 1, 1, 1]],

		 [[1, 1, 1, 1, 1]]
	],

	"stone": [
		[[0, 1, 0],
		 [1, 1, 1]],

		[[1, 0],
		 [1, 1],
		 [0, 1]],

		[[1, 1],
		 [1, 1]],

		[[1]],

		[[1],
		 [1],
		 [1]],

		[[0, 1],
		 [1, 1]]
	],

	"earth": [
		[[1, 1],
		 [1, 1]],

		[[0, 1],
		 [1, 1]],

		[[1],
		 [1]],

		[[1]],
	],

	"water": [
		[[1, 1]],
		
		[[1]],
	]
}

func _ready():
	var WeekdayGridManager = get_node("/root/Main/WeekdayGridManager")
	cell_size.width = WeekdayGridManager.size.x / WEEKDAY_GRID_SLOTS.columns
	cell_size.height = WeekdayGridManager.size.y / WEEKDAY_GRID_SLOTS.rows

func rotate_shape(shape: Array) -> Array:
	var rows = shape.size()
	var cols = shape[0].size()
	var new_shape = []
	
	# Initialize new shape array
	for i in range(cols):
		new_shape.append([])
		for _j in range(rows):
			new_shape[i].append(0)
	
	# Perform rotation
	for i in range(rows):
		for j in range(cols):
			new_shape[j][rows - 1 - i] = shape[i][j]
    
	return new_shape
