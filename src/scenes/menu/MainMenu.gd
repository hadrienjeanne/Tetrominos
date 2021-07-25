extends Node2D

onready var main_menu_panel := $MainMenuPanel
onready var settings_menu_panel := $SettingsMenuPanel

var difficulty_select_scene := preload("res://src/scenes/game/Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_panel.slide_in()


func _on_MainMenuPanel_play_pressed() -> void:
	var _err := get_tree().change_scene_to(difficulty_select_scene)

func _on_MainMenuPanel_settings_pressed() -> void:
	main_menu_panel.slide_out()
	settings_menu_panel.slide_in()

func _on_SettingsMenuPanel_settings_sound_pressed() -> void:
	print_debug("sound changed")

func _on_SettingsMenuPanel_settings_back_pressed() -> void:
	settings_menu_panel.slide_out()
	main_menu_panel.slide_in()
