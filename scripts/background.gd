extends TextureRect

func _can_drop_data(_pos, _data):
    return true

func _drop_data(_pos, data):
    # First rotate the shape
    var rotated_shape = data.shape
    for i in range(Global.current_rotation):
        rotated_shape = Global.rotate_shape(rotated_shape)
    
    # Update item with rotated shape
    data.shape = rotated_shape
    data.init(rotated_shape)
    
    var target_pos = get_global_mouse_position() - Functions._calculate_drag_item_size(rotated_shape)
    
    if data.get_parent().name != "Main":
        var grid_manager = $"/root/Main/WeekdayGridManager"
        grid_manager.remove_item_from_grid(data)
        data.reparent(get_parent())
    
    data.position = target_pos
    Global.current_rotation = 0