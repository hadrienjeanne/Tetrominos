extends Node

const cell_size := 64

var rng := RandomNumberGenerator.new()

var available_colors := {}

func _ready() -> void:
    rng.randomize()