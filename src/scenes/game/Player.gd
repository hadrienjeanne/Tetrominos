extends Node

export var life := 5 setget set_life
export var max_life := 5 setget set_max_life


signal life_changed

func set_life(value: int) -> void:
	life = value
	emit_signal("life_changed", life)
	

func set_max_life(value: int) -> void:
	max_life = value
	if life > max_life:
		life = max_life