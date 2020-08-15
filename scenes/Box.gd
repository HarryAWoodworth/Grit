extends "res://scenes/Actors.gd"
	
onready var action_menu = $ActionMenu
var menu_open = false
	
func init(game, x, y):
	moveable = true
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
func tick():
	print("Box ticked!")
	# Hide menu on tick
	if menu_open:
		action_menu.hide()
		menu_open = false
	
func _input_event(viewport, event, shape_idx):
		# Check player is adjacent
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			var diff_vec = player_distance()
			print(diff_vec)
			if (abs(diff_vec.x) == 1 and diff_vec.y == 0) or (abs(diff_vec.y) == 1 and diff_vec.x == 0):
				on_click()
			
func on_click():
	# print("Box clicked!")
	action_menu.clear()
	action_menu.add_item("Push", 1)
	action_menu.add_item("Pull", 2)
	action_menu.add_item("Open", 3)
	action_menu.set_position(Vector2(10,10))
	action_menu.connect("id_pressed", self, "menu_choice")
	menu_open = true
	action_menu.show()
	
func menu_choice(ID):
	match ID:
		1:
			print("Pushed Box")
			get_parent().tick()
		2:
			print("Pulled Box")
			get_parent().tick()
		3:
			print("Opened Box")
	
