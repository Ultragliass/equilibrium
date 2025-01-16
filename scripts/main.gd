extends Control

const WEEKDAY_GRID_SLOTS = {"rows": 5, "columns": 4}
const NUMBER_OF_ITEMS_TO_SCATTER = 8
const SCATTER_ITEMS_SCREEN_MARGIN = 10
const SCATTERED_ITEMS_POSITIONS = []
const ITEM_SCENE = preload("res://scenes/Item.tscn")

func _ready():
	for i in range(WEEKDAY_GRID_SLOTS.columns * WEEKDAY_GRID_SLOTS.rows):
		var slot := InventorySlot.new()
		slot.init(%WeekdayGrid, WEEKDAY_GRID_SLOTS.columns, WEEKDAY_GRID_SLOTS.rows)
		%WeekdayGrid.add_child(slot)

	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = ITEM_SCENE.instantiate()
		item.init(j, 1, 1)
		scatter_item(item)
		add_child(item)

	var one_by_two = ITEM_SCENE.instantiate()
	one_by_two.init(8, 1, 2)
	scatter_item(one_by_two)
	add_child(one_by_two)

	var two_by_one = ITEM_SCENE.instantiate()
	two_by_one.init(9, 2, 1)
	scatter_item(two_by_one)
	add_child(two_by_one)
	
func scatter_item(item: CenterContainer):
	var screen_size = get_viewport_rect().size
	var scatter_position = Vector2()
	
	while SCATTERED_ITEMS_POSITIONS.size() < NUMBER_OF_ITEMS_TO_SCATTER:
		var edge = randi() % 4
		match edge:
			0: scatter_position = Vector2(randf_range(0, screen_size.x - item.size.x), SCATTER_ITEMS_SCREEN_MARGIN)
			1: scatter_position = Vector2(randf_range(0, screen_size.x - item.size.x), screen_size.y - item.size.y - SCATTER_ITEMS_SCREEN_MARGIN)
			2: scatter_position = Vector2(SCATTER_ITEMS_SCREEN_MARGIN, randf_range(0, screen_size.y - item.size.y))
			3: scatter_position = Vector2(screen_size.x - item.size.x - SCATTER_ITEMS_SCREEN_MARGIN, randf_range(0, screen_size.y - item.size.y))

		var is_overlapping = false

		for scattered_item_position in SCATTERED_ITEMS_POSITIONS:
			if Rect2(scattered_item_position.position, scattered_item_position.size).intersects(Rect2(scatter_position, item.size)):
				is_overlapping = true
				break

		if not is_overlapping:
			item.position = scatter_position
			SCATTERED_ITEMS_POSITIONS.append({"position": scatter_position, "size": item.size})
			return
			
		item.position = scatter_position
