extends "res://src/scenes/menu/BaseMenuPanel.gd"

signal settings_sound_pressed
signal settings_back_pressed

func _on_Button1_pressed() -> void:
	emit_signal("settings_sound_pressed")

func _on_Button2_pressed() -> void:
	emit_signal("settings_back_pressed")