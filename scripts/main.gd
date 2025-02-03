extends Control

const NUMBER_OF_ITEMS_TO_SCATTER: int = 10
const SCATTER_ITEMS_SCREEN_MARGIN: int = 10

var scattered_item_positions: Array = []

@onready var weekday_grid_manager: Control = $WeekdayGridManager
@onready var weekend_grid_manager: Control = $WeekendGridManager
@onready var settings_button: Button = $SettingsButton
@onready var settings_screen = preload("res://scenes/Settings_Screen.tscn")
@onready var item_scene = preload("res://scenes/Item.tscn")

func _ready() -> void:
	weekday_grid_manager.init(
		Global.WEEKDAY_GRID_SLOTS.rows,
		Global.WEEKDAY_GRID_SLOTS.columns,
		Vector2(Global.cell_size.width, Global.cell_size.height)
	)

	weekend_grid_manager.init(
		Global.WEEKEND_GRID_SLOTS.rows,
		Global.WEEKEND_GRID_SLOTS.columns,
		Vector2(Global.cell_size.width, Global.cell_size.height)
	)

	settings_button.connect("pressed", _on_settings_button_pressed)

# Game initialization to be called when pressing start on the main menu
func _start_game():
	Global._play_animations([Global.ANIMATIONS.NEW_STAGE, Global.ANIMATIONS.START_NORMAL_WALK, Global.ANIMATIONS.NORMAL_WALK])
	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = _create_random_item()
		_scatter_item(item, Global.TWEENS.SCALE)
		add_child(item)

# Opens the settings screen on settings button press
func _on_settings_button_pressed():
	add_child(settings_screen.instantiate())

# Creates a new item of a random type and shape
func _create_random_item() -> Control:
	var item = item_scene.instantiate()
	var categories = Global.ITEMS.keys()
	var category = categories[randi() % categories.size()]
	var item_data = Global.ITEMS[category][randi() % Global.ITEMS[category].size()]
	item.init(item_data.shape, item_data.images, category)
	return item

# Helper function to calculate item position based on edge
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

# Helper action to animate item scale
func _animate_item_scale(item: Control) -> void:
	item.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(item, "scale", Vector2.ONE * 0.33, 0)
	tween.tween_interval(0.1)
	tween.tween_property(item, "scale", Vector2.ONE * 0.66, 0)
	tween.tween_interval(0.1)
	tween.tween_property(item, "scale", Vector2.ONE, 0)

# Helper function for item scattering
func _scatter_item(item: Control, animation: int = Global.TWEENS.SCALE) -> void:
	var screen_size := get_viewport_rect().size
	var margin := SCATTER_ITEMS_SCREEN_MARGIN
	var item_size := Vector2(
        item.shape[0].size() * Global.cell_size.width,
        item.shape.size() * Global.cell_size.height
	)
    
	var item_position := _find_valid_position(screen_size, item_size, margin)
	_apply_animation(item, item_position, animation)
    
	scattered_item_positions.append({
        "position": item_position,
        "size": item_size
	})


# Helper function to find a valid position for an item
func _find_valid_position(screen_size: Vector2, item_size: Vector2, margin: int) -> Vector2:
	var max_attempts := 50
	var attempts := 0
	
	while attempts < max_attempts:
		var edge := randi() % 4
		var item_position := _calculate_edge_position(edge, screen_size, item_size, margin)
		
		if not _is_position_overlapping(item_position, item_size):
			return item_position
		attempts += 1
	
	return _calculate_edge_position(randi() % 4, screen_size, item_size, margin)

# Helper function to check if a position is overlapping with other items
func _is_position_overlapping(item_position: Vector2, item_size: Vector2) -> bool:
	for scattered_item in scattered_item_positions:
		if Rect2(scattered_item.position, scattered_item.size).intersects(Rect2(item_position, item_size)):
			return true
	return false

# Helper function to apply animation to an item during creation and drop
func _apply_animation(item: Control, item_position: Vector2, animation: int) -> void:
	match animation:
		Global.TWEENS.SCALE:
			prints("Playing scale animation")
			_animate_item_scale(item)
			item.position = item_position
		Global.TWEENS.SCATTER:
			prints("Playing scatter animation")
			create_tween().tween_property(item, "position", item_position, 0.1)
		_:
			item.position = item_position