extends "res://scenes/Actors.gd"
	
onready var action_menu = $ActionMenu
onready var drag_menu = $ActionMenu/DragMenu

var menu_open = false
	
func init(game, x, y):
	moveable = true
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
	
func tick():
	# Hide menu on tick
	if menu_open:
		action_menu.hide()
		drag_menu.hide()
		menu_open = false
	
func _input_event(_viewport, event, _shape_idx):
		# Check player is adjacent
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			var diff_vec = player_distance()
			print(diff_vec)
			if (abs(diff_vec.x) == 1 and diff_vec.y == 0) or (abs(diff_vec.y) == 1 and diff_vec.x == 0):
				on_click()
			
func on_click():
	# print("Box clicked!")
	action_menu.clear()
	action_menu.add_item("Open", 1)
	action_menu.add_submenu_item("Drag","DragMenu", 2)
	
	drag_menu.clear()
	drag_menu.add_item("Drag Right", 1)
	drag_menu.add_item("Drag Left", 2)
	drag_menu.add_item("Push", 3)
	drag_menu.add_item("Pull", 4)
	
	action_menu.connect("id_pressed", self, "action_choice")
	drag_menu.connect("id_pressed", self, "drag_choice")
	action_menu.set_position(Vector2(10,10))
	drag_menu.set_position(Vector2(20,20))

	menu_open = true
	action_menu.show()
	
func action_choice(ID):
	match ID:
		1:
			print("Opened Box")
	
func drag_choice(ID):
	match ID:
		1:
			# Drag player and box right
			var diff_vec = player_distance()
			var x = -1 * diff_vec.y
			var y = -1 * diff_vec.x
			get_parent().move_actor(x,y,get_parent().player)
			get_parent().move_actor(x,y,self)
			get_parent().tick()
			
		2:
			# Drag player and box left
			var diff_vec = player_distance()
			var x = diff_vec.y
			var y = diff_vec.x
			get_parent().move_actor(x,y,get_parent().player)
			get_parent().move_actor(x,y,self)
			get_parent().tick()
		3: 
			# Push the box
			var diff_vec = player_distance()
			var x = -1 * diff_vec.x
			var y = -1 * diff_vec.y
			get_parent().move_actor(x,y,self)
			get_parent().tick()
		4:
			# Pull player and box
			var diff_vec = player_distance()
			var x = diff_vec.x
			var y = diff_vec.y
			get_parent().move_actor(x,y,get_parent().player)
			get_parent().move_actor(x,y,self)
			get_parent().tick()
