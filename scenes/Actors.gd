extends Node2D

var sprite_node
var curr_tile
onready var tween = $Sprite/Tween
var moveable = false

func set_curr_tile(coords):
	curr_tile = coords
