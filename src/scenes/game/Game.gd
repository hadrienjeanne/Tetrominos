extends Node2D

onready var game_over_panel := $GameOverPanel
onready var score_label : Label = $UI/ScoreUI/ScoreLabel
onready var board := $Board

## update the score
func _on_Board_score_updated(value: int) -> void:
	score_label.text = str(value)

func _on_Board_game_over() -> void:
	print_debug("game over")
	game_over_panel.slide_in()


func _on_GameOverPanel_game_over_quit() -> void:
	game_over_panel.slide_out()
	var _err := get_tree().change_scene("res://src/scenes/menu/MainMenu.tscn")

func _on_GameOverPanel_game_over_restart() -> void:
	game_over_panel.slide_out()
	var _err := get_tree().reload_current_scene()