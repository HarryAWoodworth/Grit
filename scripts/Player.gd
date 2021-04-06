extends "res://scripts/Actor.gd"

# Constants --------------------------------------------------------------------
const DEFAULT_PLAYER_MAX_HEALTH = 50
const DEFAULT_PLAYER_STARTING_LEVEL = 0
const DEFAULT_PLAYER_ARMOR = 0
const DEFAULT_PLAYER_DETECT_RADIUS = 8

# Game State -------------------------------------------------------------------
var has_turn = false

# Player Info ------------------------------------------------------------------
onready var sprite = $AnimatedSprite
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
	Combat_Manager.init()
	equipment.init(game,self)
	Center_Of_Player.position = Vector2(game.TILE_SIZE/2,game.TILE_SIZE/2)

# Tick -------------------------------------------------------------------------

func take_turn():
	print("Player taking turn!")

func tick():
	pass

# Combat -----------------------------------------------------------------------

func shoot():
	var tick_count = 0
	if !equipment.empty():
		if equipment.both_hands != null and equipment.both_hands.type == "ranged" and equipment.both_hands.current_ammo > 0:
				Combat_Manager.shoot(get_global_mouse_position(), equipment.both_hands.innacuracy_angle)
				equipment.both_hands.current_ammo -= 1
				tick_count = equipment.both_hands.speed
		#else:
		#	if equipment.right_hand != null and equipment.right_hand.type == "ranged" and equipment.right_hand.current_ammo > 0:
		#		print("Player.shoot(): Shooting right hand weapon")
		#		Combat_Manager.shoot(get_global_mouse_position(), equipment.right_hand)
		#		equipment.right_hand.current_ammo -= 1
		#		tick_count = equipment.right_hand.speed
		#	if equipment.left_hand != null and equipment.left_hand.type == "ranged" and equipment.left_hand.current_ammo > 0:
		#		print("Player.shoot(): Shooting left hand weapon")
		#		Combat_Manager.shoot(get_global_mouse_position(), equipment.left_hand)
		#		equipment.left_hand.current_ammo -= 1
		#		if tick_count < equipment.left_hand.speed:
		#			tick_count = equipment.left_hand.speed
	else:
		print("Player.shoot(): Attempting to shoot with empty hands!")
	return tick_count
		
func gain_health(plus):
	health += plus
	game.player_health_update_ui(float(health)/float(max_health))
		
func lose_health(dmg):
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
		print("Removed effect \"" + effect + "\" from Player.")
		return true
	print("Failed to remove effect \"" + effect + "\" from Player, effect not present.")
	return false
	
func has_effect(effect):
	return effects.has(effect)
