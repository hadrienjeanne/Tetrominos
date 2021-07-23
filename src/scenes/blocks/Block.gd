class_name Block
extends Node2D

onready var move_tween : Tween = $MoveTween
onready var cell1 : = $Cell
onready var cell2 : = $Cell2
onready var cell3 : = $Cell3
onready var cell4 : = $Cell4

enum {POS1, POS2, POS3, POS4}
var positions := []
var current_position := POS1

# var block_top := 0
# var block_bottom := 0
# var block_left := 0
# var block_right := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## moves the block and animates the movement
func move(target : Vector2) -> void:
	# print_debug("move tween", position, " ", target)
	var _err = move_tween.interpolate_property(self, "position", position, target, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	_err = move_tween.start()


## rotate the block clockwise
func rotate_clockwise() -> void:
	current_position = (current_position + 1) % 4	
	set_in_position(current_position)

## rotates the block counter clockwise
func rotate_counter_clockwise() -> void:
	current_position = (current_position - 1) % 4	
	set_in_position(current_position)

## sets the block in position pos
func set_in_position(pos: int) -> void:
	var cell_size = Params.cell_size
	for i in positions[pos].size():
		for j in positions[pos][i].size():
			var cell = positions[pos][i][j]
			match cell:
				1: cell1.position = Vector2(j, i) * cell_size
				2: cell2.position = Vector2(j, i) * cell_size
				3: cell3.position = Vector2(j, i) * cell_size
				4: cell4.position = Vector2(j, i) * cell_size

func get_height() -> int:
	var height := 0
	for row in positions[current_position]:
		var has_cell_in_row := false
		for col in row:
			if col != 0:
				has_cell_in_row = true
		if has_cell_in_row:
			height += 1
	return height