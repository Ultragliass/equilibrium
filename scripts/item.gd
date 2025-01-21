extends Control

var shape: Array = []

func init(item_shape: Array):
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


func _get_drag_data(_at_position):
	Global.set_drag_item(self)

	var drag_preview = duplicate()
	drag_preview.init(shape)
	drag_preview.modulate.a = 0.5
	
	var item_width = shape[0].size() * Global.cell_size.width
	var item_height = shape.size() * Global.cell_size.height
	
	var preview_control = Control.new()
	preview_control.add_child(drag_preview)
	drag_preview.position = -Vector2(item_width/2, item_height/2)

	set_drag_preview(preview_control)
	
	mouse_filter = Control.MOUSE_FILTER_PASS

	return self
