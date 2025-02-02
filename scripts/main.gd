extends Control

const NUMBER_OF_ITEMS_TO_SCATTER = 10
const SCATTER_ITEMS_SCREEN_MARGIN = 10

var scattered_item_positions = []

@onready var weekday_grid_manager: Control = $WeekdayGridManager
@onready var settings_screen = preload("res://scenes/Settings_Screen.tscn")
@onready var item_scene = preload("res://scenes/Item.tscn")
@onready var settings_button: Button = $SettingsButton

func _ready():
	weekday_grid_manager.init(Global.WEEKDAY_GRID_SLOTS.rows, Global.WEEKDAY_GRID_SLOTS.columns, Vector2(Global.cell_size.width, Global.cell_size.height))
	settings_button.connect("pressed", _on_settings_button_pressed)

# Creates and scatters multiple items
func _start_game():
	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = _create_random_item()
		_scatter_item(item, Global.ANIMATIONS.SCALE)
		add_child(item)

func _on_settings_button_pressed():
	add_child(settings_screen.instantiate())

# Creates a new item with random shape
func _create_random_item() -> Control:
	var item = item_scene.instantiate()
	var categories = Global.ITEMS.keys()
	var category = categories[randi() % categories.size()]
	var item_data = Global.ITEMS[category][randi() % Global.ITEMS[category].size()]
	item.init(item_data.shape, item_data.images, category)
	return item

# Calculate item position based on edge
func _calculate_edge_position(edge: int, screen_size: Vector2, item_size: Vector2, margin: int) -> Vector2:
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
func _is_position_overlapping(item_position: Vector2, item_size: Vector2) -> bool:
	for scattered_item in scattered_item_positions:
		if Rect2(scattered_item.position, scattered_item.size).intersects(Rect2(item_position, item_size)):
			return true
	return false
	
func _animate_item_scale(item: Control) -> void:
	item.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(item, "scale", Vector2.ONE * 0.33, 0)
	tween.tween_interval(0.1) # Pause
	tween.tween_property(item, "scale", Vector2.ONE * 0.66, 0)
	tween.tween_interval(0.1) # Pause
	tween.tween_property(item, "scale", Vector2.ONE, 0)

func _scatter_item(item: Control, animation: Global.ANIMATIONS = Global.ANIMATIONS.SCALE) -> void:
	var screen_size = get_viewport_rect().size
	var margin = SCATTER_ITEMS_SCREEN_MARGIN
	var item_size = Vector2(
		item.shape[0].size() * Global.cell_size.width,
		item.shape.size() * Global.cell_size.height
	)
	
	var max_attempts = 50 # Prevent infinite loop
	var attempts = 0
	var last_position = Vector2.ZERO
		
	while attempts < max_attempts:
		var edge = randi() % 4
		var scatter_position = _calculate_edge_position(edge, screen_size, item_size, margin)
		last_position = scatter_position
		
		if not _is_position_overlapping(scatter_position, item_size):
			scattered_item_positions.append({
				"position": scatter_position,
				"size": item_size
			})

			if animation == Global.ANIMATIONS.SCALE:
				print("Playing scale animation")
				_animate_item_scale(item)

			if animation == Global.ANIMATIONS.SCATTER:
				print("Playing scatter animation")
				create_tween().tween_property(item, "position", scatter_position, 0.1)
			else:
				item.position = scatter_position
				
			return
			
		attempts += 1
	
	# If we couldn't find a non-overlapping position, use the last tried position
	print("Warning: Could not find non-overlapping position after ", max_attempts, " attempts")

	if animation == Global.ANIMATIONS.SCALE:
		print("Playing scale animation")
		_animate_item_scale(item)

	if animation == Global.ANIMATIONS.SCATTER:
		print("Playing scatter animation")
		create_tween().tween_property(item, "position", last_position, 0.1)
	else:
		item.position = last_position

	scattered_item_positions.append({
		"position": last_position,
		"size": item_size
	})
