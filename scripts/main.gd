extends Control

const NUMBER_OF_ITEMS_TO_SCATTER = 5
const SCATTER_ITEMS_SCREEN_MARGIN = 10
var scattered_item_positions = []
const ITEM_SCENE = preload("res://scenes/Item.tscn")

func _ready():
	var WeekdayGridManager = $WeekdayGridManager
	WeekdayGridManager.init(Global.WEEKDAY_GRID_SLOTS.rows, Global.WEEKDAY_GRID_SLOTS.columns, Vector2(Global.cell_size.width, Global.cell_size.height))

	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = ITEM_SCENE.instantiate()
		var shape = Global.ITEMS["stone"][randi() % Global.ITEMS["stone"].size()]
		item.init(shape)
		scatter_item(item)
		add_child(item)

	
func scatter_item(item: Control):
	var screen_size = get_viewport_rect().size
	var scatter_position = Vector2()
	var margin = SCATTER_ITEMS_SCREEN_MARGIN

	while true:
		var edge = randi() % 4
		var item_width = item.shape[0].size() * Global.cell_size.width
		var item_height = item.shape.size() * Global.cell_size.height
		
		match edge:
			Global.SCATTER_POSITIONS.TOP: scatter_position = Vector2(
				randf_range(margin, screen_size.x - item_width - margin),
				margin)
			Global.SCATTER_POSITIONS.BOTTOM: scatter_position = Vector2(
				randf_range(margin, screen_size.x - item_width - margin),
				screen_size.y - item_height - margin)
			Global.SCATTER_POSITIONS.LEFT: scatter_position = Vector2(
				margin,
				randf_range(margin, screen_size.y - item_height - margin))
			Global.SCATTER_POSITIONS.RIGHT: scatter_position = Vector2(
				screen_size.x - item_width - margin,
				randf_range(margin, screen_size.y - item_height - margin))

		var is_overlapping = false
		for scattered_item_position in scattered_item_positions:
			if Rect2(scattered_item_position.position, scattered_item_position.size).intersects(Rect2(scatter_position, item.size)):
				is_overlapping = true
				break

		if not is_overlapping:
			item.position = scatter_position
			scattered_item_positions.append({"position": scatter_position, "size": item.size})
			return
