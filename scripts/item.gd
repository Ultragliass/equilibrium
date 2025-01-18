extends Control

var original_parent
var shape: Array = []

var number: int
var width := 1
var height := 1

func init(item_number: int, item_shape: Array):
	number = item_number
	shape = item_shape
	build_shape()

func build_shape():
	for child in get_children():
		child.queue_free()

	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var block = ColorRect.new()
				block.color = Color(0.8, 0.8, 0.8)
				block.custom_minimum_size = Vector2(Global.cell_size.width, Global.cell_size.height)
				block.position = Vector2(col, row) * Vector2(Global.cell_size.width, Global.cell_size.height)
				block.mouse_filter = Control.MOUSE_FILTER_PASS
				add_child(block)

	var label = Label.new()
	label.text = str(number)
	label.add_theme_color_override("font_color", Color(0, 0, 0))
	label.size_flags_horizontal = Control.SIZE_FILL
	label.size_flags_vertical = Control.SIZE_FILL
	add_child(label)

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CursorShape.CURSOR_DRAG

	for child in get_children():
		child.queue_free()

	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var cell = ColorRect.new()
				cell.color = Color(0.8, 0.8, 0.8)
				cell.size_flags_horizontal = Control.SIZE_FILL
				cell.size_flags_vertical = Control.SIZE_FILL
				cell.custom_minimum_size = Vector2(Global.cell_size.width, Global.cell_size.height)
				cell.position = Vector2(col, row) * Vector2(Global.cell_size.width, Global.cell_size.height)
				cell.mouse_filter = Control.MOUSE_FILTER_PASS
				add_child(cell)

	var text = Label.new()
	text.text = str(number)
	text.add_theme_color_override("font_color", Color(0, 0, 0))
	text.size_flags_horizontal = Control.SIZE_FILL
	text.size_flags_vertical = Control.SIZE_FILL
	add_child(text)


func _get_drag_data(_at_position):
	original_parent = get_parent()
	Global.set_drag_item(self)

	var preview = duplicate()
	preview.init(number, shape)

	var wrapper = Control.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
	wrapper.add_child(preview)
	preview.position = -0.5 * preview.size
	preview.modulate.a = 0.5

	set_drag_preview(wrapper)
	mouse_filter = Control.MOUSE_FILTER_PASS
	return self


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_STOP
