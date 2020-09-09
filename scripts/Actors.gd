extends Node2D

var curr_tile
var curr_tex
var identifier = "actor"
var changeable_texture = false
var grabbable = false
var blocks_light = false
var unique_id

var game

# Info
var title = "..."
var description = "..."
	
# Get the distance between the player and this Actor as a Vector2
func player_distance():
	var player_pos = get_parent().player.curr_tile
	return player_pos - curr_tile
	
# Return true if nodes are adjacent (including diagonal)
func adjacent(node):
	var x = curr_tile.x
	var y = curr_tile.y
	var _x = node.curr_tile.x
	var _y = node.curr_tile.y
	return abs(x - _x) <= 1 and abs(y - _y) <= 1
	