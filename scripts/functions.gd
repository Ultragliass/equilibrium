extends Node

func _calculate_drag_item_size(shape: Array) -> Vector2:
    var width = shape[0].size() * Global.cell_size.width
    var height = shape.size() * Global.cell_size.height
    return Vector2(width / 2, height / 2)