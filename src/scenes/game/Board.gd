extends Node2D

onready var fall_timer : Timer = $FallTimer

const width := 10
const height := 20
export var speed := 1.0

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
	rng.randomize()
	instance_next_block()

func _process(_delta: float) -> void:
	input_treatment()
	

## instantiate a random block
func instance_next_block() -> void:
	var block = blocks[rng.randi() % blocks.size()].instance()
	add_child(block)
	block.position = Vector2(Params.cell_size * 5, 0)

	current_block = block
	current_block_position = pixel_to_grid(block.position.x, block.position.y)
	put_block_into_board(int(current_block_position.y), int(current_block_position.x))

## make current block fall down 1 cell
func block_fall() -> void:
	move_current_block(Vector2.DOWN)

func move_current_block(direction: Vector2) -> void:
	if can_move(direction):
		current_block.move(current_block_position * Params.cell_size + direction * Params.cell_size)
		current_block_position += direction
		update_board()
		if not can_move(Vector2.DOWN):			
			fix_block_on_board()
			check_for_color_matches()
			instance_next_block()

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
		print_debug("fall completely downwards")
		display_board()

func _on_FallTimer_timeout() -> void:
	block_fall()

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
				#if board[current_block_position.y + i + direction.y][current_block_position.x + j + direction.x] != null and not board[current_block_position.y + i + direction.y][current_block_position.x + j + direction.x] in [1, 2, 3, 4]: # touching other pieces on the board but not the current block itself
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
	for row in board.size():
		for col in board[row].size():
			if board[row][col] in [1, 2, 3, 4]:
				board[row][col] = null

func update_board() -> void:
	remove_current_block_from_board()
	put_block_into_board(int(current_block_position.y), int(current_block_position.x))

## tells whether the position of the block is correct on the board after a rotation clockwise
func is_position_correct_after_rotation() -> bool:
	#var test_block = current_block.duplicate()
	#var test_block_pos = current_block_position
	#remove_current_block_from_board()
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
				#if board[current_block_position.y + i][current_block_position.x + j] != null and not board[current_block_position.y + i][current_block_position.x + j] in [1, 2, 3, 4]: # touching other pieces on the board but not the current block itself
					current_block.rotate_counter_clockwise()
					return false
	current_block.rotate_counter_clockwise()
	return true

# func can_move_down() -> bool:
# 	var block_pos = current_block.current_position
# 	for row in current_block.positions[block_pos].size():
# 		for col in current_block.positions[block_pos][row].size():
# 			var cell = current_block.positions[block_pos][row][col]
# 			if cell != 0:				
# 				# if current_block_position.y + row + 1 > height - 1 or board[current_block_position.y + row + 1][current_block_position.x + col] != null and board[current_block_position.y + row + 1][current_block_position.x + col] != 1 and board[current_block_position.y + row + 1][current_block_position.x + col] != 2 and board[current_block_position.y + row + 1][current_block_position.x + col] != 3 and board[current_block_position.y + row + 1][current_block_position.x + col] != 4:
# 				if current_block_position.y + row + 1 > height - 1 or (board[current_block_position.y + row + 1][current_block_position.x + col] != null and not board[current_block_position.y + row + 1][current_block_position.x + col] in [1, 2, 3, 4]): # touching other pieces on the board but not the current block itself
# 					return false
# 	return true

## Fixes the current block cells in the board
func fix_block_on_board() -> void:
	for row in height:
		for col in width:
			match board[row][col]:
				1: board[row][col] = current_block.cell1
				2: board[row][col] = current_block.cell2
				3: board[row][col] = current_block.cell3
				4: board[row][col] = current_block.cell4

## checks for 3-matches of the same color # todo match-4 pour coller au côté tetrominoes ?
func check_for_color_matches() -> void:
	for row in height:
		for col in width:
			if row > 0 and row < height-1:
				if is_a_cell(row-1, col) and is_a_cell(row, col) and is_a_cell(row+1, col):				
					var cell_above = board[row-1][col]
					var cell = board[row][col]
					var cell_below = board[row+1][col]
					if cell_above.color == cell.color and cell.color == cell_below.color:
						cell_above.matched = true
						cell.matched = true
						cell_below.matched = true
						cell_above.sprite.modulate = Color(1, 1, 1, 0.5)
						cell.sprite.modulate = Color(1, 1, 1, 0.5)
						cell_below.sprite.modulate = Color(1, 1, 1, 0.5)
						print_debug("vertical match!")		

			if col > 0 and col < width -1:
				if is_a_cell(row, col-1) and is_a_cell(row, col) and is_a_cell(row, col+1):				
					var cell_left = board[row][col-1]
					var cell = board[row][col]
					var cell_right = board[row][col+1]
					if cell_left.color == cell.color and cell.color == cell_right.color:
						cell_left.matched = true
						cell.matched = true
						cell_right.matched = true
						cell_left.sprite.modulate = Color(1, 1, 1, 0.5)
						cell.sprite.modulate = Color(1, 1, 1, 0.5)
						cell_right.sprite.modulate = Color(1, 1, 1, 0.5)
						print_debug("horizontal match!")
				
			


func is_a_cell(row, col) -> bool:
	return board[row][col] != null and not board[row][col] in [1, 2, 3, 4]