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
	pass
	#print("Wall hit!")

# Change the occluder based on adjacent walls
func occluder_set():
	var polygon_vector: PoolVector2Array
	if hasUpperLeftNeighbor:
		polygon_vector.append(Vector2(0,0))
	el
	light_occluder.occluder.polygon = polygon_vector
