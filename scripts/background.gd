extends TextureRect


func _can_drop_data(_pos, _data):
	return true

func _drop_data(_pos, data):
	data.position = get_global_mouse_position()
	if (data.get_parent().name != "Main"):
		data.reparent(get_parent())
		data.position = get_global_mouse_position()