extends Control

const NUMBER_OF_ITEMS_TO_SCATTER = 5
const SCATTER_ITEMS_SCREEN_MARGIN = 10
const ITEM_SCENE = preload("res://scenes/Item.tscn")

var scattered_item_positions = []

func _ready():
	var WeekdayGridManager = $WeekdayGridManager
	WeekdayGridManager.init(Global.WEEKDAY_GRID_SLOTS.rows, Global.WEEKDAY_GRID_SLOTS.columns, Vector2(Global.cell_size.width, Global.cell_size.height))
	
	scatter_multiple_items()

# Creates and scatters multiple items
func scatter_multiple_items():
	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = create_random_item()
		scatter_item(item)
		add_child(item)
		print("Scattered item %d at position: %s" % [j, item.position])

# Creates a new item with random shape
func create_random_item() -> Control:
	var item = ITEM_SCENE.instantiate()
	var categories = Global.ITEMS.keys()
	var category = categories[randi() % categories.size()]
	var shape = Global.ITEMS[category][randi() % Global.ITEMS[category].size()]
	item.init(shape, category)
	return item

# Calculate item position based on edge
func calculate_edge_position(edge: int, screen_size: Vector2, item_size: Vector2, margin: int) -> Vector2:
	var item_width = item_size.x
	var item_height = item_size.y
	
	match edge:
		Global.SCATTER_POSITIONS.TOP:
			return Vector2(randf_range(margin, screen_size.x - item_width - margin), margin)
		Global.SCATTER_POSITIONS.BOTTOM:
			return Vector2(randf_range(margin, screen_size.x - item_width - margin), screen_size.y - item_height - margin)
		Global.SCATTER_POSITIONS.LEFT:
			return Vector2(margin, randf_range(margin, screen_size.y - item_height - margin))
		Global.SCATTER_POSITIONS.RIGHT:
			return Vector2(screen_size.x - item_width - margin, randf_range(margin, screen_size.y - item_height - margin))
	return Vector2.ZERO

# Check if position overlaps with existing items
func is_position_overlapping(item_position: Vector2, item_size: Vector2) -> bool:
	for scattered_item in scattered_item_positions:
		if Rect2(scattered_item.position, scattered_item.size).intersects(Rect2(item_position, item_size)):
			return true
	return false
	
func scatter_item(item: Control):
	var screen_size = get_viewport_rect().size
	var margin = SCATTER_ITEMS_SCREEN_MARGIN
	var item_size = Vector2(item.shape[0].size() * Global.cell_size.width, item.shape.size() * Global.cell_size.height)
	
	print("Attempting to scatter item of size: ", item_size)
	
	while true:
		var edge = randi() % 4
		var scatter_position = calculate_edge_position(edge, screen_size, item_size, margin)
		
		if not is_position_overlapping(scatter_position, item.size):
			item.position = scatter_position
			scattered_item_positions.append({"position": scatter_position, "size": item.size})
			print("Successfully placed item at edge: ", edge)
			return
		
		print("Position overlapped, trying again...")
