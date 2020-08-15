extends "res://scenes/Actors.gd"
	
func init(game, x, y):
	
	moveable = true
	
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
func _input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			on_click()
			
func on_click():
	print("Box clicked!")
