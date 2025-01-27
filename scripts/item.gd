extends Control

var shape: Array = []
var category: Global.ITEM_TYPES

const ITEM_COLORS = {
    Global.ITEM_TYPES.IRON: Color(0.4, 0.4, 0.4),
    Global.ITEM_TYPES.STONE: Color(0.8, 0.8, 0.8),
    Global.ITEM_TYPES.EARTH: Color(0.45, 0.32, 0.17),
    Global.ITEM_TYPES.WATER: Color(0.2, 0.4, 0.8)
}

func init(item_shape: Array, item_category: Global.ITEM_TYPES):
	shape = item_shape
	category = item_category
	_build_shape()

func _build_shape():
	_clear_existing_blocks()
	_create_blocks()

# Helper function to clear existing blocks
func _clear_existing_blocks():
	for child in get_children():
		child.queue_free()

# Helper function to create new blocks
func _create_blocks():
	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var block = _create_block(row, col)
				add_child(block)

# Helper function to create a single block
func _create_block(row: int, col: int) -> ColorRect:
	var block = ColorRect.new()
	block.color = ITEM_COLORS[category]
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
	
	return self

# Helper function to set up drag state
func _setup_drag_state():
	Global.drag_item = self
	Global.is_dragging = true
	Global.current_rotation = 0

# Helper function to create drag preview
func _create_drag_preview() -> DragPreviewControl:
	var drag_preview = duplicate()
	drag_preview.init(shape, category)
	drag_preview.modulate.a = 0.5
	
	var preview_control = DragPreviewControl.new()
	preview_control.setup(drag_preview, shape)
	preview_control.connect("tree_exiting", func(): Global.is_dragging = false)
	
	return preview_control
