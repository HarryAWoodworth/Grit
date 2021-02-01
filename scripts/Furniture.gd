extends "res://scripts/Actor.gd"
	
#onready var tween = $Sprite/Tween
	
var moveable
	
func init_furniture(moveable_=false):
	moveable = moveable_

func drag(ID):
	match ID:
		"drag_right":
			# Drag player and furniture right
			var diff_vec = player_distance()
			var y = -1 * diff_vec.x
			var x = diff_vec.y
			var vec = Vector2(x,y)
			if game.can_move(x, y, self) and game.can_move(x, y, game.player):
				game.move_actor(vec,game.player,0)
				game.move_actor(vec,self)
				game.logg("You drag the " + title + ".")
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
				game.logg("You drag the " + title + ".")
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
				game.logg("You push the " + title + ".")
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
				game.logg("You pull the " + title + ".")
				game.tick()
			else:
				game.cant_move_anim(x,y,self)
				game.cant_move_anim(x,y,game.player)

func _on_Box_mouse_entered():
	game.display_actor_data(self)


func _on_Box_mouse_exited():
	game.clear_actor_data()
