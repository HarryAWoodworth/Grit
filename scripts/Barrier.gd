extends "res://scripts/Actors.gd"

onready var sprite = $Sprite

var game

func init(x,y,new_texture):
	game = get_parent()
	curr_tile = Vector2(x,y)
	sprite.texture = new_texture
	position = curr_tile * game.TILE_SIZE
