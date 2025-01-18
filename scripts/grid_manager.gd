extends Control

var drop_preview: CenterContainer = null

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

func can_place_item_at(grid_x: int, grid_y: int, item_width: int, item_height: int, moving_item: Node = null) -> bool:
	for i in range(item_height):
		for j in range(item_width):
			var cell_x = grid_x + j
			var cell_y = grid_y + i

			if cell_x >= columns or cell_y >= rows:
				print("Out of bounds at: ", Vector2(cell_x, cell_y))
				return false

			if grid[cell_y][cell_x] != null and grid[cell_y][cell_x] != moving_item:
				print("Cell occupied at: ", Vector2(cell_x, cell_y))
				return false

	return true


func place_item_at(grid_x: int, grid_y: int, item: Node, item_width: int, item_height: int) -> bool:
	if not can_place_item_at(grid_x, grid_y, item_width, item_height, item):
		return false

	for i in range(item_height):
		for j in range(item_width):
			grid[grid_y + i][grid_x + j] = item

	item.position = Vector2(grid_x, grid_y) * cell_size
	item.anchors_preset = Control.PRESET_TOP_LEFT
	return true

func remove_item_from_grid(item: Node):
	for i in range(rows):
		for j in range(columns):
			if grid[i][j] == item:
				print("Removing item from cell(", j, ", ", i, ")")
				grid[i][j] = null

func _can_drop_data(_pos, data):
	if data is CenterContainer:
		var dragging_item = Global.get_drag_item()
		var grid_coords = get_grid_coordinates(get_global_mouse_position(), dragging_item.width, dragging_item.height)

		if dragging_item and can_place_item_at(grid_coords.x, grid_coords.y, dragging_item.width, dragging_item.height, data):
			show_drop_preview(grid_coords, dragging_item)
			return true

	remove_drop_preview()

	return false

func _drop_data(_pos, data):
	var grid_coords = get_grid_coordinates(get_global_mouse_position(), data.width, data.height)

	if can_place_item_at(grid_coords.x, grid_coords.y, data.width, data.height, data):
		remove_item_from_grid(data)
		remove_drop_preview()
		
		if place_item_at(grid_coords.x, grid_coords.y, data, data.width, data.height):
			if data.get_parent() != self:
				data.reparent(self)

			data.position = grid_coords * cell_size
			data.anchors_preset = Control.PRESET_TOP_LEFT
			data.anchor_left = 0
			data.anchor_top = 0
			data.anchor_right = 0
			data.anchor_bottom = 0
			data.modulate.a = 1

			print("Item placed successfully at: ", grid_coords)
		else:
			print("Failed to place item")
	else:
		print("Item cannot be placed at this position")


func get_grid_coordinates(world_position: Vector2, item_width: int, item_height: int) -> Vector2:
	var local_position = world_position - global_position

	var grid_x = floor(local_position.x / cell_size.x)
	var grid_y = floor(local_position.y / cell_size.y)

	grid_x = clamp(grid_x, 0, columns - item_width)
	grid_y = clamp(grid_y, 0, rows - item_height)

	return Vector2(grid_x, grid_y)

func show_drop_preview(grid_coords: Vector2, dragging_item: CenterContainer):
	if not drop_preview:
		drop_preview = dragging_item.duplicate()
		drop_preview.init(dragging_item.number, dragging_item.width, dragging_item.height)
		drop_preview.modulate.a = 0.5
		add_child(drop_preview)

	drop_preview.position = grid_coords * cell_size
	drop_preview.mouse_filter = Control.MOUSE_FILTER_PASS

func remove_drop_preview():
	if drop_preview:
		drop_preview.queue_free()
		drop_preview = null

func _on_mouse_exited():
	remove_drop_preview()
