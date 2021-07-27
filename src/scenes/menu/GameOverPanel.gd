extends "res://src/scenes/menu/BaseMenuPanel.gd"

signal game_over_quit
signal game_over_restart

func _on_Button1_pressed() -> void:
	emit_signal("game_over_quit")

func _on_Button2_pressed() -> void:
	emit_signal("game_over_restart")