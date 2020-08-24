extends "res://scripts/Actors.gd"

onready var sprite = $Sprite
onready var light_occluder = $LightOccluder2D

var has_description = false

func tick():
	pass

func init(x,y,new_texture,new_description="..."):
	game = get_parent()
	curr_tile = Vector2(x,y)
	sprite.texture = new_texture
	position = curr_tile * game.TILE_SIZE
	
	identifier = "barrier"
	
	if new_description != "...":
		description = new_description
		has_description = true
