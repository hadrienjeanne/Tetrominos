extends Node2D

onready var board_rect : AspectRatioContainer = $AspectRatioContainer
onready var fall_timer : Timer = $FallTimer
onready var projection_cell1 : Sprite = $Projections/ProjectionCell1
onready var projection_cell2 : Sprite = $Projections/ProjectionCell2
onready var projection_cell3 : Sprite = $Projections/ProjectionCell3
onready var projection_cell4 : Sprite = $Projections/ProjectionCell4

const width := 10
const height := 16
export var speed := 1.5

var rng := RandomNumberGenerator.new()

var blocks := [
	preload("res://src/scenes/blocks/I_Block.tscn"),
	preload("res://src/scenes/blocks/J_Block.tscn"),
	preload("res://src/scenes/blocks/L_Block.tscn"),
	preload("res://src/scenes/blocks/O_Block.tscn"),
	preload("res://src/scenes/blocks/S_Block.tscn"),
	preload("res://src/scenes/blocks/T_Block.tscn"),
	preload("res://src/scenes/blocks/Z_Block.tscn")
]

var current_block
var current_block_position := Vector2.ZERO

var board := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = make_2d_array(height, width)
	fall_timer.wait_time = 1 / speed
	rng.randomize()
	board_rect.ratio = float(width)/height
	board_rect.rect_size = Vector2(width, height) * Params.cell_size
	instantiate_next_block()

func _process(_delta: float) -> void:
	input_treatment()
	

## instantiate a random block
func instantiate_next_block() -> void:
	var block = blocks[rng.randi() % blocks.size()].instance()
	add_child(block)
	block.position = Vector2(Params.cell_size * 5, 0)

	current_block = block
	current_block_position = pixel_to_grid(block.position.x, block.position.y)
	put_block_into_board(int(current_block_position.y), int(current_block_position.x))
	display_block_projection()

## make current block fall down 1 cell and move the cells on the board than can go down
func blocks_fall() -> void:
	move_current_block(Vector2.DOWN)
	
	for row in range(height - 2, 1, -1):
		for col in width:
			if is_a_cell(row, col) and board[row+1][col] == null:
				var cell = board[row][col]
				cell.move(Vector2.DOWN * Params.cell_size)
				board[row+1][col] = cell
				board[row][col] = null


func move_current_block(direction: Vector2) -> void:
	if can_move(direction):
		current_block.move(current_block_position * Params.cell_size + direction * Params.cell_size)
		current_block_position += direction
		update_board()
		if not can_move(Vector2.DOWN):			
			fix_block_on_board()
			check_for_color_matches()
			destroy_matched_cells()
			instantiate_next_block()

func rotate_current_block() -> void:
	if is_position_correct_after_rotation():
		current_block.rotate_clockwise()
		update_board()

func input_treatment() -> void:
	if Input.is_action_just_pressed("ui_left"):
		move_current_block(Vector2.LEFT)		
	if Input.is_action_just_pressed("ui_right"):
		move_current_block(Vector2.RIGHT)
	if Input.is_action_just_pressed("ui_rotate"):
		rotate_current_block()
	if Input.is_action_just_pressed("ui_down"):
		move_current_block(Vector2.DOWN)
	if Input.is_action_just_pressed("ui_complete_down"):
		fall_to_bottom()
		# display_board()

func _on_FallTimer_timeout() -> void:
	blocks_fall()
	check_for_color_matches()
	destroy_matched_cells()

## create a 2D array of size (w, h)
func make_2d_array(w: int, h: int) -> Array:
	var array := []
	for i in range(w):
		array.append([])
		for _j in range(h):
			array[i].append(null)
	return array

## input: a column and a row number for a piece
## output: the position in pixels of the piece
func grid_to_pixel(col: int, row: int) -> Vector2:
	var new_x := Params.cell_size * col
	var new_y := -Params.cell_size * row
	return Vector2(new_x, new_y)

## input: a position in pixels of the mouse 
## output: the column and the row number for the piece
func pixel_to_grid(x: float, y: float) -> Vector2:
	var col := round(x / float(Params.cell_size))
	var row := round(y / float(Params.cell_size))
	return Vector2(col, row)

## tells whether the position pos is inside the board 
func is_in_board(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < width and pos.y < height

func display_board() -> void:
	for r in height:
		var row_str = ""
		for c in width:			
			if board[r][c] != null:
				row_str += str(board[r][c])
			else:
				row_str += 'x'
		print_debug(row_str)

##	tells whether the position pos is inside the grid after a movement in the direction direction
func can_move(direction: Vector2) -> bool:
	var block_pos = current_block.current_position
	for i in current_block.positions[block_pos].size():
		for j in current_block.positions[block_pos][i].size():
			var cell = current_block.positions[block_pos][i][j]
			if cell != 0:
				if current_block_position.y + i + direction.y < 0 or current_block_position.y + i + direction.y >= height:
					return false
				if current_block_position.x + j + direction.x < 0 or current_block_position.x + j + direction.x >= width:
					return false
				if is_a_cell(current_block_position.y + i + direction.y, current_block_position.x + j + direction.x): # touching other pieces on the board but not the current block itself
					return false
	return true

##
func put_block_into_board(row: int, col: int) -> void:
	var block_pos = current_block.current_position
	for i in current_block.positions[block_pos].size():
		for j in current_block.positions[block_pos][i].size():
			var cell = current_block.positions[block_pos][i][j]
			if cell != 0:
				board[row + i][col + j] = cell

func remove_current_block_from_board() -> void:
	for row in height:
		for col in width:
			if board[row][col] in [1, 2, 3, 4]:
				board[row][col] = null

func update_board() -> void:
	remove_current_block_from_board()
	put_block_into_board(int(current_block_position.y), int(current_block_position.x))
	display_block_projection()

## tells whether the position of the block is correct on the board after a rotation clockwise
func is_position_correct_after_rotation() -> bool:
	current_block.rotate_clockwise()
	var block_pos = current_block.current_position
	for i in current_block.positions[block_pos].size():
		for j in current_block.positions[block_pos][i].size():
			var cell = current_block.positions[block_pos][i][j]
			if cell != 0:
				if current_block_position.y + i < 0 or current_block_position.y + i > height - 1:
					current_block.rotate_counter_clockwise()
					return false
				if current_block_position.x + j < 0 or current_block_position.x + j > width - 1:
					current_block.rotate_counter_clockwise()
					return false
				if is_a_cell(current_block_position.y + i, current_block_position.x + j): # touching other pieces on the board but not the current block itself
					current_block.rotate_counter_clockwise()
					return false
	current_block.rotate_counter_clockwise()
	return true

## Fixes the current block cells in the board
func fix_block_on_board() -> void:
	for row in height:
		for col in width:
			match board[row][col]:
				1: board[row][col] = current_block.cell1
				2: board[row][col] = current_block.cell2
				3: board[row][col] = current_block.cell3
				4: board[row][col] = current_block.cell4

## checks for 4-matches of the same color
func check_for_color_matches() -> void:
	for row in height:
		for col in width:
			if row >= 0 and row < height-3:
				if is_a_cell(row, col) and is_a_cell(row+1, col) and is_a_cell(row+2, col) and is_a_cell(row+3, col):
					var cell_0 = board[row][col]
					var cell_1 = board[row+1][col]
					var cell_2 = board[row+2][col]
					var cell_3 = board[row+3][col]
					if cell_0.color == cell_1.color and cell_0.color == cell_2.color and cell_0.color == cell_3.color:
						cell_0.matched = true
						cell_1.matched = true
						cell_2.matched = true
						cell_3.matched = true

			if col >= 0 and col < width-3:
				if is_a_cell(row, col) and is_a_cell(row, col+1) and is_a_cell(row, col+2) and is_a_cell(row, col+3):
					var cell_0 = board[row][col]
					var cell_1 = board[row][col+1]
					var cell_2 = board[row][col+2]
					var cell_3 = board[row][col+3]
					if cell_0.color == cell_1.color and cell_0.color == cell_2.color and cell_0.color == cell_3.color:
						cell_0.matched = true
						cell_1.matched = true
						cell_2.matched = true
						cell_3.matched = true
			
## destroys the cells that are matched (Cell attribute matched == true)
func destroy_matched_cells() -> void:
	for row in height:
		for col in width:
			if is_a_cell(row, col):
				var cell = board[row][col]
				if cell.matched:
					cell.destroy()
					board[row][col] = null

## returns true if the item at the position (row, col) in the board is a cell (i.e. is not null and not the current block)
func is_a_cell(row, col) -> bool:
	return board[row][col] != null and not board[row][col] in [1, 2, 3, 4]

## returns the first available row at the col column of the board
func get_lowest_available_row(col: int) -> int:
	for row in range(height-1, 1, -1):
		if not is_a_cell(row, col):
			return row
	return 0

## displays the projection of the current block on the lower part of the board
func display_block_projection() -> void:
	for row in height:
		for col in width:
			if board[row][col] in [1, 2, 3, 4]:
				var lowest_row = get_lowest_available_row(col)				
				match board[row][col]:
					1: projection_cell1.position = Vector2(col, lowest_row) * Params.cell_size
					2: projection_cell2.position = Vector2(col, lowest_row) * Params.cell_size
					3: projection_cell3.position = Vector2(col, lowest_row) * Params.cell_size
					4: projection_cell4.position = Vector2(col, lowest_row) * Params.cell_size

## makes the current block fall downard to bottom of the board
func fall_to_bottom() -> void:
	# fall_timer.stop()
	var highest_row = height
	for row in height:
		for col in width:
			if board[row][col] in [1, 2, 3, 4]:
				var lowest_row = get_lowest_available_row(col)
				if lowest_row < highest_row:
					highest_row = lowest_row
	move_current_block(Vector2.DOWN * (highest_row - current_block_position.y - current_block.get_height())) # TODO modifier -2 par la hauteur de la pièce
	# todo gérer le fait que lorsqu'on appui proche d'une pièce, le bloc remonte
	# fall_timer.start()