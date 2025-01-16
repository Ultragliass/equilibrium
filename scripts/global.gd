extends Node

signal dragging_item(item)

var drag_item: Node

func set_drag_item(item: Node):
	drag_item = item
	emit_signal("dragging_item", item)

func get_drag_item():
	return drag_item