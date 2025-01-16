extends CenterContainer

var original_parent

var number: int
var width := 1
var height := 1

func init(item_number: int, item_width: int, item_height: int):
	number = item_number
	width = item_width
	height = item_height
	size = Vector2(153.5 * width, 118.2 * height)

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CursorShape.CURSOR_DRAG

	var color = ColorRect.new()
	color.custom_minimum_size = Vector2(153.5 * width, 118.2 * height)
	color.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(color)

	var text = Label.new()
	text.add_theme_color_override("font_color", Color(0, 0, 0))
	text.text = str(number)
	add_child(text)

func _get_drag_data(_at_position):
	original_parent = get_parent()

	if original_parent is InventorySlot:
		original_parent.stored_item = null

	Global.set_drag_item(self)

	var preview = duplicate()
	preview.name = "DragPreview"
	preview.init(number, width, height)

	var wrapper = Control.new()
	wrapper.add_child(preview)
	preview.position = -0.5 * preview.size

	set_drag_preview(wrapper)
	modulate.a = 0.5
    
	return self
