extends Control

var shape: Array = []

func init(item_shape: Array):
	shape = item_shape
	print("Initializing item with shape: ", shape)
	_build_shape()

func _build_shape():
	_clear_existing_blocks()
	_create_blocks()

# Helper function to clear existing blocks
func _clear_existing_blocks():
	for child in get_children():
		child.queue_free()
	print("Cleared existing blocks")

# Helper function to create new blocks
func _create_blocks():
	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var block = _create_block(row, col)
				add_child(block)
	print("Created new blocks for shape")

# Helper function to create a single block
func _create_block(row: int, col: int) -> ColorRect:
	var block = ColorRect.new()
	block.color = Color(0.8, 0.8, 0.8)
	block.custom_minimum_size = Vector2(Global.cell_size.width, Global.cell_size.height)
	block.position = Vector2(col, row) * Vector2(Global.cell_size.width, Global.cell_size.height)
	block.mouse_filter = Control.MOUSE_FILTER_PASS
	return block

func _get_drag_data(_at_position):
	# Set up global drag state
	_setup_drag_state()
	
	# Create and setup preview
	var preview_control = _create_drag_preview()
	
	set_drag_preview(preview_control)
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	print("Started dragging item")
	return self

# Helper function to set up drag state
func _setup_drag_state():
	Global.drag_item = self
	Global.is_dragging = true
	Global.current_rotation = 0

# Helper function to create drag preview
func _create_drag_preview() -> DragPreviewControl:
	var drag_preview = duplicate()
	drag_preview.init(shape)
	drag_preview.modulate.a = 0.5
	
	var preview_control = DragPreviewControl.new()
	preview_control.setup(drag_preview, shape)
	preview_control.connect("tree_exiting", func(): Global.is_dragging = false)
	
	return preview_control
