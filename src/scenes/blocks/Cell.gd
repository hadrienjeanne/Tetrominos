extends Node2D

onready var sprite : Sprite = $Sprite
onready var move_tween : Tween = $MoveTween
onready var destroy_animation : AnimatedSprite = $DestroyAnimation
onready var projection_sprite : Sprite = $ProjectionSprite

var available_colors := {
	"blue": "res://src/assets/Cells/size_256/Cell_blue_256.png",
	"brown": "res://src/assets/Cells/size_256/Cell_brown_256.png",
	"green": "res://src/assets/Cells/size_256/Cell_green_256.png",
	"red": "res://src/assets/Cells/size_256/Cell_red_256.png",
	"yellow": "res://src/assets/Cells/size_256/Cell_yellow_256.png",
}

var color : String
var matched := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	change_color()

## randomly changes the color of the cell 
func change_color() -> void:
	var c = randi() % available_colors.size()
	sprite.set_texture(load(available_colors.values()[c]))
	color = available_colors.keys()[c]

## changes the color of the cell by the input string
func choose_color(c: String) -> void:
	if c in available_colors.keys():
		color = c
		sprite.texture = available_colors[c]
	
func move(dir : Vector2) -> void:
	# print_debug("move cell", position, " -> ", dir)
	var _err = move_tween.interpolate_property(self, "position", position, position+dir, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	_err = move_tween.start()

func set_projection_at_row(cell_row: int, cell_col:int, projection_row: int) -> void:
	projection_sprite.position = Vector2(cell_col, (projection_row - cell_row) * Params.cell_size)

func destroy() -> void:
	destroy_animation.visible = true
	sprite.visible = false
	destroy_animation.play("default")
	yield(destroy_animation, "animation_finished")
	queue_free()