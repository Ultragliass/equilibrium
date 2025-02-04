extends Control

var grid = []
var cell_size = Vector2(100, 100)
var rows: int
var columns: int

var drop_preview: Node = null
var last_preview_pos: Vector2 = Vector2.ZERO
var last_preview_rotation: int = 0
var dragging_item: Node = null

func _ready() -> void:
	set_process_input(true)

func init(grid_rows: int, grid_columns: int, grid_cell_size: Vector2) -> void:
	dragging_item = null
	rows = grid_rows
	columns = grid_columns
	cell_size = grid_cell_size
	mouse_exited.connect(_on_mouse_exited)

	print(self.name, " - Grid Initialized: Rows=", rows, ", Columns=", columns)
	
	_initialize_empty_grid()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate") and Global.is_dragging and drop_preview:
		_update_drop_preview()

# Helper function to initialize an empty grid 
func _initialize_empty_grid() -> void:
	grid.resize(rows)

	for i in range(rows):
		grid[i] = []
		grid[i].resize(columns)
		for j in range(columns):
			grid[i][j] = null

func _drop_data(_pos: Vector2, data: Variant) -> void:
	data.init(Global.drag_preview.shape, data.images, data.category, data.score if data.category != Global.ITEM_TYPES.EARTH else {"bonus": 0, "penalty": 0}, data.description, data.task_data, data.shape_type)
	data.current_rotation = Global.drag_preview.current_rotation
	data.z_index = 1

	_remove_item_from_grid(data)
	_remove_drop_preview()

	var grid_coords = _get_grid_coordinates(get_global_mouse_position())

	var item_parent = data.get_parent()

	if item_parent != self:
		if item_parent.has_method("_remove_item_from_grid"):
			item_parent._remove_item_from_grid(data)

		data.reparent(self)

	var placement_data = _place_item_at(grid_coords.x, grid_coords.y, data)

	if placement_data.is_placed:
		create_tween().tween_property(data, "position", grid_coords * cell_size, 0.1)
		
		match data.category:
			Global.ITEM_TYPES.IRON:
				Global._play_sfx(Global.SFXs.IRON_PLACE)
			Global.ITEM_TYPES.STONE:
				Global._play_sfx(Global.SFXs.STONE_PLACE)
			Global.ITEM_TYPES.EARTH:
				Global._play_sfx(Global.SFXs.EARTH_PLACE)
			Global.ITEM_TYPES.WATER:
				Global._play_sfx(Global.SFXs.WATER_PLACE)

		await get_tree().create_timer(0.1).timeout

		_update_falling_items()
		_update_floating_items()

	dragging_item = null
	Global.is_dragging = false

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	var grid_coords = _get_grid_coordinates(get_global_mouse_position())
	dragging_item = data

	var temp_item = data.duplicate()
	temp_item.shape = Global.drag_preview.shape

	var can_place = _can_place_item_at(grid_coords.x, grid_coords.y, temp_item)
	temp_item.queue_free()

	if can_place:
		_show_drop_preview(grid_coords, Global.drag_preview.shape)
		return true

	_remove_drop_preview()
	return false

# Initialize and show drop preview
func _show_drop_preview(grid_coords: Vector2, shape: Array) -> void:
	if not drop_preview:
		_create_drop_preview()

	var safe_coords = Vector2(
		clamp(grid_coords.x, 0, columns - 1),
		clamp(grid_coords.y, 0, rows - 1)
	)

	if last_preview_pos != safe_coords or last_preview_rotation != Global.drag_preview.current_rotation:
		_update_preview_transform(safe_coords, Global.drag_preview.shape)

# Update positions of items that should fall
func _update_falling_items() -> void:
	var something_fell = true
	var did_item_fall = false

	while something_fell:
		something_fell = false
		for row in range(rows - 1, -1, -1):
			for col in range(columns):
				var item = grid[row][col]
				if item != null and item.category == Global.ITEM_TYPES.IRON:
					var item_start_x = _find_item_start_x(item, row, col)
					if col == item_start_x:
						var did_fall = _make_item_fall(item, item_start_x, row)

						if not did_item_fall:
							did_item_fall = did_fall

						something_fell = something_fell or did_fall

	if did_item_fall:
		Global._play_sfx(Global.SFXs.IRON_DROP)

# Update positions of items that should float
func _update_floating_items() -> void:
	var something_floated = true
	var did_item_float = false

	while something_floated:
		something_floated = false
		var processed_items = []
		for row in range(rows):
			for col in range(columns):
				var item = grid[row][col]
				if item != null and item.category == Global.ITEM_TYPES.WATER and not item in processed_items:
					processed_items.append(item)
					var item_start_x = _find_item_start_x(item, row, col)
					if col == item_start_x:
						var did_float = _make_item_float(item, item_start_x, row)
						if not did_item_float:
							did_item_float = did_float
						something_floated = something_floated or did_float

	if did_item_float:
		Global._play_sfx(Global.SFXs.WATER_FLOAT)

# Helper function to update drop preview
func _update_drop_preview() -> void:
	if drop_preview and Global.drag_preview:
		var grid_coords = _get_grid_coordinates(get_global_mouse_position())
		_show_drop_preview(grid_coords, Global.drag_preview.shape)

# Helper function to place an item on the grid
func _place_item_at(grid_x: int, grid_y: int, item: Node) -> Dictionary:
	if not _can_place_item_at(grid_x, grid_y, item):
		print(self.name, " - Failed to place item at", grid_x, ",", grid_y)
		return {"is_placed": false, "grid_coords": 0, "grid_y": 0}

	_remove_item_from_grid(item)

	for row in range(item.shape.size()):
		for col in range(item.shape[row].size()):
			if item.shape[row][col] == 1:
				grid[grid_y + row][grid_x + col] = item
				print(self.name, " - Successfully placed item at", grid_x + col, ",", grid_y + row)

	return {"is_placed": true, "grid_x": grid_x, "grid_y": grid_y}

# Helper function to check if an item can be placed at a given grid position
func _can_place_item_at(grid_x: int, grid_y: int, item: Control) -> bool:
	var shape = item.shape
	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var cell_x = grid_x + col
				var cell_y = grid_y + row

				if not _is_within_bounds(cell_x, cell_y):
					print(self.name, " - Cannot place item - out of bounds at", cell_x, ",", cell_y)
					return false

				if grid[cell_y][cell_x] != null and grid[cell_y][cell_x] != dragging_item:
					print(self.name, " - Cannot place item - space occupied at", cell_x, ",", cell_y)
					return false

	return true

# Helper function to remove an item from the grid
func _remove_item_from_grid(item: Node) -> void:
	for row in range(rows):
		for col in range(columns):
			if grid[row][col] == item:
				grid[row][col] = null
				print(self.name, " - Removed item from", col, ",", row)

# Helper function to make an item fall to its lowest possible position
func _make_item_fall(item: Node, start_x: int, start_y: int) -> bool:
	var final_y = start_y
	var iron_items = []

	for row in range(rows):
		for col in range(columns):
			var cell_item = grid[row][col]
			if cell_item != null and cell_item != item and cell_item.category == Global.ITEM_TYPES.IRON:
				if not cell_item in iron_items:
					iron_items.append({
						"item": cell_item,
						"start_x": _find_item_start_x(cell_item, row, col),
						"y": row,
						"shape": cell_item.shape
					})

	while final_y < rows - item.shape.size():
		var next_y = final_y + 1
		var blocked = false
		var items_at_level = []

		for shape_row in range(item.shape.size()):
			for shape_col in range(item.shape[0].size()):
				if item.shape[shape_row][shape_col] == 1:
					var check_x = start_x + shape_col
					var check_y = next_y + shape_row

					if check_y >= rows:
						blocked = true
						break

					var under_iron = false
					for iron_data in iron_items:
						var iron_item = iron_data.item
						var iron_x = iron_data.start_x
						var iron_y = iron_data.y

						if iron_y < check_y:
							var relative_x = check_x - iron_x
							if relative_x >= 0 and relative_x < iron_item.shape[0].size():
								for iron_row in range(iron_item.shape.size()):
									if iron_item.shape[iron_row][relative_x] == 1:
										under_iron = true
										break

					var cell_item = grid[check_y][check_x]
					if cell_item != null and cell_item != item:
						if cell_item.category == Global.ITEM_TYPES.IRON:
							blocked = true
							break
						elif not under_iron and not items_at_level.has(cell_item):
							items_at_level.append(cell_item)

			if blocked:
				break

		if blocked:
			break

		for pop_item in items_at_level:
			_pop_item_to_background(pop_item)

		final_y = next_y

	if final_y != start_y:
		_remove_item_from_old_position(item, start_x, start_y)
		_place_item_in_new_position(item, start_x, final_y)
		return true

	return false

# Make an item float upwards
func _make_item_float(item: Node, start_x: int, start_y: int) -> bool:
	if start_y == 0:
		return false
	
	var final_y = start_y
	while final_y > 0:
		var next_y = final_y - 1
		var blocked = false
		for col in range(item.shape[0].size()):
			for row in range(item.shape.size()):
				if item.shape[row][col] == 1:
					var check_y = next_y + row
					var check_x = start_x + col
					if check_y < 0 or check_x >= columns or (grid[check_y][check_x] != null and grid[check_y][check_x] != item):
						blocked = true
						break
			if blocked:
				break
		if blocked:
			break
		final_y = next_y
	
	if final_y != start_y:
		_remove_item_from_old_position(item, start_x, start_y)
		_place_item_in_new_position(item, start_x, final_y)
		return true
	return false

# Helper function to remove item from an old position
func _remove_item_from_old_position(item: Node, start_x: int, start_y: int) -> void:
	for row in range(item.shape.size()):
		for col in range(item.shape[0].size()):
			if item.shape[row][col] == 1:
				grid[start_y + row][start_x + col] = null

# Helper function to place an item in a new position
func _place_item_in_new_position(item: Node, start_x: int, fall_y: int) -> void:
	for row in range(item.shape.size()):
		for col in range(item.shape[0].size()):
			if item.shape[row][col] == 1:
				grid[fall_y + row][start_x + col] = item

	create_tween().tween_property(item, "position", Vector2(start_x, fall_y) * cell_size, 0.1)


func _pop_item_to_background(item: Node) -> void:
	var main_scene = get_node("/root/Main")
	_remove_item_from_grid(item)
	item.z_index = 5

	if item.get_parent() == self:
		item.reparent(main_scene)

	main_scene._scatter_item(item, Global.TWEENS.SCATTER)

# Calculate grid coordinates from world position
func _get_grid_coordinates(world_position: Vector2) -> Vector2:
	var local_position = world_position - global_position
	var grid_x = maxi(0, floor(local_position.x / cell_size.x))
	var grid_y = maxi(0, floor(local_position.y / cell_size.y))

	if dragging_item:
		var rotated_shape = Global.drag_preview.shape
		var shape_width = rotated_shape[0].size()
		var shape_height = rotated_shape.size()

		grid_x = grid_x - floor(shape_width / 2)
		grid_y = grid_y - floor(shape_height / 2)

		grid_x = maxi(0, mini(grid_x, columns - shape_width))
		grid_y = maxi(0, mini(grid_y, rows - shape_height))
	else:
		grid_x = maxi(0, mini(grid_x, columns - 1))
		grid_y = maxi(0, mini(grid_y, rows - 1))

	return Vector2(grid_x, grid_y)

# Helper function to check if a cell is within bounds
func _is_within_bounds(cell_x: int, cell_y: int) -> bool:
	return cell_x >= 0 and cell_y >= 0 and cell_x < columns and cell_y < rows

# Helper to find leftmost position of an item
func _find_item_start_x(item: Node, row: int, col: int) -> int:
	while col > 0 and grid[row][col - 1] == item:
		col -= 1
	return col

# Helper function to update preview transform
func _update_preview_transform(coords: Vector2, shape: Array) -> void:
	drop_preview.current_rotation = Global.drag_preview.current_rotation
	drop_preview.init(Global.drag_preview.shape, drop_preview.images, drop_preview.category, drop_preview.score, drop_preview.description, drop_preview.task_data)
	drop_preview.position = coords * cell_size

	last_preview_pos = coords
	last_preview_rotation = Global.drag_preview.current_rotation

# Helper function to create drop preview in the grid
func _create_drop_preview() -> void:
	drop_preview = Global.drag_preview.duplicate()
	drop_preview.modulate.a = 0.5
	drop_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	drop_preview.init(
		Global.drag_preview.shape.duplicate(true),
		Global.drag_preview.images,
		Global.drag_preview.category,
		Global.drag_preview.score,
		Global.drag_preview.description,
		Global.drag_preview.task_data
	)
	
	drop_preview.current_rotation = Global.drag_preview.current_rotation
	drop_preview.position = Vector2.ZERO

	add_child(drop_preview)

# Helper function to remove drop preview from the grid
func _remove_drop_preview():
	if drop_preview:
		drop_preview.queue_free()
		drop_preview = null

		last_preview_pos = Vector2.ZERO
		last_preview_rotation = 0

func _on_mouse_exited():
	_remove_drop_preview()
