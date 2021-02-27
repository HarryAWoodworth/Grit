extends "res://scripts/Actor.gd"

onready var sprite = $Sprite
onready var light_occluder = $LightOccluder2D

func unshadow():
	hidden = false
	#sprite.modulate = Color(1,1,1)
	sprite.show()
	
func shadow():
	pass
	#sprite.modulate = Color( 0.31, 0.31, 0.31, 1)

func handle_hit():
	print("Wall hit!")
