extends Control

const NUMBER_OF_ITEMS_TO_SCATTER: int = 10
const SCATTER_ITEMS_SCREEN_MARGIN: int = 10

var scattered_item_positions: Array[Dictionary] = []
var health: int
var init_grid_y_position: float
var dirt_items: Array[Item] = []
var doll_initial_position: Vector2
var mouse_blocker: Control

@onready var weekday_grid_manager: Control = $WeekdayGridManager
@onready var weekend_grid_manager: Control = $WeekendGridManager
@onready var settings_button: Button = $MenuButton
@onready var finish_button: Button = $FinishButton
@onready var close_instructions: Button = $Instructions/Close
@onready var calendar: TextureRect = $Calendar
@onready var progress_box: HBoxContainer = $ProgressBox
@onready var credits_screen: TextureRect = $CreditsScreen
@onready var settings_screen = preload("res://scenes/Settings_Screen.tscn")

func _ready() -> void:
	await get_tree().process_frame

	Global.init($BackgroundMusicPlayer, $Background/PlayerAnimations, $Background/ScreenAnimations)

	_setup_mouse_blocker()
	
	doll_initial_position = $Calendar/SmallDoll.position

	health = Global.INITIAL_HEALTH
	
	settings_button.connect("pressed", _on_settings_button_pressed)
	finish_button.connect("pressed", on_finish_button_pressed)
	close_instructions.connect("pressed", _on_close_instructions_pressed)

func _setup_mouse_blocker() -> void:
	mouse_blocker = Control.new()
	mouse_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.add_child(mouse_blocker)
	add_child(canvas_layer)

func _on_close_instructions_pressed() -> void:
	$Calendar/WeekLabel.text = "שבוע מספר " + str(Global.week + 1)
	$Calendar/HealthLabel.text = "נקודות נפש " + str(health)
	await create_tween().tween_property($Instructions, "modulate", Color(1, 1, 1, 0), 0.5).finished
	_start_game()

func _update_ui_labels() -> void:
	$ProgressBox/ClassicLabel.text = "מטלת קלאסית - " + str(_get_completion_amount(Global.tasks_1)) + "/6"
	$ProgressBox/StopMotionLabel.text = "מטלת סטופ מושן - " + str(_get_completion_amount(Global.tasks_2)) + "/6"
	$ProgressBox/ThreeDLabel.text = "מטלת תלת - " + str(_get_completion_amount(Global.tasks_3)) + "/7"
	$Calendar/WeekLabel.text = "שבוע מספר " + str(Global.week + 1)
	$Calendar/HealthLabel.text = "נקודות נפש " + str(health)

func _animate_calendar_and_doll() -> Tween:
	var tween = create_tween()
	var doll: TextureRect = $Calendar/SmallDoll
	tween.tween_property(doll, "position", Vector2(doll.position.x - (0 if Global.week == 0 else 365), doll.position.y), 2)
	tween.tween_property(calendar, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): Global._play_animations([Global.ANIMATIONS.IDLE]))
	return tween

func _initialize_grid_managers() -> void:
	weekday_grid_manager.init(
		Global.WEEKDAY_GRID_SLOTS.rows,
		Global.WEEKDAY_GRID_SLOTS.columns,
		Vector2(Global.cell_size.width, Global.cell_size.height)
	)
	if not init_grid_y_position:
		init_grid_y_position = weekday_grid_manager.position.y
	
	weekend_grid_manager.init(
		Global.WEEKEND_GRID_SLOTS.rows,
		Global.WEEKEND_GRID_SLOTS.columns,
		Vector2(Global.cell_size.width, Global.cell_size.height)
	)

func _apply_grid_animation() -> void:
	if health <= 5:
		Global._play_animations([Global.ANIMATIONS.NEW_STAGE, Global.ANIMATIONS.SAD_WALK])
		weekday_grid_manager.position = Vector2(weekday_grid_manager.position.x, init_grid_y_position + 40)
		weekend_grid_manager.position = Vector2(weekend_grid_manager.position.x, init_grid_y_position + 40)
	else:
		Global._play_animations([Global.ANIMATIONS.NEW_STAGE, Global.ANIMATIONS.START_NORMAL_WALK, Global.ANIMATIONS.NORMAL_WALK])

func _spawn_tasks() -> void:
	var tasks = _get_initial_tasks()
	for task in tasks:
		var item = _convert_task_to_item(task)
		_scatter_item(item, Global.TWEENS.SCALE)
		add_child(item)

func _spawn_random_items() -> void:
	for j in range(NUMBER_OF_ITEMS_TO_SCATTER):
		var item = _create_random_item()
		if item.category == Global.ITEM_TYPES.EARTH:
			add_child(item)
			item.position = Vector2.ZERO
			item.scale = Vector2(0, 0)
			dirt_items.append(item)
			_place_item_in_random_grid_position(item)
		else:
			_scatter_item(item, Global.TWEENS.SCALE)
			add_child(item)

func _animate_dirt_items() -> void:
	await get_tree().create_timer(3).timeout
	for dirt_item in dirt_items:
		create_tween().tween_property(dirt_item, "scale", Vector2(1, 1), 0.2)
		dirt_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dirt_item.z_index = 1

func _start_game() -> void:
	if Global.low_health:
		health = 1

	dirt_items.clear()
	
	mouse_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	weekday_grid_manager.mouse_filter = Control.MOUSE_FILTER_STOP
	weekend_grid_manager.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_update_ui_labels()
	
	var tween = _animate_calendar_and_doll()
	await tween.finished
	
	$Calendar.hide()
	finish_button.disabled = false
	
	_initialize_grid_managers()
	_apply_grid_animation()
	
	_spawn_tasks()
	_spawn_random_items()
	await _animate_dirt_items()
	mouse_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _get_completion_amount(task_list: Dictionary) -> int:
	var completed = 0
	for num in task_list.keys():
		if task_list[num].completed:
			completed += 1
	return completed

func _get_uncompleted(task_list: Dictionary, list_number: int) -> Array:
	var result = []
	var task_nums = task_list.keys()
	task_nums.sort()
	
	for num in task_nums:
		if result.size() >= 2:
			break
		if not task_list[num].completed:
			var task = task_list[num].duplicate()
			task["task_list"] = list_number
			task["task_number"] = num
			result.append(task)
	return result

func _get_initial_tasks() -> Array:
	var tasks = []
	tasks.append_array(_get_uncompleted(Global.tasks_1, 1))
	tasks.append_array(_get_uncompleted(Global.tasks_2, 2))
	tasks.append_array(_get_uncompleted(Global.tasks_3, 3))
	return tasks

func _convert_task_to_item(task: Dictionary) -> Control:
	var item = Item.new()
	var matching_items = Global.ITEMS[task.type].filter(func(_item):
		return _item.difficulty == task.difficulty)
	var item_data = matching_items[randi() % matching_items.size()]
	
	var final_item_data = item_data.duplicate()
	final_item_data["description"] = task.description
	
	var task_data = {
		"is_unique": true,
		"task_list": task.get("task_list", 1),
		"task_number": task.get("task_number", 1),
	}
	
	item.init(final_item_data.shape,
		final_item_data.images,
		task.type,
		final_item_data.score,
		final_item_data.description,
		task_data,
		final_item_data.shape_type)
	return item

func _on_settings_button_pressed() -> void:
	add_child(settings_screen.instantiate())

func on_finish_button_pressed() -> void:
	finish_button.disabled = true
	mouse_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	
	await Global.player_animations.animation_looped
	
	if health > 5:
		await Global._play_animations([Global.ANIMATIONS.STOP_NORMAL_WALK])
	else:
		Global.player_animations.stop()
	
	var background_items = get_children().filter(func(child):
		return child.has_method("_setup_image"))
	var grid_items = (weekday_grid_manager.get_children() + weekend_grid_manager.get_children()).filter(func(child):
		return child.has_method("_setup_image"))
	
	var fade_data = await _fade_out_items(background_items, grid_items)
	
	for item in grid_items + background_items:
		item.queue_free()
	
	scattered_item_positions.clear()
	
	await _calculate_new_health(fade_data["bonus"], fade_data["penalty"])
	
	if health <= 0:
		await Global._play_animations([Global.ANIMATIONS.DEATH])
		_handle_reset()
	else:
		_continue_stage()

func _update_task_completion_for_item(grid_item: Item) -> void:
	if grid_item.task_data.is_unique:
		var task_list = grid_item.task_data.task_list
		var task_num = grid_item.task_data.task_number
		match task_list:
			1: Global.tasks_1[task_num].completed = true
			2: Global.tasks_2[task_num].completed = true
			3: Global.tasks_3[task_num].completed = true

func _fade_out_items(background_items: Array[Node], grid_items: Array[Node]) -> Dictionary:
	var bonus = 0
	var penalty = 0
	var tween = create_tween()
	tween.set_parallel()
	
	for background_item in background_items:
		penalty += background_item.score.penalty
		tween.tween_property(background_item, "modulate", Color(0, 0, 0, 0), 0.5)
	
	for grid_item in grid_items:
		_update_task_completion_for_item(grid_item)
		bonus += grid_item.score.bonus
		tween.tween_property(grid_item, "modulate", Color(0, 0, 0, 0), 0.5)
	
	await tween.finished
	return {"bonus": bonus, "penalty": penalty}

func _calculate_new_health(bonus: int, penalty: int) -> void:
	Global.week += 1
	if Global.week == 4:
		if _get_completion_amount(Global.tasks_1) != 6 or _get_completion_amount(Global.tasks_2) != 6 or _get_completion_amount(Global.tasks_3) != 7:
			health = 0
		else:
			await get_tree().create_timer(0.5).timeout
			credits_screen.show()
			health = 0
	else:
		health += bonus - penalty
	
	if Global.godmode and Global.week < 4:
		health = Global.INITIAL_HEALTH
	
	if Global.low_health and Global.week < 4:
		health = 1

func _handle_reset() -> void:
	Global.reset()

	$Calendar/SmallDoll.position = doll_initial_position
	
	$TitleScreen.show()
	$TitleScreen.modulate = Color(1, 1, 1, 1)
	$TitleScreen/StartGameButton.disabled = false
	
	$Instructions.show()
	$Instructions.modulate = Color(1, 1, 1, 1)
	
	$Calendar.show()
	$Calendar.modulate = Color(1, 1, 1, 1)
	
	health = Global.INITIAL_HEALTH

	mouse_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

	weekday_grid_manager.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weekend_grid_manager.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	weekday_grid_manager.position = Vector2(weekday_grid_manager.position.x, init_grid_y_position)
	weekend_grid_manager.position = Vector2(weekend_grid_manager.position.x, init_grid_y_position)
	
	$Calendar/WeekLabel.text = "שבוע מספר " + str(Global.week + 1)
	$Calendar/HealthLabel.text = "נקודות נפש " + str(health)

func _continue_stage() -> void:
	Global._play_animations([Global.ANIMATIONS.NEW_STAGE, Global.ANIMATIONS.IDLE], true)
	$Calendar/WeekLabel.text = "שבוע מספר " + str(Global.week + 1)
	$Calendar/HealthLabel.text = "נקודות נפש " + str(health)
	
	var tween2 = create_tween()
	tween2.tween_interval(1)
	$Calendar.show()
	tween2.tween_property(calendar, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween2.finished
	_start_game()

func _create_random_item() -> Control:
	var item = Item.new()
	var categories = Global.ITEMS.keys()
	var category = categories[randi() % categories.size()]
	var valid_items = Global.ITEMS[category].filter(func(_item_data):
		return not (category == Global.ITEM_TYPES.IRON and _item_data.difficulty == Global.DIFFICULTIES.HARD))
	var item_data = valid_items[randi() % valid_items.size()]
	var description = _get_description_for_item(category, item_data.difficulty)
	var final_item_data = item_data.duplicate()
	final_item_data["description"] = description
	
	item.init(final_item_data.shape, final_item_data.images, category, final_item_data.score, final_item_data.description, {"is_unique": false}, final_item_data.shape_type)
			  
	return item

func _place_item_in_random_grid_position(item: Item) -> void:
	var grids = [weekday_grid_manager, weekend_grid_manager]
	var target_grid = grids[randi() % grids.size()]
	
	var max_attempts = 50
	var attempts = 0
	
	while attempts < max_attempts:
		var grid_x = randi() % target_grid.columns
		var grid_y = randi() % target_grid.rows
		
		if target_grid._can_place_item_at(grid_x, grid_y, item):
			var placement = target_grid._place_item_at(grid_x, grid_y, item)
			if placement.is_placed:
				item.reparent(target_grid)
				item.position = Vector2(grid_x, grid_y) * target_grid.cell_size
				return
		attempts += 1

func _get_description_for_item(category: Global.ITEM_TYPES, difficulty: Global.DIFFICULTIES) -> String:
	match category:
		Global.ITEM_TYPES.WATER:
			var descriptions = Global.WATER_TASK_DESCRIPTIONS
			return descriptions[randi() % descriptions.size()]
		Global.ITEM_TYPES.EARTH:
			var descriptions = Global.EARTH_TASK_DESCRIPTIONS
			return descriptions[randi() % descriptions.size()]
		Global.ITEM_TYPES.IRON, Global.ITEM_TYPES.STONE:
			if difficulty != Global.DIFFICULTIES.HARD:
				var descriptions = Global.EASY_AND_MEDIUM_METAL_AND_STONE
				return descriptions[randi() % descriptions.size()]
	return ""

func _calculate_edge_position(screen_size: Vector2, item_size: Vector2, margin: int) -> Vector2:
	return Vector2(randf_range(margin, screen_size.x - item_size.x - margin), screen_size.y - item_size.y - margin)

func _animate_item_scale(item: Item, item_position: Vector2) -> void:
	item.position = Vector2(item_position.x, -500)
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(item, "position", item_position, (float(item.category) + 5) / 10)

func _scatter_item(item: Item, tween: Global.TWEENS = Global.TWEENS.SCALE) -> void:
	var screen_size := get_viewport_rect().size
	var margin := SCATTER_ITEMS_SCREEN_MARGIN
	var item_size := Vector2(
		item.shape[0].size() * Global.cell_size.width,
		item.shape.size() * Global.cell_size.height
	)
	
	var item_position := _find_valid_position(screen_size, item_size, margin)
	_apply_animation(item, item_position, tween)
	
	scattered_item_positions.append({
		"position": item_position,
		"size": item_size
	})

func _find_valid_position(screen_size: Vector2, item_size: Vector2, margin: int) -> Vector2:
	var max_attempts := 50
	var attempts := 0
	
	while attempts < max_attempts:
		var item_position := _calculate_edge_position(screen_size, item_size, margin)
		if not _is_position_overlapping(item_position, item_size):
			return item_position
		attempts += 1
	
	return _calculate_edge_position(screen_size, item_size, margin)

func _is_position_overlapping(item_position: Vector2, item_size: Vector2) -> bool:
	for scattered_item in scattered_item_positions:
		if Rect2(scattered_item.position, scattered_item.size).intersects(Rect2(item_position, item_size)):
			return true
	return false

func _apply_animation(item: Item, item_position: Vector2, tween: Global.TWEENS) -> void:
	match tween:
		Global.TWEENS.SCALE:
			_animate_item_scale(item, item_position)
		Global.TWEENS.SCATTER:
			create_tween().tween_property(item, "position", item_position, 0.1)
		_:
			item.position = item_position