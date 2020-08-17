extends Area2D

var identifier = "player"
var curr_tile
var curr_tex = "down"
var changeable_texture = true
onready var tween = $Sprite/Tween
onready var sprite = $Sprite

var right = preload("res://assets/player_sprite/player_right.png")
var left = preload("res://assets/player_sprite/player_left.png")
var up = preload("res://assets/player_sprite/player_up.png")
var down = preload("res://assets/player_sprite/player_down.png")
var right_grab = preload("res://assets/player_sprite/player_right_grab.png")
var left_grab = preload("res://assets/player_sprite/player_left_grab.png")
var up_grab = preload("res://assets/player_sprite/player_up_grab.png")
var down_grab = preload("res://assets/player_sprite/player_down_grab.png")

func tick():
	pass

func _input_event(_viewport, event, _shape_idx):
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			on_click()
			
func on_click():
	pass
