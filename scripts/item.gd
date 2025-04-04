class_name Item extends Control

var shape: Array = []
var images: Dictionary
var category: Global.ITEM_TYPES
var score: Dictionary
var description: String
var task_data: Dictionary
var shape_type: String
var current_rotation: int:
	set(value):
		current_rotation = value % 4
		_setup_image()

func init(item_shape: Array,
		item_images: Dictionary,
		item_category: Global.ITEM_TYPES,
		item_score: Dictionary,
		item_description: String,
		item_task_data: Dictionary = {"is_unique": false},
		item_shape_type: String = ""
		) -> void:

	shape = item_shape
	images = item_images
	category = item_category
	score = item_score
	description = item_description
	task_data = item_task_data
	shape_type = item_shape_type
	z_index = 5

	var dimensions = str(shape[0].size()) + "x" + str(shape.size()) if shape_type.is_empty() else shape_type
	var scores = "\n" + "קנס: " + str(score.penalty) + "\nבונוס: " + str(score.bonus)

	tooltip_text = description + "\n" + dimensions + scores

	_setup_image()

# Helper function to create the item image
func _setup_image() -> void:
	for child in get_children():
		child.queue_free()
		
	var image_texture = _create_image_texture()
	_apply_rotation_transforms(image_texture)
	_setup_size_and_pivot(image_texture)
	add_child(image_texture)

# Helper function to initialize the texture
func _create_image_texture() -> TextureRect:
	var texture = TextureRect.new()
	texture.expand = true
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	if task_data.is_unique:
		texture.modulate = Color(1, 0.7, 0.7, 1)
		
	return texture

# Helper function to setup the texture rotation
func _apply_rotation_transforms(texture: TextureRect) -> void:
	match current_rotation:
		0:
			texture.texture = images.h
			texture.flip_h = false
			texture.flip_v = false
		1:
			texture.texture = images.v
			texture.flip_h = false
			texture.flip_v = false
		2:
			texture.texture = images.h
			texture.flip_h = true
			texture.flip_v = true
		3:
			texture.texture = images.v
			texture.flip_h = true
			texture.flip_v = true

# Helper function to setup the texture size and offset
func _setup_size_and_pivot(texture: TextureRect) -> void:
	var item_width = shape[0].size() * Global.cell_size.width
	var item_height = shape.size() * Global.cell_size.height
	var item_size = Vector2(item_width, item_height)
	
	custom_minimum_size = item_size
	size = item_size
	pivot_offset = size / 2
	
	texture.custom_minimum_size = size
	texture.size = size
	texture.pivot_offset = size / 2

func _get_drag_data(_at_position: Vector2) -> Control:
	Global.is_dragging = true

	var preview_control = _create_drag_preview()

	set_drag_preview(preview_control)

	mouse_filter = Control.MOUSE_FILTER_PASS
	
	shape = shape.duplicate(true)

	return self

# Helper function to create drag preview
func _create_drag_preview() -> DragPreviewControl:
	var drag_preview = duplicate()
	drag_preview.init(shape, images, category, score, description, task_data, shape_type)
	drag_preview.current_rotation = current_rotation
	drag_preview.modulate.a = 0.5
	
	var preview_control = DragPreviewControl.new()
	preview_control.setup(drag_preview)
	preview_control.connect("tree_exiting", func(): Global.is_dragging = false)
	preview_control.z_index = 5

	print("Creating drag preview with shape: ", shape)

	Global.drag_preview = drag_preview
	
	return preview_control
