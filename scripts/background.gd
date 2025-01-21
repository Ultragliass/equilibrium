extends TextureRect

func _can_drop_data(_pos, _data):
	return true

func _drop_data(_pos, data):
	data.position = get_global_mouse_position() - 0.5 * data.size
	
	if (data.get_parent().name != "Main"):
		var grid_manager = $"/root/Main/WeekdayGridManager"
		grid_manager.remove_item_from_grid(data)
		data.reparent(get_parent())
		data.position = get_global_mouse_position() - 0.5 * data.size