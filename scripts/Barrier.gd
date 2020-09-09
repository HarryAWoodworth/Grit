extends "res://scripts/Actors.gd"

onready var sprite = $Sprite
onready var light_occluder = $LightOccluder2D

var has_description = false
var discovered = false

func tick():
	pass

func unshadow():
	hidden = false
	#sprite.modulate = Color(1,1,1)
	sprite.show()
	
func shadow():
	pass
	#sprite.modulate = Color( 0.31, 0.31, 0.31, 1)

func init(x,y,new_texture,new_description="...",new_discovered=false):
	game = get_parent()
	curr_tile = Vector2(x,y)
	sprite.texture = new_texture
	position = curr_tile * game.TILE_SIZE
	
	blocks_light = true
	
	discovered = new_discovered
	
	identifier = "barrier"
	
	if new_description != "...":
		description = new_description
		has_description = true
