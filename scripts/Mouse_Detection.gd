extends Node2D

var game
var mouse_position = null

func init(game_):
	game = game_

func _input(event):
	if event is InputEventMouseMotion:
		print("Mouse motion at " + str(event.position))
		mouse_position = event.position

func _draw():
	draw_line(game.player.position, mouse_position, Color(1,0,0,1))
	draw_circle(mouse_position, 50, Color(1,0,0,1))
	#draw_line(player.position, mouse_position, Color(1,0,0,1))
	#draw_circle(mouse_position, 50, Color(1,0,0,1))
