extends "res://scripts/Character.gd"

# Constants --------------------------------------------------------------------
const DEFAULT_PLAYER_MAX_HEALTH = 50
const DEFAULT_PLAYER_STARTING_LEVEL = 0
const DEFAULT_PLAYER_ARMOR = 0
const DEFAULT_PLAYER_DETECT_RADIUS = 6

# Player Info ------------------------------------------------------------------
var weapon = "Big Ass Laser Gun"
var grabbing = false
var grabbed_actor

# Detection --------------------------------------------------------------------
var targets = []
onready var light = $Light2D

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
	detect_radius = DEFAULT_PLAYER_DETECT_RADIUS * game.TILE_SIZE
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
	check_los()

# Raycasting -------------------------------------------------------------------

func check_los():
	print("updating los!")
	update()
	var space_state = get_world_2d().direct_space_state
	var tile_len = game.TILE_SIZE
	var half_tile = tile_len/2
	var center_of_player = Vector2(position.x + half_tile, position.y + half_tile)
	hit_pos = []
	for target in targets:
		var iden = target.unique_id
		var corner1 = Vector2(target.position.x + half_tile, target.position.y)
		var corner2 = Vector2(target.position.x + tile_len, target.position.y + half_tile)
		var corner3 = Vector2(target.position.x, target.position.y + half_tile) 
		var corner4 = Vector2(target.position.x + half_tile, target.position.y + tile_len)
		var corner1_res = space_state.intersect_ray(center_of_player, corner1, [self], self.collision_mask)
		var corner2_res = space_state.intersect_ray(center_of_player, corner2, [self], self.collision_mask)
		var corner3_res = space_state.intersect_ray(center_of_player, corner3, [self], self.collision_mask)
		var corner4_res = space_state.intersect_ray(center_of_player, corner4, [self], self.collision_mask)
#		if corner1_res:
#			hit_pos.append(corner1_res.position)
#			if corner1_res.collider.unique_id == iden:
		if (corner1_res and corner1_res.collider.unique_id == iden) or (corner2_res and corner2_res.collider.unique_id == iden) or (corner3_res and corner3_res.collider.unique_id == iden)or (corner4_res and corner4_res.collider.unique_id == iden):
			show_target(target)
		else:
			hide_target(target)
		
		
func _draw():
#	var half_tile = game.TILE_SIZE/2
	draw_circle(Vector2(), detect_radius, vis_color)
#	if targets:
#		for hit_poss in hit_pos:
#			draw_line(Vector2(half_tile,half_tile), (hit_poss - position).rotated(-rotation), laser_color)
#			draw_circle((hit_poss - position).rotated(-rotation), 1, laser_color)

func show_target(target):
	target.sprite.show()
	
func hide_target(target):
	target.sprite.hide()
		
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
	if event.is_action_pressed("ui_left"):
		if !grabbing:
			game.move_actor(Vector2(-1,0),self)
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
	elif event.is_action_pressed("ui_right"):
		if !grabbing:
			game.move_actor(Vector2(1,0),self)
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
	elif event.is_action_pressed("ui_up"):
		if !grabbing:
			game.move_actor(Vector2(0,-1),self)
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
	elif event.is_action_pressed("ui_down"):
		if !grabbing:
			game.move_actor(Vector2(0,1),self)
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
	
	elif Input.is_action_just_pressed("debug"):
		print("Debug!")
		light.visible = !light.visible
		print(game.actor_map)
	
# Game input -------------------------------------------------------------------
	
func die():
	print("Player died :C")

# Signals ----------------------------------------------------------------------

func _on_Visibility_body_entered(body):
	print(str(body.unique_id) + " entered")
	if body.identifier == identifier:
		return
	targets.append(body)
	
func _on_Visibility_body_exited(body):
	print(str(body.unique_id) + " exited")
	if targets and targets.has(body):
		targets.erase(body)
		hide_target(body)
	
