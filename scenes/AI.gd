extends Node2D

# Game ref
var game = get_parent()

# AI's -------------------------------------------------------------------------

# AI types
var none = funcref(self, "none")
var monster_classic = funcref(self, "monster_classic")

func none():
	pass

# Monster Classic AI
func monster_classic(node):
	if game.player.curr_tile.x > node.curr_tile.x and game.can_move(1,0,node,false):
		game.move_actor(Vector2(1,0),node)
	elif game.player.curr_tile.x < node.curr_tile.x and game.can_move(-1,0,node,false):
		game.move_actor(Vector2(-1,0),node)
	elif game.player.curr_tile.y >  node.curr_tile.y and game.can_move(0,1,node,false):
		game.move_actor(Vector2(0,1),node)
	elif game.player.curr_tile.y <  node.curr_tile.y and game.can_move(0,-1,node,false):
		game.move_actor(Vector2(0,-1),node)
		
# Util -------------------------------------------------------------------------
		
# Get the ai tick function based on string name
func get_callback(func_name):
	match func_name:
		"none":
			return none
		"monster_classic":
			return monster_classic
