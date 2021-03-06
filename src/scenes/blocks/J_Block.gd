extends Block

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	positions = [
		[[0, 0, 1], [0, 0, 2], [0, 4, 3]],
		[[0, 0, 0], [4, 0, 0], [3, 2, 1]],
		[[3, 4, 0], [2, 0, 0], [1, 0, 0]],
		[[1, 2, 3], [0, 0, 4], [0, 0, 0]],
	]
	set_in_position(POS1)


func move(target : Vector2) -> void:
	.move(target)

func rotate_clockwise() -> void:
	.rotate_clockwise()

func rotate_counter_clockwise() -> void:
	.rotate_counter_clockwise()

func set_in_position(pos: int) -> void:
	.set_in_position(pos)