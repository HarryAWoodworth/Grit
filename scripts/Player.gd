extends "res://scripts/Actor.gd"

# Constants --------------------------------------------------------------------
const DEFAULT_PLAYER_MAX_HEALTH = 50
const DEFAULT_PLAYER_STARTING_LEVEL = 0
const DEFAULT_PLAYER_ARMOR = 0
const DEFAULT_PLAYER_DETECT_RADIUS = 8

# Game State -------------------------------------------------------------------
var has_turn = false

# Player Info ------------------------------------------------------------------
onready var sprite = $Sprite
onready var inventory = $Inventory
var health: int
var speed: int
var grabbing = false
var grabbed_actor
var effects
var current_weight = 0
var max_weight = 100

# Detection --------------------------------------------------------------------
var targets = []
onready var light = $Light2D
onready var visibility = $Visibility

# Init -------------------------------------------------------------------------

func init_player():
	effects = []
	health = DEFAULT_PLAYER_MAX_HEALTH
	speed = 5
	inventory.init(current_weight,max_weight,game)

# Tick -------------------------------------------------------------------------

func take_turn():
	print("Player taking turn!")

func tick():
	pass


# Raycasting -------------------------------------------------------------------


		
# Input ------------------------------------------------------------------------

func _input(event):
	# Return if it is not a press event
	if !event.is_pressed():
		return
	if Input.is_action_just_pressed("debug"):
		#game.darken_tile(curr_tile.x,curr_tile.y)
		game.ticker.print_ticker()
	# Return if it is not the player's turn
	if !has_turn:
		return
	# Movement keys
	if event.is_action_pressed("ui_left"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(-1,0))
			game.ticker.schedule_action(self,speed)
			game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
			game.run_until_player_turn()
	elif event.is_action_pressed("ui_right"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(1,0))
			game.ticker.schedule_action(self,speed)
			game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
			game.run_until_player_turn()
	elif event.is_action_pressed("ui_up"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(0,-1))
			game.ticker.schedule_action(self,speed)
			game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
			game.run_until_player_turn()
	elif event.is_action_pressed("ui_down"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(0,1))
			game.ticker.schedule_action(self,speed)
			game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
			game.run_until_player_turn()

# Game Util -------------------------------------------------------------------
	
func die():
	print("Player died :C")
	
func add_effect(effect):
	if !effects.has(effect):
		effects.append(effect)
		return true
	return false
	
func remove_effect(effect):
	if effects.has(effect):
		effects.erase(effect)
		return true
	return false
	
func has_effect(effect):
	return effects.has(effect)
