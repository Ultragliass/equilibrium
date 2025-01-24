extends Control

var drop_preview: Node = null
var last_preview_pos: Vector2 = Vector2.ZERO
var last_preview_rotation: int = 0

var grid = []
var cell_size = Vector2(100, 100)
var rows: int
var columns: int

var dragging_item: Node = null
var original_positions: Array = []

# Initialize the grid with given dimensions
func init(grid_rows: int, grid_columns: int, grid_cell_size: Vector2):
	rows = grid_rows
	columns = grid_columns
	cell_size = grid_cell_size
	mouse_exited.connect(_on_mouse_exited)

	print("Grid Initialized: Rows=", rows, ", Columns=", columns, ", Cell Size=", cell_size)
	_initialize_empty_grid()

# Helper function to initialize an empty grid 
func _initialize_empty_grid() -> void:
	grid.resize(rows)
	for i in range(rows):
		grid[i] = []
		grid[i].resize(columns)
		for j in range(columns):
			grid[i][j] = null
	print("Empty grid initialized.")

# Helper function to get rotated shape
func _get_rotated_shape(original_shape: Array) -> Array:
	var result = original_shape
	for i in range(Global.current_rotation):
		result = Global.rotate_shape(result)
	print("Rotated shape:", result)
	return result

# Helper function to check if a cell is within bounds
func _is_within_bounds(cell_x: int, cell_y: int) -> bool:
	return cell_x >= 0 and cell_y >= 0 and cell_x < columns and cell_y < rows

func can_place_item_at(grid_x: int, grid_y: int, item: Node) -> bool:
	var shape = item.shape
	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var cell_x = grid_x + col
				var cell_y = grid_y + row

				# Check grid bounds
				if not _is_within_bounds(cell_x, cell_y):
					print("Cannot place item - out of bounds at", cell_x, ",", cell_y)
					return false

				# Allow overlap with dragging item
				if grid[cell_y][cell_x] != null and grid[cell_y][cell_x] != dragging_item:
					print("Cannot place item - space occupied at", cell_x, ",", cell_y)
					return false

	return true

func place_item_at(grid_x: int, grid_y: int, item: Node) -> Dictionary:
	if not can_place_item_at(grid_x, grid_y, item):
		print("Failed to place item at", grid_x, ",", grid_y)
		return {"isPlaced": false, "grid_coords": 0, "grid_y": 0}

	remove_item_from_grid(item)

	# Place in new positions
	for row in range(item.shape.size()):
		for col in range(item.shape[row].size()):
			if item.shape[row][col] == 1:
				grid[grid_y + row][grid_x + col] = item
				print("Successfully placed item at", grid_x + col, ",", grid_y + row)

	return {"isPlaced": true, "grid_x": grid_x, "grid_y": grid_y}

func remove_item_from_grid(item: Node) -> void:
	# First pass - just remove item
	for row in range(rows):
		for col in range(columns):
			if grid[row][col] == item:
				grid[row][col] = null
				print("Removing item from", col, ",", row)

func update_falling_items() -> void:
	var something_fell = true

	# Keep checking until nothing falls anymore
	while something_fell:
		something_fell = false
		# Process from bottom up
		for row in range(rows - 1, -1, -1):
			for col in range(columns):
				var item = grid[row][col]
				if item != null and item.category == "iron":
					# Process each item only once by checking leftmost position
					var item_start_x = _find_item_start_x(item, row, col)
					if col == item_start_x:
						# Check if item can fall
						var did_fall = _make_item_fall(item, item_start_x, row)
						something_fell = something_fell or did_fall

# Helper function to find the leftmost position of an item in a row
func _find_item_start_x(item: Node, row: int, col: int) -> int:
	while col > 0 and grid[row][col - 1] == item:
		col -= 1
	return col

# Helper function to make an item fall to its lowest possible position
func _make_item_fall(item: Node, start_x: int, start_y: int) -> bool:
	var fall_y = start_y
	while can_move_down(item, start_x, fall_y):
		fall_y += 1

	if fall_y != start_y:
		_remove_item_from_old_position(item, start_x, start_y)
		_place_item_in_new_position(item, start_x, fall_y)
		print("Iron item fell from y=", start_y, "to y=", fall_y)
		return true

	return false

# Helper function to remove an item from its old position
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
	item.position = Vector2(start_x, fall_y) * cell_size

# Check if dragging item can be dropped
func _can_drop_data(_pos, data):
	if not (data is Control):
		return false

	var grid_coords = get_grid_coordinates(get_global_mouse_position())
	dragging_item = data

	var temp_item = data.duplicate()
	temp_item.shape = _get_rotated_shape(data.shape)

	var can_place = can_place_item_at(grid_coords.x, grid_coords.y, temp_item)
	temp_item.queue_free()

	if can_place:
		show_drop_preview(grid_coords, temp_item.shape)
		return true

	remove_drop_preview()
	return false

# Handle dropping of an item
func _drop_data(_pos, data):
	if not (data is Control):
		return

	var grid_coords = get_grid_coordinates(get_global_mouse_position())
	data.shape = _get_rotated_shape(data.shape)
	data.init(data.shape, data.category)

	remove_item_from_grid(data)
	remove_drop_preview()

	# Reparent if needed
	if data.get_parent() != self:
		data.reparent(self)

	var placement_data = place_item_at(grid_coords.x, grid_coords.y, data)

	if placement_data.isPlaced:
		data.position = grid_coords * cell_size
		# Check for falls
		update_falling_items()

	dragging_item = null
	Global.is_dragging = false
	Global.current_rotation = 0

# Calculate grid coordinates from world position
func get_grid_coordinates(world_position: Vector2) -> Vector2:
	var local_position = world_position - global_position
	var grid_x = maxi(0, floor(local_position.x / cell_size.x))
	var grid_y = maxi(0, floor(local_position.y / cell_size.y))

	if dragging_item:
		var rotated_shape = _get_rotated_shape(dragging_item.shape)
		var shape_width = rotated_shape[0].size()
		var shape_height = rotated_shape.size()

		grid_x = grid_x - floor(shape_width / 2)
		grid_y = grid_y - floor(shape_height / 2)

		grid_x = maxi(0, mini(grid_x, columns - shape_width))
		grid_y = maxi(0, mini(grid_y, rows - shape_height))
	else:
		grid_x = maxi(0, mini(grid_x, columns - 1))
		grid_y = maxi(0, mini(grid_y, rows - 1))

	print("Grid coordinates calculated:", Vector2(grid_x, grid_y))
	return Vector2(grid_x, grid_y)

# Initialize and show drop preview
func show_drop_preview(grid_coords: Vector2, shape: Array):
	if not drop_preview:
		_create_drop_preview()

	var safe_coords = Vector2(
		clamp(grid_coords.x, 0, columns - 1),
		clamp(grid_coords.y, 0, rows - 1)
	)

	if last_preview_pos != safe_coords or last_preview_rotation != Global.current_rotation:
		_update_preview_transform(safe_coords, shape)

# Helper function to create drop preview
func _create_drop_preview() -> void:
	drop_preview = Global.drag_item.duplicate()
	drop_preview.modulate = Color(1, 1, 1, 0.5)
	drop_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drop_preview.category = Global.drag_item.category

	# Reset all control properties
	drop_preview.position = Vector2.ZERO
	drop_preview.anchor_left = 0
	drop_preview.anchor_top = 0
	drop_preview.anchor_right = 0
	drop_preview.anchor_bottom = 0
	drop_preview.offset_left = 0
	drop_preview.offset_top = 0
	drop_preview.offset_right = 0
	drop_preview.offset_bottom = 0

	add_child(drop_preview)

# Helper function to update preview transform
func _update_preview_transform(coords: Vector2, shape: Array) -> void:
	drop_preview.shape = shape
	drop_preview.init(shape, drop_preview.category)
	drop_preview.position = coords * cell_size
	last_preview_pos = coords
	last_preview_rotation = Global.current_rotation

func remove_drop_preview():
	if drop_preview:
		drop_preview.queue_free()
		drop_preview = null
		last_preview_pos = Vector2.ZERO
		last_preview_rotation = 0

func _on_mouse_exited():
	remove_drop_preview()

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	if event.is_action_pressed("rotate") and Global.is_dragging and drop_preview:
		update_drop_preview()

func update_drop_preview():
	if drop_preview and Global.drag_item:
		var grid_coords = get_grid_coordinates(get_global_mouse_position())
		var rotated_shape = _get_rotated_shape(Global.drag_item.shape)
		show_drop_preview(grid_coords, rotated_shape)

func can_move_down(item: Node, current_x: int, current_y: int) -> bool:
	if current_y >= rows - item.shape.size(): # Already at bottom
		return false

	# Check if space below is free
	for col in range(item.shape[0].size()):
		for row in range(item.shape.size()):
			if item.shape[row][col] == 1:
				var check_y = current_y + row + 1
				var check_x = current_x + col

				if check_y >= rows:
					return false

				if grid[check_y][check_x] != null and grid[check_y][check_x] != item:
					return false

	return true
