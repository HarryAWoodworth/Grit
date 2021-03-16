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
	equipment.init(game)
	Combat_Manager.init()
	Center_Of_Player.position = Vector2(game.TILE_SIZE/2,game.TILE_SIZE/2)

# Tick -------------------------------------------------------------------------

func take_turn():
	print("Player taking turn!")

func tick():
	pass

# Combat -----------------------------------------------------------------------

func shoot():
	print("HANDS: " + str(equipment.both_hands))
	
	if !equipment.empty() and equipment.both_hands.type == "ranged":
		Combat_Manager.shoot(get_global_mouse_position(), equipment.both_hands.innacuracy_angle)
		
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
		return true
	return false
	
func has_effect(effect):
	return effects.has(effect)
