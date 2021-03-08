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
	if Input.is_action_just_pressed("debug"):
		#for child in game.InventoryScroller.get_node("VBoxContainer").get_children():
		#	print("Child: " + str(child.item))
		player.take_damage(5)
		#game.darken_tile(curr_tile.x,curr_tile.y)
		#game.ticker.print_ticker()
	# Return if it is not the player's turn
	if !player.has_turn:
		return

	### MOVEMENT KEYS
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
	### ACTION KEYS
	elif event.is_action_pressed("action_button_use"):
		action("action_button_use")

# Schedule an action with the game based on a string
func action(action):
	match action:
		"move":
			game.ticker.schedule_action(player,player.speed)
			game.run_until_player_turn()
			game.open_loot_tray(game.map[player.curr_tile.x][player.curr_tile.y])
		"action_button_use":
			if game.do_action("action_button_use"):
				game.ticker.schedule_action(player,player.eat_speed)
				game.run_until_player_turn()
