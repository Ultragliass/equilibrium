class_name DragPreviewControl
extends Control

var drag_preview: Control
var original_shape: Array

func _ready() -> void:
    set_process_input(true)

func setup(preview: Control) -> void:
    drag_preview = preview
    original_shape = preview.shape.duplicate(true)
    add_child(preview)
    _update_preview_position()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("rotate"):
        var new_rotation: int = (drag_preview.current_rotation + 1) % 4
        var rotated_shape = _get_rotated_shape()
        drag_preview.current_rotation = new_rotation
        drag_preview.init(rotated_shape, drag_preview.images, drag_preview.category)
        _update_preview_position()

# Helper function to update preview position
func _update_preview_position() -> void:
    if drag_preview:
        drag_preview.position = -drag_preview.size / 2

# Helper function to handle rotation
func _get_rotated_shape() -> Array:
    original_shape = _rotate_shape_once(original_shape)

    print("Shape rotated: ", original_shape)

    return original_shape

# Helper function to rotate shape
func _rotate_shape_once(shape: Array) -> Array:
    var rows = shape.size()
    var cols: int = shape[0].size()
    
    var rotated = []
    for i in range(cols):
        var row = []
        for _j in range(rows):
            row.append(0)
        rotated.append(row)
    
    for i in range(rows):
        for j in range(cols):
            rotated[j][rows - 1 - i] = shape[i][j]
    
    return rotated
