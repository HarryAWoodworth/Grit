extends Node

var game
var player

func init(game_):
	game = game_
	player = game.player

# Listen for user input
func _input(event):
	# Return if it is not a press event
	if !event.is_pressed():
		return
	## YOUR DEBUG KEY IS }
	if event.is_action_pressed("debug"):
		#for child in game.InventoryScroller.get_node("VBoxContainer").get_children():
		#	print("Child: " + str(child.item))
		player.shoot()
		#player.take_damage(5)
		#game.darken_tile(curr_tile.x,curr_tile.y)
		#game.ticker.print_ticker()
	# Return if it is not the player's turn
	if !player.has_turn:
		return

	### MOVEMENT KEYS
	if event.is_action_pressed("action_button_click"):
			action("click")
	if event.is_action_pressed("move_left"):
			if game.move_actor_vect(player,Vector2(-1,0)):
				action("move")
	elif event.is_action_pressed("move_right"):
			if game.move_actor_vect(player,Vector2(1,0)):
				action("move")
	elif event.is_action_pressed("move_up"):
			if game.move_actor_vect(player,Vector2(0,-1)):
				action("move")
	elif event.is_action_pressed("move_down"):
			if game.move_actor_vect(player,Vector2(0,1)):
				action("move")
	elif event.is_action_pressed("move_up_left"):
			if game.move_actor_vect(player,Vector2(-1,-1)):
				action("move")
	elif event.is_action_pressed("move_up_right"):
			if game.move_actor_vect(player,Vector2(1,-1)):
				action("move")
	elif event.is_action_pressed("move_down_left"):
			if game.move_actor_vect(player,Vector2(-1,1)):
				action("move")
	elif event.is_action_pressed("move_down_right"):
			if game.move_actor_vect(player,Vector2(1,1)):
				action("move")

	### MISC ACTIONS
	elif event.is_action_pressed("action_button_reload"):
		player.equipment.reload()

	### ACTION KEYS
	elif event.is_action_pressed("action_button_equip"):
		action("action_button_equip")
	elif event.is_action_pressed("action_button_move_inv"):
		if event.shift:
			action("action_button_move_inv_spec")
		else:
			action("action_button_move_inv")
	elif event.is_action_pressed("action_button_use"):
		action("action_button_use")
	elif event.is_action_pressed("action_button_use_1"):
		action("action_button_use_1")
	elif event.is_action_pressed("action_button_use_2"):
		action("action_button_use_2")
	elif event.is_action_pressed("action_button_use_3"):
		action("action_button_use_3")
	elif event.is_action_pressed("action_button_use_4"):
		action("action_button_use_4")
	elif event.is_action_pressed("action_button_use_5"):
		action("action_button_use_5")

# Schedule an action with the game based on a string
func action(action):
	match action:
		"click":
			if game.aiming:
				var tick_count = player.shoot()
				game.ticker.schedule_action(player,tick_count)
				game.run_until_player_turn()
		"move":
			game.ticker.schedule_action(player,player.speed)
			game.run_until_player_turn()
			game.open_loot_tray(game.map[player.curr_tile.x][player.curr_tile.y])
		"action_button_equip":
			helper(action)
		"action_button_move_inv":
			helper(action)
		"action_button_move_inv_spec":
			helper(action)
		"action_button_use":
			helper(action)
		"action_button_use_1":
			helper(action)
		"action_button_use_2":
			helper(action)
		"action_button_use_3":
			helper(action)
		"action_button_use_4":
			helper(action)
		"action_button_use_5":
			helper(action)
				
func helper(action):
	print("Input_Manager.helper(): Using Action Button: " + action)
	game.do_action(action)
	var tick_count = game.InfoPanel.get_ticks(action)
	if tick_count > 0:
		game.ticker.schedule_action(player,tick_count)
		game.run_until_player_turn()
