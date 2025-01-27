extends TextureRect

func _can_drop_data(_pos, _data):
    return true

func _drop_data(_pos, data):
    # Apply rotation to the shape based on Global.current_rotation
    var rotated_shape = _get_rotated_shape(data.shape)
    
    # Update the data with rotated shape
    data.init(rotated_shape, data.category)
    
    # Calculate target position for the dropped item
    var target_pos = _calculate_target_position(rotated_shape)

    _handle_reparenting(data)
    
    # Set final position and reset rotation
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

    Global.current_rotation = 0

# Helper function to handle shape rotation
func _get_rotated_shape(original_shape):
    var shape = original_shape
    for i in range(Global.current_rotation):
        shape = Global._rotate_shape(shape)
    return shape

# Helper function to calculate target position
func _calculate_target_position(shape):
    return get_global_mouse_position() - Functions._calculate_drag_item_size(shape)

# Helper function to handle reparenting
func _handle_reparenting(data: Control):
    if data.get_parent().name != "Main":
        var grid_manager = data.get_parent()
        grid_manager._remove_item_from_grid(data)
        grid_manager._update_falling_items()
        grid_manager._update_floating_items()
        data.reparent(get_parent())