extends "res://scripts/Actor.gd"

# Child Nodes
onready var sprite = $Sprite
# onready var tween = $Sprite/Tween
onready var fct_manager = $FCTManager
onready var ai_manager = $AI_Manager
onready var detection_shape = $Visibility/DetectionShape

# Preload anim
var NoticeAnim = preload("res://util/NoticeAnimation.tscn")
var notice_animation

# Consts
const DEFAULT_AI = "none"
const DEFAULT_HEALTH = 10
#const DEFAULT_STATUSES = []
#const DEFAULT_EFFECTS = []
#const DEFAULT_ARMOR = 0
const DEFAULT_DMG = 0
#const DEFAULT_LEVEL = 0

# Detection
const DEFAULT_DETECT_RADIUS = 5
var detect_radius
var target = null
var target_aquired = false
var target_just_aquired = false

# Enemy data
var health
#var armor
#var level
var dmg = 4
#var effect_arr
#var status_arr

# AI
var ai
var ai_tick_callback

# A* AI
var closed_list = []
var open_list = []

# Init the character
func init_character(health_=DEFAULT_HEALTH,ai_=DEFAULT_AI):
	
	ai = ai_
	ai_tick_callback = ai_manager.get_callback(ai)
	health = health_
	
	# Detection
#	hidden = true
	detect_radius = DEFAULT_DETECT_RADIUS * game.TILE_SIZE
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	detection_shape.shape = shape
#	orig_sprite = sprite.texture
#	sprite.hide()
	
	if blocks_light:
		self.collision_layer = 18
	
# Tick -------------------------------------------------------------------------

func tick():
	
	# Remove notice animation
	if has_node("NoticeAnimation") and notice_animation != null:
		target_just_aquired = false
		remove_child(notice_animation)
		
	check_los()
		
	# Ai callback to decide action
	ai_tick_callback.call_funcv([self, game])

# Game util --------------------------------------------------------------------

func take_dmg(num, crit=false):
	#var dmg_taken = (num - armor)
	health = health - num
	fct_manager.show_value(num, crit)
	game.logg(title + " has taken " + str(num) + " dmg.")
	# TODO: Update UI
	if health <= 0:
		die()
		
func die():
	game.remove_node(self)

#func unshadow():
#	hidden = false
#	sprite.show()

#func shadow():
#	hidden = true
#	sprite.hide()

# Get the actor this actor is facing, -1 if no actor is present
#func get_actor_facing():
#	match curr_tex:
#		"right":
#			return game.get_actor_at(curr_tile.x + 1, curr_tile.y)
#		"left":
#			return game.get_actor_at(curr_tile.x - 1, curr_tile.y)
#		"down":
#			return game.get_actor_at(curr_tile.x, curr_tile.y + 1)
#		"up":
#			return game.get_actor_at(curr_tile.x, curr_tile.y - 1)


# Add status to status array if status not already present
#func add_status(status):
#	if status_arr.find(status) == -1:
#		status_arr.append(status)

# Add effect to effect array if effect not already present
#func add_effect(effect):
#	if effect_arr.find(effect) == -1:
#		effect_arr.append(effect)
	
# Remove status from status array
#func remove_status(status):
#	status_arr.erase(status)
	
# Remove effect from effect array
#func remove_effect(effect):
#	effect_arr.erase(effect)
	
# Return if the status is present in status array
#func has_status(status):
#	var found = status_arr.find(status)
#	if found != -1:
#		return true
#	return false
	
# Return if the effect is present in effect array
#func has_effect(effect):
#	var found = effect_arr.find(effect)
#	if found != -1:
#		return true
#	return false
	

# Detection --------------------------------------------------------------------

func check_los():
	var space_state = get_world_2d().direct_space_state
	var tile_len = game.TILE_SIZE
	var half_tile = tile_len/2
	var center = Vector2(position.x + half_tile, position.y+half_tile)
	if target:
		var target_center = Vector2(target.position.x + half_tile, target.position.y+half_tile)
		var result = space_state.intersect_ray(center, target_center, [self], self.collision_mask)
		if result:
			# If the enemy sees a player for the first time, show a notice animation
			if result.collider.identifier == "player" and !target_aquired:
				target_aquired = true
				target_just_aquired = true
				notice_animation = NoticeAnim.instance()
				add_child(notice_animation)
				#var quarter_tile = (game.TILE_SIZE/4)
				notice_animation.sprite.offset = position
				#notice_animation.sprite.offset.x -= quarter_tile
				#notice_animation.sprite.offset.y += quarter_tile
				notice_animation.play("NoticeAnim")
#			elif target_aquired:
#				target_aquired = false

# When a body enters the visibility shape, make it a target if not already
func _on_Visibility_body_entered(body):
	# Check that it is a targetable body
	# var arr_non_targetable = ["barrier","box"]
	if body.identifier != "player":
		return
	target = body

func _on_Visibility_body_exited(body):
	if body == target:
		target = null
		target_aquired = false

# Mouse input data display signals ---------------------------------------------

func _on_Character_mouse_entered():
	game.display_actor_data(self)

func _on_Character_mouse_exited():
	game.clear_actor_data()

