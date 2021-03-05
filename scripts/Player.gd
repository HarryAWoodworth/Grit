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
onready var equipment = $Equipment
onready var Combat_Manager = $Combat_Manager
onready var Center_Of_Player = $Center_Of_Player
var health: int
var max_health: int
var speed: int
var grabbing = false
var grabbed_actor
var effects
var current_weight = 0
var max_weight = 100
var hand_space = 2

# Detection --------------------------------------------------------------------
var targets = []
onready var light = $Light2D
onready var visibility = $Visibility

# Init -------------------------------------------------------------------------

func init_player():
	effects = []
	max_health = DEFAULT_PLAYER_MAX_HEALTH
	health = max_health
	speed = 5
	inventory.init(current_weight,max_weight,game)
	equipment.init(game)
	Combat_Manager.init()
	Center_Of_Player.position = Vector2(game.TILE_SIZE/2,game.TILE_SIZE/2)

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
	## YOUR DEBUG KEY IS }
	if Input.is_action_just_pressed("debug"):
		#for child in game.InventoryScroller.get_node("VBoxContainer").get_children():
		#	print("Child: " + str(child.item))
		take_damage(5)
		#game.darken_tile(curr_tile.x,curr_tile.y)
		#game.ticker.print_ticker()
	# Return if it is not the player's turn
	if !has_turn:
		return
	# Shooting key
	
	# Movement keys
	if event.is_action_pressed("ui_left"):
		if !grabbing:
			if game.move_actor_vect(self,Vector2(-1,0)):
				game.ticker.schedule_action(self,speed)
				game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
				game.run_until_player_turn()
	elif event.is_action_pressed("ui_right"):
		if !grabbing:
			if game.move_actor_vect(self,Vector2(1,0)):
				game.ticker.schedule_action(self,speed)
				game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
				game.run_until_player_turn()
	elif event.is_action_pressed("ui_up"):
		if !grabbing:
			if game.move_actor_vect(self,Vector2(0,-1)):
				game.ticker.schedule_action(self,speed)
				game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
				game.run_until_player_turn()
	elif event.is_action_pressed("ui_down"):
		if !grabbing:
			if game.move_actor_vect(self,Vector2(0,1)):
				game.ticker.schedule_action(self,speed)
				game.open_loot_tray(game.map[curr_tile.x][curr_tile.y])
				game.run_until_player_turn()

# Combat -----------------------------------------------------------------------

func shoot():
	# print("HANDS: " + str(equipment.hands))
	#if !equipment.empty():
	#	Combat_Manager.shoot(get_global_mouse_position(), equipment.selected_item.innacuracy_angle)
	pass
		
func take_damage(dmg):
	health -= dmg
	game.player_health_update_ui(float(health)/float(max_health))
	

# Game Util --------------------------------------------------------------------
	
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
