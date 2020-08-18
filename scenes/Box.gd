extends "res://scenes/Actors.gd"
	
onready var tween = $Sprite/Tween
onready var sprite = $Sprite
	
func init(game, x, y):
	grabbable = true
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
func drag(ID):
	var game = get_parent()
	match ID:
		"drag_right":
			# Drag player and box right
			var diff_vec = player_distance()
			var x = -1 * diff_vec.y
			var y = -1 * diff_vec.x
			var vec = Vector2(x,y)
			if game.can_move(x, y, self) and game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("The box was dragged right.")
				game.tick()
			
		"drag_left":
			# Drag player and box left
			var diff_vec = player_distance()
			var x = diff_vec.y
			var y = diff_vec.x
			var vec = Vector2(x,y)
			if game.can_move(x, y, self) and game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("The box was dragged left.")
				game.tick()
		"push": 
			# Push the box
			var diff_vec = player_distance()
			var x = -1 * diff_vec.x
			var y = -1 * diff_vec.y
			var vec = Vector2(x,y)
			if game.can_move(x, y, self):
				game.move_actor(vec,self)
				game.move_actor(vec,game.player,0)
				game.logg("The box was pushed.")
				game.tick()
		"pull":
			# Pull player and box
			var diff_vec = player_distance()
			var x = diff_vec.x
			var y = diff_vec.y
			var vec = Vector2(x,y)
			if game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("The box was pulled.")
				game.tick()

	
func tick():
	pass
