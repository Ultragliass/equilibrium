extends Node

# Calculates the size of a draggable item based on its shape matrix
# Returns the half-size as Vector2 for centering purposes
func _calculate_drag_item_size(shape: Array) -> Vector2:
    # Calculate dimensions based on shape array and cell size
    var width: float = shape[0].size() * Global.cell_size.width
    var height: float = shape.size() * Global.cell_size.height
    
    print("Drag item dimensions - Width: ", width, " Height: ", height)
    
    return Vector2(width / 2, height / 2)