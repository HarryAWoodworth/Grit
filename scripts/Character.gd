extends "res://scripts/Actors.gd"

# Child Nodes
onready var tween = $Sprite/Tween
onready var sprite = $Sprite
onready var fct_manager = $FCTManager
onready var ai_manager = $AI_Manager
onready var detection_shape = $Visibility/DetectionShape

# Unknown sprite
var unknown_tex = preload("res://assets/unknown.png")
var orig_sprite

# Preload anim
var NoticeAnim = preload("res://util/NoticeAnimation.tscn")
var notice_animation

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
const DEFAULT_CURR_TEX = "down"
const DEFAULT_LEVEL = 0

# Detection
const DEFAULT_DETECT_RADIUS = 5
const DEFAULT_BLOCKS_LIGHT = false
var detect_radius
var target
var target_aquired = false
var hidden = true
var hidden_last_turn = false

# Enemy data
var health
var armor
var level
var dmg = 4
var effect_arr
var status_arr

# AI
var ai
var ai_tick_callback

# A* AI
var closed_list = []
var open_list = []

# Init the character
func init(game_ref, x, y,new_identifier=DEFAULT_IDENTIFIER,new_title=DEFAULT_TITLE,new_description=DEFAULT_DESCRIPTION,new_ai=DEFAULT_AI,can_change_texture=false,new_curr_tex=DEFAULT_CURR_TEX,new_level=DEFAULT_LEVEL,new_health=DEFAULT_HEALTH,new_armor=DEFAULT_ARMOR,new_blocks_light=DEFAULT_BLOCKS_LIGHT,new_status_arr=DEFAULT_STATUSES,new_effect_arr=DEFAULT_EFFECTS):
	
	# Identifier
	identifier = new_identifier
	
	# AI
	ai = new_ai
	ai_tick_callback = ai_manager.get_callback(ai)
	
	# Game ref
	game = game_ref
	
	# Set position in game world
	curr_tile = Vector2(x,y)
	position = curr_tile * game.TILE_SIZE
	curr_tex = new_curr_tex
	
	# Info
	title = new_title
	description = new_description
	level = new_level
	health = new_health
	armor = new_armor
	status_arr = new_status_arr
	effect_arr = new_effect_arr
	changeable_texture = can_change_texture
	
	# Detection
	detect_radius = DEFAULT_DETECT_RADIUS * game.TILE_SIZE
	blocks_light = new_blocks_light
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	detection_shape.shape = shape
	orig_sprite = sprite.texture
	sprite.hide()
	
	if blocks_light:
		self.collision_layer = 18
	
# Tick -------------------------------------------------------------------------

func tick():
	
	# Remove notice animation
	if has_node("NoticeAnimation") and notice_animation != null:
		remove_child(notice_animation)
		
	if hidden_last_turn:
		hidden_last_turn = false
		hidden = true
	elif hidden:
		sprite.hide()
		
	check_los()
		
	# Ai callback to decide action
	ai_tick_callback.call_funcv([self, game])
	
func check_los():
	var space_state = get_world_2d().direct_space_state
	var tile_len = game.TILE_SIZE
	var half_tile = tile_len/2
	var center = Vector2(position.x + half_tile, position.y+half_tile)
	if target:
		var target_center = Vector2(target.position.x + half_tile, target.position.y+half_tile)
		var result = space_state.intersect_ray(center, target_center, [self], self.collision_mask)
		if result:
			if result.collider.identifier == "player":
				if !target_aquired:
						target_aquired = true
						notice_animation = NoticeAnim.instance()
						add_child(notice_animation)
						var quarter_tile = (game.TILE_SIZE/4)
						notice_animation.sprite.offset = position
						notice_animation.sprite.offset.x -= quarter_tile
						notice_animation.sprite.offset.y += quarter_tile
						notice_animation.play("NoticeAnim")
			else:
				if target_aquired:
					target_aquired = false
	
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

func unshadow():
	hidden = false
	sprite.texture = orig_sprite
	sprite.show()
	
func shadow():
	if hidden:
		return
	hidden_last_turn = true
	sprite.texture = unknown_tex

# Get the actor this actor is facing, -1 if no actor is present
func get_actor_facing():
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

# When a body enters the visibility shape, make it a target if not already
func _on_Visibility_body_entered(body):
	# Check that it is a targetable body
	var arr_non_targetable = ["barrier","box"]
	if body.identifier == identifier or arr_non_targetable.has(body.identifier) or target:
		return
	target = body
	
func _on_Visibility_body_exited(body):
	if body == target:
		target = null
		target_aquired = false
	
func _on_Character_mouse_entered():
	game.display_actor_data(self)
	
func _on_Character_mouse_exited():
	game.clear_actor_data()
	
