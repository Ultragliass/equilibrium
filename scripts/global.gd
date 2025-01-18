extends Node

signal dragging_item(item)

const WEEKDAY_GRID_SLOTS = {"rows": 5, "columns": 4}

var drag_item: Node
var cell_size = {
	"width": 100,
	"height": 100
}


func _ready():
	var WeekdayGridManager = get_node("/root/Main/WeekdayGridManager")
	cell_size.width = WeekdayGridManager.size.x / WEEKDAY_GRID_SLOTS.columns
	cell_size.height = WeekdayGridManager.size.y / WEEKDAY_GRID_SLOTS.rows

func set_drag_item(item: Node):
	drag_item = item
	emit_signal("dragging_item", item)

func get_drag_item():
	return drag_item