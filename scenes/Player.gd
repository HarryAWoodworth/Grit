extends Area2D

const DEFAULT_PLAYER_MAX_HEALTH = 50

var identifier = "player"
var curr_tile
var curr_tex = "down"
var changeable_texture = true
onready var tween = $Sprite/Tween
onready var sprite = $Sprite

# Info
var title = "Thunder McDonald"
var health = DEFAULT_PLAYER_MAX_HEALTH
var weapon = "Big Ass Laser Gun"

var right = preload("res://assets/player_sprite/player_right.png")
var left = preload("res://assets/player_sprite/player_left.png")
var up = preload("res://assets/player_sprite/player_up.png")
var down = preload("res://assets/player_sprite/player_down.png")
var right_grab = preload("res://assets/player_sprite/player_right_grab.png")
var left_grab = preload("res://assets/player_sprite/player_left_grab.png")
var up_grab = preload("res://assets/player_sprite/player_up_grab.png")
var down_grab = preload("res://assets/player_sprite/player_down_grab.png")

# Key Booleans
var grabbing = false
var grabbed_actor

func _input(event):
	
	# Record on click
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		on_click()
		return
		
	var game = get_parent().get_parent()
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
			grabbed_actor.drag("drag_left")
	elif event.is_action("ui_right"):
		if !grabbing:
			if game.move_actor(Vector2(1,0),self):
				game.tick()
		else:
			grabbed_actor.drag("drag_right")
	elif event.is_action("ui_up"):
		if !grabbing:
			if game.move_actor(Vector2(0,-1),self):
				game.tick()
		else:
			grabbed_actor.drag("push")
	elif event.is_action("ui_down"):
		if !grabbing:
			if game.move_actor(Vector2(0,1),self):
				game.tick()
		else:
			grabbed_actor.drag("pull")
			
	# Grabbing key
	elif Input.is_action_just_pressed("ui_grab"):
		# If not grabbing, check for grabbable actor and change sprite
		if !grabbing:
			var actor_facing = get_actor_facing(game)
			if typeof(actor_facing) == 2:
				print("No grabbable object in front of you.")
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
			
func get_actor_facing(game):
	#print("Curr Tile: " + str(curr_tile))
	match curr_tex:
		"right":
			#print("Getting actor at " + str(curr_tile.x + 1) + ", " + str(curr_tile.y))
			return game.get_actor_at(curr_tile.x + 1, curr_tile.y)
		"left":
			#print("Getting actor at " + str(curr_tile.x - 1) + ", " + str(curr_tile.y))
			return game.get_actor_at(curr_tile.x - 1, curr_tile.y)
		"down":
			#print("Getting actor at " + str(curr_tile.x) + ", " + str(curr_tile.y + 1))
			return game.get_actor_at(curr_tile.x, curr_tile.y + 1)
		"up":
			#print("Getting actor at " + str(curr_tile.x) + ", " + str(curr_tile.y - 1))
			return game.get_actor_at(curr_tile.x, curr_tile.y - 1)
			
func on_click():
	pass
	
func tick():
	pass
