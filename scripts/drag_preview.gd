class_name DragPreviewControl
extends Control

var drag_preview: Control
var original_shape: Array

func _ready():
    set_process_input(true)
    prints("DragPreviewControl initialized")

func setup(preview: Control):
    drag_preview = preview
    original_shape = preview.shape.duplicate(true)
    add_child(preview)
    _update_preview_position()
    prints("Preview setup completed with shape:", preview.shape)

func _input(event: InputEvent):
    if event.is_action_pressed("rotate"):
        var new_rotation = (drag_preview.current_rotation + 1) % 4
        var rotated_shape = _get_rotated_shape(new_rotation)
        drag_preview.current_rotation = new_rotation
        drag_preview.init(rotated_shape, drag_preview.images, drag_preview.category)
        _update_preview_position()

# Updates the preview position based on the given shape
func _update_preview_position():
    if drag_preview:
        drag_preview.position = -drag_preview.size / 2

# Returns the shape after applying current rotation
func _get_rotated_shape(_rotation: int = -1) -> Array:
    original_shape = _rotate_shape_once(original_shape)

    return original_shape

func _rotate_shape_once(shape: Array) -> Array:
    var rows = shape.size()
    var cols = shape[0].size()
    
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
