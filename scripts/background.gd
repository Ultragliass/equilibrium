extends Control

func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_pos: Vector2, data: Variant) -> void:
	data.init(Global.drag_preview.shape, data.images, data.category, data.score if data.category != Global.ITEM_TYPES.EARTH else {"bonus": 0, "penalty": 0}, data.description, data.task_data, data.shape_type)
	data.current_rotation = Global.drag_preview.current_rotation
	data.z_index = 5
	
	var target_pos = _calculate_target_position(Global.drag_preview.shape)
	_handle_reparenting(data)
	create_tween().tween_property(data, "position", target_pos, 0.1)

	_play_placement_sfx(data.category)

# Helper function to play the correct SFX when placing an item
func _play_placement_sfx(category: Global.ITEM_TYPES) -> void:
	match category:
		Global.ITEM_TYPES.IRON:
			Global._play_sfx(Global.SFXs.IRON_PLACE)
		Global.ITEM_TYPES.STONE:
			Global._play_sfx(Global.SFXs.STONE_PLACE)
		Global.ITEM_TYPES.EARTH:
			Global._play_sfx(Global.SFXs.EARTH_PLACE)
		Global.ITEM_TYPES.WATER:
			Global._play_sfx(Global.SFXs.WATER_PLACE)

# Helper function to calculate target position
func _calculate_target_position(shape: Array) -> Vector2:
	var width: float = shape[0].size() * Global.cell_size.width / 2
	var height: float = shape.size() * Global.cell_size.height / 2
	return get_global_mouse_position() - Vector2(width, height)

# Helper function to handle reparenting of items to the main play area
func _handle_reparenting(data: Control) -> void:
	if data.get_parent().name != "Main":
		var grid_manager: Control = data.get_parent()
		grid_manager._remove_item_from_grid(data)
		grid_manager._update_falling_items()
		grid_manager._update_floating_items()
		data.reparent(get_parent())