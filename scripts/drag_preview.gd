class_name DragPreviewControl
extends Control

var drag_preview: Control
var original_shape: Array

func _ready():
    set_process_input(true)

func setup(preview: Control, shape: Array):
    drag_preview = preview
    original_shape = shape
    add_child(preview)
    preview.position = -Functions._calculate_drag_item_size(shape)

func _input(event: InputEvent):
    if event.is_action_pressed("rotate"):
        Global.current_rotation = (Global.current_rotation + 1) % 4
        var rotated_shape = original_shape
        for i in range(Global.current_rotation):
            rotated_shape = Global.rotate_shape(rotated_shape)
        drag_preview.init(rotated_shape)
        # Calculate new center based on rotated dimensions
        drag_preview.position = -Functions._calculate_drag_item_size(rotated_shape)