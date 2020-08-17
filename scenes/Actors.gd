extends Node2D

var sprite_node
var curr_tile
var moveable = false
var changeable_texture = false
	
# Get the distance between the player and this Actor as a Vector2
func player_distance():
	var player_pos = get_parent().player.curr_tile
	return player_pos - curr_tile
