extends Control

var drop_preview: Control = null

var grid = []
var cell_size = Vector2(100, 100)
var rows: int
var columns: int

func init(grid_rows: int, grid_columns: int, grid_cell_size: Vector2):
	rows = grid_rows
	columns = grid_columns
	cell_size = grid_cell_size
	mouse_exited.connect(_on_mouse_exited)

	print("Grid Initialized: Rows=", rows, ", Columns=", columns, ", Cell Size=", cell_size)

	grid.resize(rows)
	for i in range(rows):
		grid[i] = []
		grid[i].resize(columns)
		for j in range(columns):
			grid[i][j] = null

func can_place_item_at(grid_x: int, grid_y: int, item: Node) -> bool:
	var shape = item.shape
	for row in range(shape.size()):
		for col in range(shape[row].size()):
			if shape[row][col] == 1:
				var cell_x = grid_x + col
				var cell_y = grid_y + row

				if cell_x >= columns or cell_y >= rows or cell_x < 0 or cell_y < 0:
					return false

				if grid[cell_y][cell_x] != null and grid[cell_y][cell_x] != item:
					return false

	return true


func place_item_at(grid_x: int, grid_y: int, item: Node) -> bool:
	if not can_place_item_at(grid_x, grid_y, item):
		return false

	for row in range(item.shape.size()):
		for col in range(item.shape[row].size()):
			if item.shape[row][col] == 1:
				grid[grid_y + row][grid_x + col] = item

	item.position = Vector2(grid_x, grid_y) * cell_size

	item.anchor_left = 0
	item.anchor_top = 0
	item.anchor_right = 0
	item.anchor_bottom = 0

	item.size_flags_horizontal = Control.SIZE_FILL
	item.size_flags_vertical = Control.SIZE_FILL

	return true


func remove_item_from_grid(item: Node):
	for row in range(rows):
		for col in range(columns):
			if grid[row][col] == item:
				grid[row][col] = null


func _can_drop_data(_pos, data):
	if data is Control:
		var dragging_item = Global.drag_item
		var grid_coords = get_grid_coordinates(get_global_mouse_position())

		if dragging_item and can_place_item_at(grid_coords.x, grid_coords.y, dragging_item):
			show_drop_preview(grid_coords, dragging_item)
			return true

	remove_drop_preview()

	return false


func _drop_data(_pos, data):
	var grid_coords = get_grid_coordinates(get_global_mouse_position())

	if can_place_item_at(grid_coords.x, grid_coords.y, data):
		remove_item_from_grid(data)
		remove_drop_preview()

		if place_item_at(grid_coords.x, grid_coords.y, data):
			if data.get_parent() != self:
				data.reparent(self)


			data.position = grid_coords * cell_size
			print("Item placed successfully at: ", grid_coords)
		else:
			print("Failed to place item")
	else:
		print("Item cannot be placed at this position")


func get_grid_coordinates(world_position: Vector2) -> Vector2:
	var local_position = world_position - global_position
	
	local_position -= Functions._calculate_drag_item_size()
	
	var grid_x = floor(local_position.x / cell_size.x)
	var grid_y = floor(local_position.y / cell_size.y)
	
	grid_x = clamp(grid_x, 0, columns)
	grid_y = clamp(grid_y, 0, rows)
	
	return Vector2(grid_x, grid_y)

func show_drop_preview(grid_coords: Vector2, dragging_item: Control):
	if not drop_preview:
		drop_preview = dragging_item.duplicate()
		drop_preview.init(dragging_item.shape)
		drop_preview.modulate.a = 0.5
		add_child(drop_preview)
	
	drop_preview.position = grid_coords * cell_size

func remove_drop_preview():
	if drop_preview:
		drop_preview.queue_free()
		drop_preview = null

func _on_mouse_exited():
	remove_drop_preview()
