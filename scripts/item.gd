extends Control

var shape: Array = []
var category: Global.ITEM_TYPES
var images: Dictionary
var current_rotation: int:
	set(value):
		current_rotation = value % 4
		_setup_image()

func init(item_shape: Array, item_images: Dictionary, item_category: Global.ITEM_TYPES) -> void:
	shape = item_shape
	category = item_category
	images = item_images
	_setup_image()

func _setup_image() -> void:
	for child in get_children():
		child.queue_free()
		
	var image_texture = TextureRect.new()
	image_texture.expand = true
	image_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	# Handle rotation-specific texture and flags
	match current_rotation:
		0:
			image_texture.texture = images.h
			image_texture.flip_h = false
			image_texture.flip_v = false
		1:
			image_texture.texture = images.v
			image_texture.flip_h = false
			image_texture.flip_v = false
		2:
			image_texture.texture = images.h
			image_texture.flip_h = true
			image_texture.flip_v = true
		3:
			image_texture.texture = images.v
			image_texture.flip_h = true
			image_texture.flip_v = true
	
	var item_width = shape[0].size() * Global.cell_size.width
	var item_height = shape.size() * Global.cell_size.height
	
	custom_minimum_size = Vector2(item_width, item_height)
	size = Vector2(item_width, item_height)
	pivot_offset = size / 2
	
	image_texture.custom_minimum_size = size
	image_texture.size = size
	image_texture.pivot_offset = size / 2
	
	add_child(image_texture)

func _get_drag_data(_at_position) -> Control:
	Global.is_dragging = true

	var preview_control = _create_drag_preview()

	set_drag_preview(preview_control)

	mouse_filter = Control.MOUSE_FILTER_PASS
	
	shape = shape.duplicate(true)

	return self

# Helper function to create drag preview
func _create_drag_preview() -> DragPreviewControl:
	var drag_preview = duplicate()
	drag_preview.init(shape, images, category)
	drag_preview.current_rotation = current_rotation
	drag_preview.modulate.a = 0.5
	
	var preview_control = DragPreviewControl.new()
	preview_control.setup(drag_preview)
	preview_control.connect("tree_exiting", func(): Global.is_dragging = false)

	print("Creating drag preview with shape: ", shape)

	Global.drag_preview = drag_preview
	
	return preview_control
