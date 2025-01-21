extends Node

func _calculate_drag_item_size():
	var item = Global.drag_item
	
	var item_width = item.shape[0].size() * Global.cell_size.width
	var item_height = item.shape.size() * Global.cell_size.height
	
	return Vector2(item_width / 2, item_height / 2)