extends "res://scenes/Actors.gd"
	
onready var action_menu = $ActionMenu
onready var drag_menu = $ActionMenu/DragMenu
onready var tween = $Sprite/Tween
onready var sprite = $Sprite

var menu_open = false
	
func init(game, x, y):
	grabbable = true
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
#func _input(event):
#		# Check player is adjacent
#		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
#			var diff_vec = player_distance()
#			print(diff_vec)
#			if (abs(diff_vec.x) == 1 and diff_vec.y == 0) or (abs(diff_vec.y) == 1 and diff_vec.x == 0):
#				on_click()
			
#func on_click():
#	# print("Box clicked!")
#	action_menu.clear()
#	action_menu.add_item("Open", 1)
#	action_menu.add_submenu_item("Drag","DragMenu", 2)
#
#	drag_menu.clear()
#	drag_menu.add_item("Drag Right", 1)
#	drag_menu.add_item("Drag Left", 2)
#	drag_menu.add_item("Push", 3)
#	drag_menu.add_item("Pull", 4)
#
#	action_menu.connect("id_pressed", self, "action_choice")
#	drag_menu.connect("id_pressed", self, "drag_choice")
#	action_menu.set_position(Vector2(10,10))
#	drag_menu.set_position(Vector2(20,20))
#
#	menu_open = true
#	action_menu.show()
	
#func action_choice(ID):
#	match ID:
#		1:
#			print("Opened Box")
	
func drag(ID):
	var game = get_parent()
	match ID:
		"drag_right":
			# Drag player and box right
			var diff_vec = player_distance()
			var x = -1 * diff_vec.y
			var y = -1 * diff_vec.x
			var vec = Vector2(x,y)
			game.move_actor(vec,game.player,0)
			game.logg("The box was dragged right.")
			game.move_actor(vec,self)
			game.tick()
			
		"drag_left":
			# Drag player and box left
			var diff_vec = player_distance()
			var x = diff_vec.y
			var y = diff_vec.x
			var vec = Vector2(x,y)
			game.move_actor(vec,game.player,0)
			game.logg("The box was dragged left.")
			game.move_actor(vec,self)
			game.tick()
		"push": 
			# Push the box
			var diff_vec = player_distance()
			var x = -1 * diff_vec.x
			var y = -1 * diff_vec.y
			var vec = Vector2(x,y)
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
			game.move_actor(vec,game.player,0)
			game.move_actor(vec,self)
			game.logg("The box was pulled.")
			game.tick()

	
func tick():
	# Hide menu on tick
	if menu_open:
		action_menu.hide()
		drag_menu.hide()
		menu_open = false
