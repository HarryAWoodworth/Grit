extends "res://scenes/Actors.gd"

# Child Nodes
onready var tween = $Sprite/Tween
onready var sprite = $Sprite
onready var fct_manager = $FCTManager
onready var ai_manager = $AI_Manager

# Consts 
const DEFAULT_AI = "none"
const DEFAULT_IDENTIFIER = "..."
const DEFAULT_HEALTH = 10
const DEFAULT_TITLE = "..."
const DEFAULT_DESCRIPTION = "..."
const DEFAULT_STATUSES = []
const DEFAULT_EFFECTS = []
const DEFAULT_ARMOR = 0
const DEFAULT_DMG = 0
const DEFAULT_CURR_TEXT = "down"
const DEFAULT_LEVEL = 0

# Enemy data
var health
var armor
var dmg = 4
var effect_arr
var status_arr

# AI
var ai
var ai_tick_callback

# Game ref
var game

# Init the character
func init(game_ref, x, y,
new_identifier=DEFAULT_IDENTIFIER,
new_title=DEFAULT_TITLE,
new_description=DEFAULT_DESCRIPTION,
new_ai=DEFAULT_AI,
can_change_texture=false,
new_curr_text=DEFAULT_CURR_TEXT,
new_level=DEFAULT_LEVEL,
new_health=DEFAULT_HEALTH,
new_armor=DEFAULT_ARMOR,
new_status_arr=DEFAULT_STATUSES,
new_effect_arr=DEFAULT_EFFECTS):
	
	# Identifier
	identifier = new_identifier
	
	# AI
	ai_tick_callback = ai_manager.get_callback(ai)
	
	# Game ref
	game = get_parent()
	
	# Set position in game world
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
	# Info
	title = new_title
	description = new_description
	health = new_health
	armor = new_armor
	status_arr = new_status_arr
	effect_arr = new_effect_arr
	changeable_texture = can_change_texture
	
# Tick -------------------------------------------------------------------------

# Follow the player
func tick():
	ai_tick_callback.call_func(self)
		
func take_dmg(num, crit=false):
	var dmg_taken = (num - armor)
	health = health - dmg_taken
	fct_manager.show_value(dmg_taken, crit)
	game.logg(title + " has taken " + str(dmg_taken) + " dmg. Health is now " + str(health))
	# TODO: Update UI
	if health <= 0:
		die()
		
func die():
	game.remove_node(self)
	
# Data setters -----------------------------------------------------------------
	
# Set a new sprite
func set_sprite(sprite_tex):
	sprite.texture = sprite_tex
	
# Set a new title
func set_title(new_title):
	title = new_title
	
# Set a new description
func set_description(new_description):
	description = new_description
	
# Game util --------------------------------------------------------------------

# Get the actor this actor is facing, -1 if no actor is present
func get_actor_facing(game):
	match curr_tex:
		"right":
			return game.get_actor_at(curr_tile.x + 1, curr_tile.y)
		"left":
			return game.get_actor_at(curr_tile.x - 1, curr_tile.y)
		"down":
			return game.get_actor_at(curr_tile.x, curr_tile.y + 1)
		"up":
			return game.get_actor_at(curr_tile.x, curr_tile.y - 1)
	
# Effect and status util -------------------------------------------------------	

# Add status to status array if status not already present
func add_status(status):
	if status_arr.find(status) == -1:
		status_arr.append(status)

# Add effect to effect array if effect not already present
func add_effect(effect):
	if effect_arr.find(effect) == -1:
		effect_arr.append(effect)
	
# Remove status from status array
func remove_status(status):
	status_arr.erase(status)
	
# Remove effect from effect array
func remove_effect(effect):
	effect_arr.erase(effect)
	
# Return if the status is present in status array
func has_status(status):
	var found = status_arr.find(status)
	if found != -1:
		return true
	return false
	
# Return if the effect is present in effect array
func has_effect(effect):
	var found = effect_arr.find(effect)
	if found != -1:
		return true
	return false
	
# Mouse input data display signals ---------------------------------------------

func _on_Enemy_mouse_entered():
	get_parent().display_actor_data(self)

func _on_Enemy_mouse_exited():
	get_parent().clear_actor_data()
