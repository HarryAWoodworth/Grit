extends "res://scenes/Actors.gd"
	
func init(game, x, y):
	
	moveable = true
	
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
