extends Node2D

onready var score_label : Label = $UI/ScoreUI/ScoreLabel
onready var board := $Board

## update the score
func _on_Board_score_updated(value: int) -> void:
	score_label.text = str(value)

func _on_Board_game_over() -> void:
	print_debug("game over")