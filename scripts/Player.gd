extends "res://scripts/Character.gd"

# Constants --------------------------------------------------------------------
const DEFAULT_PLAYER_MAX_HEALTH = 50
const DEFAULT_PLAYER_STARTING_LEVEL = 0
const DEFAULT_PLAYER_ARMOR = 0

# Player Info ------------------------------------------------------------------
var weapon = "Big Ass Laser Gun"
var grabbing = false
var grabbed_actor

# Detection --------------------------------------------------------------------
var targets

# Sprite preload ---------------------------------------------------------------
var right = preload("res://assets/player_sprite/player_right.png")
var left = preload("res://assets/player_sprite/player_left.png")
var up = preload("res://assets/player_sprite/player_up.png")
var down = preload("res://assets/player_sprite/player_down.png")
var right_grab = preload("res://assets/player_sprite/player_right_grab.png")
var left_grab = preload("res://assets/player_sprite/player_left_grab.png")
var up_grab = preload("res://assets/player_sprite/player_up_grab.png")
var down_grab = preload("res://assets/player_sprite/player_down_grab.png")

# Init -------------------------------------------------------------------------

func init_player():
	identifier = "player"
	curr_tex = "down"
	changeable_texture = true
	title = "Thunder McDonald"
	
	# Detection
	targets = []
	hit_pos = []
	for _j in range(40):
		hit_pos.append(null)
	detect_radius = DEFAULT_DETECT_RADIUS * game.TILE_SIZE
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	detection_shape.shape = shape
	
	# Info
	health = DEFAULT_PLAYER_MAX_HEALTH
	level = DEFAULT_PLAYER_STARTING_LEVEL
	armor = DEFAULT_PLAYER_ARMOR
	dmg = 5

# Tick -------------------------------------------------------------------------

func tick():
	pass

# Raycasting -------------------------------------------------------------------

func _physics_process(_delta):
	# Call _draw()
	update()
	# Draw rays to targets
	if targets and targets.size() > 0:
		# Space state, half tile, and offset position
		var space_state = get_world_2d().direct_space_state
		var half_tile = game.TILE_SIZE/2
		var offset_pos = Vector2(position.x + half_tile, position.y + half_tile)
		# Loop through targets
		var i = -1
		for target in targets:
			i = i+1
			# Send the ray out from the middle of the player to the middle of the target
			var offset_target_pos = Vector2(target.position.x + half_tile, target.position.y + half_tile)
			# Get the actor hit by the raycast
			var result = space_state.intersect_ray(offset_pos, offset_target_pos, [self], self.collision_mask)
			# If it hits something, record the hit position
			if result:
				hit_pos[i] = result.position
				if result.collider != target:
					hit_pos[i] = result.position
					result.collider.sprite.hide()
				else:
					result.collider.sprite.show()

func _draw():
	var half_tile = game.TILE_SIZE/2
	var offset_pos = Vector2(half_tile, half_tile)
	draw_circle(Vector2(8,8), detect_radius, vis_color)
	if targets and targets.size() > 0:
		var i = -1
		for target in targets:
			i = i+1
			draw_line(offset_pos, (hit_pos[i] - position).rotated(-rotation), laser_color)
			draw_circle((hit_pos[i] - position).rotated(-rotation), 1, laser_color)

# Input ------------------------------------------------------------------------

func _input(event):
	# Record on click
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
#		on_click()
#		return
	# Return if animating movement
	if(!game.anim_finished):
		return
	# Return if it is not a press event
	if !event.is_pressed():
		return
	# Movement keys
	if event.is_action("ui_left"):
		if !grabbing:
			if game.move_actor(Vector2(-1,0),self):
				game.tick()
		else:
			match curr_tex:
				"up":
					grabbed_actor.drag("drag_left")
				"down":
					grabbed_actor.drag("drag_right")
				"left":
					grabbed_actor.drag("push")
				"right":
					grabbed_actor.drag("pull")
	elif event.is_action("ui_right"):
		if !grabbing:
			if game.move_actor(Vector2(1,0),self):
				game.tick()
		else:
			match curr_tex:
				"up":
					grabbed_actor.drag("drag_right")
				"down":
					grabbed_actor.drag("drag_left")
				"left":
					grabbed_actor.drag("pull")
				"right":
					grabbed_actor.drag("push")
	elif event.is_action("ui_up"):
		if !grabbing:
			if game.move_actor(Vector2(0,-1),self):
				game.tick()
		else:
			match curr_tex:
				"up":
					grabbed_actor.drag("push")
				"down":
					grabbed_actor.drag("pull")
				"left":
					grabbed_actor.drag("drag_right")
				"right":
					grabbed_actor.drag("drag_left")
	elif event.is_action("ui_down"):
		if !grabbing:
			if game.move_actor(Vector2(0,1),self):
				game.tick()
		else:
			match curr_tex:
				"up":
					grabbed_actor.drag("pull")
				"down":
					grabbed_actor.drag("push")
				"left":
					grabbed_actor.drag("drag_left")
				"right":
					grabbed_actor.drag("drag_right")
					
			
	# Grabbing key
	elif Input.is_action_just_pressed("ui_grab"):
		# If not grabbing, check for grabbable actor and change sprite
		if !grabbing:
			var actor_facing = get_actor_facing()
			if typeof(actor_facing) == 2:
				game.logg("No grabbable object in front of you.")
				return
			if actor_facing.grabbable:
				grabbing = true
				grabbed_actor = actor_facing
				match curr_tex:
					"right":
						sprite.set_texture(right_grab)
					"left":
						sprite.set_texture(left_grab)
					"down":
						sprite.set_texture(down_grab)
					"up":
						sprite.set_texture(up_grab)
		# else change sprite back to non-grabbing
		else:
			grabbing = false
			match curr_tex:
				"right":
					sprite.set_texture(right)
				"left":
					sprite.set_texture(left)
				"down":
					sprite.set_texture(down)
				"up":
					sprite.set_texture(up)
	
# Game input -------------------------------------------------------------------
	
func die():
	print("Player died :C")

# Signals ----------------------------------------------------------------------

func _on_Visibility_body_entered(body):
	# Check that it is a targetable body
	#var arr_non_targetable = ["barrier","box"]
	#if body.identifier == identifier or arr_non_targetable.has(body.identifier):
	if body.identifier == identifier:
		return
	targets.append(body)
	#print(body.identifier +  " inside!")
	
func _on_Visibility_body_exited(body):
	if targets and targets.has(body):
		targets.erase(body)
		#print(body.identifier +  " outside!")
	
