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
#var weapon = "Big Ass Laser Gun"
var health: int
var speed: int
var grabbing = false
var grabbed_actor

# Detection --------------------------------------------------------------------
var targets = []
onready var light = $Light2D
onready var visibility = $Visibility
var character = preload("res://actors/Character.tscn")

# Sprite preload ---------------------------------------------------------------
#var right = preload("res://assets/player_sprite/player_right.png")
#var left = preload("res://assets/player_sprite/player_left.png")
#var up = preload("res://assets/player_sprite/player_up.png")
#var down = preload("res://assets/player_sprite/player_down.png")
#var right_grab = preload("res://assets/player_sprite/player_right_grab.png")
#var left_grab = preload("res://assets/player_sprite/player_left_grab.png")
#var up_grab = preload("res://assets/player_sprite/player_up_grab.png")
#var down_grab = preload("res://assets/player_sprite/player_down_grab.png")

# Init -------------------------------------------------------------------------

func init_player():
	#curr_tex = "down"
	#changeable_texture = true
	
	
	# Detection
	#detect_radius = DEFAULT_PLAYER_DETECT_RADIUS * game.TILE_SIZE
	#var shape = CircleShape2D.new()
	#shape.radius = detect_radius
	#detection_shape.shape = shape
	#hidden = false
	
	# Info
	health = DEFAULT_PLAYER_MAX_HEALTH
	speed = 5
	#level = DEFAULT_PLAYER_STARTING_LEVEL
	#armor = DEFAULT_PLAYER_ARMOR
	
	#sprite.show()

# Tick -------------------------------------------------------------------------

func take_turn():
	print("Player taking turn!")

func tick():
	pass
	#check_los()

# Raycasting -------------------------------------------------------------------

# Optimizations:
# Check after every corner raycast result
#func check_los():
#	update()
#	var corner_res
#	var space_state = get_world_2d().direct_space_state
#	var tile_len = game.TILE_SIZE
#	var half_tile = tile_len/2
#	var center_of_player = Vector2(position.x + half_tile, position.y + half_tile)
#	for target in targets:
#		var iden = target.unique_id
#		var sightnodeOrEnemy = target.identifier == "sightnode" or target.identifier == "enemy"
#		var raymask = self.collision_mask
#		var exceptarr = [self]
#		# Floor sightnodes are onlyblocked by barriers and light-blocking actors
#		if sightnodeOrEnemy:
#			raymask = 20
#		# Side 1
#		#  and !corner_res.empty() 
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + half_tile, target.position.y), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 2
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + tile_len, target.position.y + half_tile), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 3
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x, target.position.y + half_tile), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 4
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + half_tile, target.position.y + tile_len), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		hide_target(target)

#func show_target(target):
	#target.unshadow()
	
	
#func hide_target(target):
	#target.shadow()
		
# Input ------------------------------------------------------------------------

func _input(event):
	# Return if it is not a press event
	if !event.is_pressed():
		return
	if Input.is_action_just_pressed("debug"):
		#game.darken_tile(curr_tile.x,curr_tile.y)
		game.ticker.print_ticker()
	# Return if it is not the player's turn
	if !has_turn:
		return
	# Record on click
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
#		on_click()
#		return
	# Return if animating movement
	#if(!game.anim_finished):
	#	return
	
	# Movement keys
	if event.is_action_pressed("ui_left"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(-1,0))
			game.ticker.schedule_action(self,speed)
			game.run_until_player_turn()
#		else:
#			match curr_tex:
#				"up":
#					grabbed_actor.drag("drag_left")
#				"down":
#					grabbed_actor.drag("drag_right")
#				"left":
#					grabbed_actor.drag("push")
#				"right":
#					grabbed_actor.drag("pull")
	elif event.is_action_pressed("ui_right"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(1,0))
			game.ticker.schedule_action(self,speed)
			game.run_until_player_turn()
#		else:
#			match curr_tex:
#				"up":
#					grabbed_actor.drag("drag_right")
#				"down":
#					grabbed_actor.drag("drag_left")
#				"left":
#					grabbed_actor.drag("pull")
#				"right":
#					grabbed_actor.drag("push")
	elif event.is_action_pressed("ui_up"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(0,-1))
			game.ticker.schedule_action(self,speed)
			game.run_until_player_turn()
#		else:
#			match curr_tex:
#				"up":
#					grabbed_actor.drag("push")
#				"down":
#					grabbed_actor.drag("pull")
#				"left":
#					grabbed_actor.drag("drag_right")
#				"right":
#					grabbed_actor.drag("drag_left")
	elif event.is_action_pressed("ui_down"):
		if !grabbing:
			game.move_actor_vect(self,Vector2(0,1))
			game.ticker.schedule_action(self,speed)
			game.run_until_player_turn()
#		else:
#			match curr_tex:
#				"up":
#					grabbed_actor.drag("pull")
#				"down":
#					grabbed_actor.drag("push")
#				"left":
#					grabbed_actor.drag("drag_left")
#				"right":
#					grabbed_actor.drag("drag_right")
					
			
	# Grabbing key
#	elif Input.is_action_just_pressed("ui_grab"):
		# If not grabbing, check for grabbable actor and change sprite
#		if !grabbing:
#			var actor_facing = get_actor_facing()
#			if typeof(actor_facing) == 2:
#				game.logg("No grabbable object in front of you.")
#				return
#			if actor_facing.grabbable:
#				grabbing = true
#				grabbed_actor = actor_facing
#				match curr_tex:
#					"right":
#						sprite.set_texture(right_grab)
#					"left":
#						sprite.set_texture(left_grab)
#					"down":
#						sprite.set_texture(down_grab)
#					"up":
#						sprite.set_texture(up_grab)
		# else change sprite back to non-grabbing
#		else:
#			grabbing = false
#			match curr_tex:
#				"right":
#					sprite.set_texture(right)
#				"left":
#					sprite.set_texture(left)
#				"down":
#					sprite.set_texture(down)
#				"up":
#					sprite.set_texture(up)
	
# Game input -------------------------------------------------------------------
	
func die():
	print("Player died :C")

# Signals ----------------------------------------------------------------------

func _on_Visibility_body_entered(_body):
	pass
	# print(body.identifier + " entered")
	#if body.identifier == identifier:
	#	return
	#targets.append(body)
	
func _on_Visibility_body_exited(_body):
	pass
	#if targets and targets.has(body):
	#	targets.erase(body)
	#	hide_target(body)
	
