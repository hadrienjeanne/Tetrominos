extends Block


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	positions = [
		[[1, 2], [3, 4]],
		[[3, 1], [4, 2]],
		[[4, 3], [2, 1]],
		[[2, 4], [1, 3]],
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