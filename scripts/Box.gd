extends "res://scripts/Actors.gd"
	
onready var tween = $Sprite/Tween
onready var sprite = $Sprite
	
func init(game_ref, x, y):
	game = game_ref
	grabbable = true
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
	# Identifier
	identifier = "box"
	
	# Info box stuff
	title = "Blue Test Box"
	description = "This techno blue see-through box doesn't belong in this post apocalyptic waste- oh wait, this is a test forest for development..."

func drag(ID):
	match ID:
		"drag_right":
			# Drag player and box right
			var diff_vec = player_distance()
			var y = -1 * diff_vec.x
			var x = diff_vec.y
			var vec = Vector2(x,y)
			if game.can_move(x, y, self) and game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("The box was dragged right.")
				game.tick()
			else:
				game.cant_move_anim(x,y,self)
				game.cant_move_anim(x,y,game.player)
		"drag_left":
			# Drag player and box left
			var diff_vec = player_distance()
			var x = -1 * diff_vec.y
			var y = diff_vec.x
			var vec = Vector2(x,y)
			if game.can_move(x, y, self) and game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("The box was dragged left.")
				game.tick()
			else:
				game.cant_move_anim(x,y,self)
				game.cant_move_anim(x,y,game.player)
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
			else:
				game.cant_move_anim(x,y,self)
				game.cant_move_anim(x,y,game.player)
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
			else:
				game.cant_move_anim(x,y,self)
				game.cant_move_anim(x,y,game.player)

func tick():
	pass

func _on_Box_mouse_entered():
	game.display_actor_data(self)


func _on_Box_mouse_exited():
	game.clear_actor_data()
