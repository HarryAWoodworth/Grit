extends "res://scenes/Actors.gd"

# Child Nodes
onready var tween = $Sprite/Tween
onready var sprite = $Sprite

# Consts 
const DEFAULT_ENEMY_HEALTH = 10
const DEFAULT_ENEMY_TITLE = "..."
const DEFAULT_ENEMY_DESCRIPTION = "..."
const DEFAULT_ENEMY_STATUSES = []
const DEFAULT_ENEMY_EFFECTS = []

# Enemy data
var health
var effect_arr
var status_arr

# Game ref
var game

# Init the enemy
func init(game_ref, x, y,
new_title=DEFAULT_ENEMY_TITLE,
new_description=DEFAULT_ENEMY_DESCRIPTION,
new_health=DEFAULT_ENEMY_HEALTH,
new_status_arr=DEFAULT_ENEMY_STATUSES,
new_effect_arr=DEFAULT_ENEMY_EFFECTS,
can_change_texture=false):
	
	# Set position in game world
	game = game_ref
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
	position = curr_tile * game.TILE_SIZE
	
	# Info
	title = new_title
	description = new_description
	health = new_health
	status_arr = new_status_arr
	effect_arr = new_effect_arr
	changeable_texture = can_change_texture
	
# Tick -------------------------------------------------------------------------

func tick():
	if game.player.curr_tile.x > curr_tile.x and game.can_move(1,0,self):
		game.move_actor(Vector2(1,0),self)
	elif game.player.curr_tile.y > curr_tile.y and game.can_move(0,1,self):
		game.move_actor(Vector2(0,1),self)
	elif game.player.curr_tile.x < curr_tile.x and game.can_move(-1,0,self):
		game.move_actor(Vector2(-1,0),self)
	elif game.player.curr_tile.y < curr_tile.y and game.can_move(0,-1,self):
		game.move_actor(Vector2(0,-1),self)
		
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
	
