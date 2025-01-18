extends CenterContainer

var original_parent

var number: int
var width := 1
var height := 1

func init(item_number: int, item_width: int, item_height: int):
	number = item_number
	width = item_width
	height = item_height
	size = Vector2(Global.cell_size.width * width, Global.cell_size.height * height)

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CursorShape.CURSOR_DRAG

	var color = ColorRect.new()
	color.custom_minimum_size = Vector2(Global.cell_size.width * width, Global.cell_size.height * height)
	color.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(color)

	var text = Label.new()
	text.add_theme_color_override("font_color", Color(0, 0, 0))
	text.text = str(number)
	add_child(text)

func _get_drag_data(_at_position):
	original_parent = get_parent()

	Global.set_drag_item(self)

	var preview = duplicate()
	preview.init(number, width, height)
	
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
