extends Node2D

var game
var half_tile

func _ready():
	# Call _process in every frame
	set_process(true)

func init(game_):
	game = game_
	half_tile = game.TILE_SIZE/2

func _process(_delta):
	update()

func _draw():
	# TODO maybe just remove node if not aiming?
	if game.aiming:
		var mouse_position = get_global_mouse_position()
		draw_line(Vector2(game.player.position.x + half_tile,game.player.position.y + half_tile), mouse_position, Color(1,0,0,1))
		draw_circle(mouse_position, 10, Color(1,0,0,1))

func _input(_event):
	pass   
	#if event is InputEventMouseButton and event.pressed:
	   #game.player.shoot()
