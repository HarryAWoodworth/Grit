extends "res://scripts/Actors.gd"

# Child Nodes
onready var tween = $Sprite/Tween
onready var sprite = $Sprite
onready var fct_manager = $FCTManager
onready var ai_manager = $AI_Manager
onready var detection_shape = $Visibility/DetectionShape

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
const DEFAULT_BLOCKSLOS = false

# Detection
const DEFAULT_DETECT_RADIUS = 5
var detect_radius
var vis_color = Color(.867, .91, .247, 0.1)
var target
var follow = true
var hit_pos = Vector2(0,0)
var laser_color = Color(0, 0, 0.7)
var blockslos
var notice_animation_playing = false

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

# Init the character
func init(game_ref, x, y,
new_identifier=DEFAULT_IDENTIFIER,
new_title=DEFAULT_TITLE,
new_description=DEFAULT_DESCRIPTION,
new_ai=DEFAULT_AI,
can_change_texture=false,
new_curr_tex=DEFAULT_CURR_TEX,
new_level=DEFAULT_LEVEL,
new_health=DEFAULT_HEALTH,
new_armor=DEFAULT_ARMOR,
new_status_arr=DEFAULT_STATUSES,
new_effect_arr=DEFAULT_EFFECTS,
new_blockslos=DEFAULT_BLOCKSLOS):
	
	# Identifier
	identifier = new_identifier
	
	# AI
	ai = new_ai
	ai_tick_callback = ai_manager.get_callback(ai)
	
	# Game ref
	game = game_ref
	
	# Set position in game world
	curr_tile = Vector2(x,y)
	game.actor_map[x][y] = sprite_node
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
	blockslos = new_blockslos
	
	# Detection
	if blockslos:
		self.collision_mask = 4
	
	if identifier != "player":
		detect_radius = DEFAULT_DETECT_RADIUS * game.TILE_SIZE
		print("Detect radius: " + str(detect_radius))
		sprite.self_modulate = Color(0.2, 0, 0)
		var shape = CircleShape2D.new()
		shape.radius = detect_radius
		detection_shape.shape = shape
	
# Tick -------------------------------------------------------------------------

func tick():
	# Stop the notice animation after tick
	if notice_animation_playing:
		notice_animation_playing = false
		notice_animation.stop()
	# Ai callback to decide action
	ai_tick_callback.call_funcv([self, game])
	
func _physics_process(_delta):
	# Call _draw()
	update()
	# Draw a ray to target
	if target:
		var space_state = get_world_2d().direct_space_state
		# Send the ray out from the middle of the actor to the middle of the target
		var half_tile = game.TILE_SIZE/2
		var offset_pos = Vector2(position.x + half_tile, position.y + half_tile)
		var offset_target_pos = Vector2(target.position.x + half_tile, target.position.y + half_tile)
		var result = space_state.intersect_ray(offset_pos, offset_target_pos, [self], self.collision_mask)
		# If it hits something, record the hit position
		if result:
			hit_pos = result.position
			# If the actor hit is the player make the sprite red
			if result.collider.identifier == "player":
				laser_color = Color(1,0,0)
			else:
				laser_color = Color(0,0,1)
		
func _draw():
	var half_tile = game.TILE_SIZE/2
	var offset_pos = Vector2(half_tile, half_tile)
	if identifier != "player":
		draw_circle(Vector2(8,8), detect_radius, vis_color)
		if target:
			draw_line(offset_pos, (hit_pos - position).rotated(-rotation), laser_color)
			draw_circle((hit_pos - position).rotated(-rotation), 1, laser_color)
	
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

func _on_Enemy_mouse_entered():
	game.display_actor_data(self)

func _on_Enemy_mouse_exited():
	game.clear_actor_data()

# When a body enters the visibility shape, make it a target if not already
func _on_Visibility_body_entered(body):
	# Check that it is a targetable body
	var arr_non_targetable = ["barrier","box"]
	if body.identifier == identifier or arr_non_targetable.has(body.identifier) or target:
		return
	# Log and set
	game.logg(title + " has spotted " + body.title + "!")
	target = body
	# Play notice animation if it is the player
	if target.identifier == "player":
		notice_animation_playing = true
		notice_animation = NoticeAnim.instance()
		add_child(notice_animation)
		notice_animation.play("NoticeAnim")


func _on_Visibility_body_exited(body):
	if body == target:
		target = null
		print("No more target")
		sprite.self_modulate.r = 0.2
		
