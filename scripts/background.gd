extends TextureRect

func _can_drop_data(_pos, _data):
    return true

func _drop_data(_pos, data):

    data.init(Global.drag_preview.shape, data.images, data.category)
    data.current_rotation = Global.drag_preview.current_rotation
    
    var target_pos = _calculate_target_position(Global.drag_preview.shape)

    _handle_reparenting(data)
    
    create_tween().tween_property(data, "position", target_pos, 0.1)

    match data.category:
        Global.ITEM_TYPES.IRON:
            Global._play_sfx(Global.SFXs.IRON_PLACE)
        Global.ITEM_TYPES.STONE:
            Global._play_sfx(Global.SFXs.STONE_PLACE)
        Global.ITEM_TYPES.EARTH:
            Global._play_sfx(Global.SFXs.EARTH_PLACE)
        Global.ITEM_TYPES.WATER:
            Global._play_sfx(Global.SFXs.WATER_PLACE)

# Helper function to calculate target position
func _calculate_target_position(shape):
    var width: float = shape[0].size() * Global.cell_size.width / 2
    var height: float = shape.size() * Global.cell_size.height / 2
    return get_global_mouse_position() - Vector2(width, height)

# Helper function to handle reparenting
func _handle_reparenting(data: Control):
    if data.get_parent().name != "Main":
        var grid_manager = data.get_parent()
        grid_manager._remove_item_from_grid(data)
        grid_manager._update_falling_items()
        grid_manager._update_floating_items()
        data.reparent(get_parent())