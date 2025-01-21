class_name DragPreviewControl
extends Control

var drag_preview: Control
var original_shape: Array

func _ready():
    set_process_input(true)
    prints("DragPreviewControl initialized")

func setup(preview: Control, shape: Array):
    drag_preview = preview
    original_shape = shape
    add_child(preview)
    _update_preview_position(shape)
    prints("Preview setup completed with shape:", shape)

func _input(event: InputEvent):
    if event.is_action_pressed("rotate"):
        _handle_rotation()

# Updates the preview position based on the given shape
func _update_preview_position(shape: Array) -> void:
    drag_preview.position = -Functions._calculate_drag_item_size(shape)
    prints("Preview position updated:", drag_preview.position)

# Handles the rotation logic when rotation input is received
func _handle_rotation() -> void:
    # Update rotation counter
    Global.current_rotation = (Global.current_rotation + 1) % 4
    prints("Current rotation:", Global.current_rotation)
    
    # Get rotated shape
    var rotated_shape = _get_rotated_shape()
    
    # Update preview with new shape
    drag_preview.init(rotated_shape)
    _update_preview_position(rotated_shape)

# Returns the shape after applying current rotation
func _get_rotated_shape() -> Array:
    var rotated_shape = original_shape
    for i in range(Global.current_rotation):
        rotated_shape = Global.rotate_shape(rotated_shape)
    return rotated_shape