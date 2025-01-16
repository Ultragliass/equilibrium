class_name InventorySlot
extends CenterContainer

var stored_item
var drop_preview: Node
var original_item: Node

func init(WeekdayGrid: GridContainer, columns: int, rows: int):
	var width = WeekdayGrid.size.x / columns
	var height = WeekdayGrid.size.y / rows

	custom_minimum_size = Vector2(width, height)
	mouse_filter = Control.MOUSE_FILTER_PASS

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(width, height)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	Global.dragging_item.connect(_on_dragging_item)

func _can_drop_data(_pos, data):
	if data is CenterContainer and stored_item == null:
		drop_preview.visible = true
		return true
	drop_preview.visible = false
	return false

func _drop_data(_pos, data):
	drop_preview.visible = false
	stored_item = data
	data.reparent(self)
	center_item(data)

func center_item(item):
	item.anchors_preset = Control.PRESET_CENTER
	item.position = (custom_minimum_size - item.custom_minimum_size) / 2

	item.queue_sort()

func _on_mouse_entered():
	if drop_preview == null: return

	drop_preview.mouse_filter = Control.MOUSE_FILTER_PASS

	if get_viewport().gui_is_dragging():
		drop_preview.visible = stored_item == null

func _on_mouse_exited():
	if drop_preview == null: return
	
	drop_preview.visible = false

func _on_dragging_item(item: Node):
	original_item = item
	drop_preview = item.duplicate()
	drop_preview.name = "DropPreview"
	drop_preview.init(item.number, item.width, item.height)
	drop_preview.visible = false
	drop_preview.modulate.a = 0.5
	add_child(drop_preview)

func on_drag_end():
	original_item.modulate.a = 1
	if drop_preview != null:
		drop_preview.queue_free()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		on_drag_end()