extends Area2D

var identifier = "player"
var curr_tile
var curr_tex = "down"
var changeable_texture = true
onready var tween = $Sprite/Tween
onready var sprite = $Sprite

var right = preload("res://assets/player_sprite/player_right.png")
var left = preload("res://assets/player_sprite/player_left.png")
var up = preload("res://assets/player_sprite/player_up.png")
var down = preload("res://assets/player_sprite/player_down.png")
var right_grab = preload("res://assets/player_sprite/player_right_grab.png")
var left_grab = preload("res://assets/player_sprite/player_left_grab.png")
var up_grab = preload("res://assets/player_sprite/player_up_grab.png")
var down_grab = preload("res://assets/player_sprite/player_down_grab.png")

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		on_click()
	
	var game = get_parent().get_parent()
	
	# Return if animating movement
	if(!game.anim_finished):
		return
	
	# Return if it is not a press event
	if !event.is_pressed():
		return
		
	if event.is_action("ui_left"):
		if game.move_actor(Vector2(-1,0),self):
			game.tick()
	if event.is_action("ui_right"):
		if game.move_actor(Vector2(1,0),self):
			game.tick()
	if event.is_action("ui_up"):
		if game.move_actor(Vector2(0,-1),self):
			game.tick()
	if event.is_action("ui_down"):
		if game.move_actor(Vector2(0,1),self):
			game.tick()
	if event is InputEventKey and event.scancode == KEY_Z:
		print("Z pressed!")
			
func on_click():
	pass
	
func tick():
	pass
