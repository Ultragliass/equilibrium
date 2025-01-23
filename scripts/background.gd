extends TextureRect

func _can_drop_data(_pos, _data):
    return true

func _drop_data(_pos, data):
    # Apply rotation to the shape based on Global.current_rotation
    var rotated_shape = _get_rotated_shape(data.shape)
    print("Rotated shape: ", rotated_shape)
    
    # Update the data with rotated shape
    data.init(rotated_shape, data.category)
    
    # Calculate target position for the dropped item
    var target_pos = _calculate_target_position(rotated_shape)
    print("Target position: ", target_pos)
    
    # Handle reparenting if needed
    _handle_reparenting(data)
    
    # Set final position and reset rotation
    data.position = target_pos
    Global.current_rotation = 0

# Helper function to handle shape rotation
func _get_rotated_shape(original_shape):
    var shape = original_shape
    for i in range(Global.current_rotation):
        shape = Global.rotate_shape(shape)
    return shape

# Helper function to calculate target position
func _calculate_target_position(shape):
    return get_global_mouse_position() - Functions._calculate_drag_item_size(shape)

# Helper function to handle reparenting
func _handle_reparenting(data):
    if data.get_parent().name != "Main":
        print("Reparenting item from grid") # Debug print
        var grid_manager = $"/root/Main/WeekdayGridManager"
        grid_manager.remove_item_from_grid(data)
        data.reparent(get_parent())