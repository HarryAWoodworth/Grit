extends Node2D

var sprite_node
var curr_tile
onready var tween = $Sprite/Tween
var moveable = false

func set_curr_tile(coords):
	curr_tile = coords
	
func player_distance():
	var player_pos = get_parent().player.curr_tile
	print("player pos:")
	print(player_pos)
	print("Curr tile:")
	print(curr_tile)
	return player_pos - curr_tile
