extends "res://scripts/Actor.gd"

onready var sprite = $Sprite
onready var light_occluder = $LightOccluder2D

# How many pixels of the wall are visible before the shadow
const VISIBLE_THICKNESS = 30

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
func occluder_set(tilesize, freespaces):
	print("Wall.occluder_set")
	var polygon_vector = PoolVector2Array([])
	var has_left_neighbor = !freespaces.has(Vector2(-1,0))
	var has_lower_neighbor = !freespaces.has(Vector2(0,1))
	var has_right_neighbor = !freespaces.has(Vector2(1,0))
	var has_top_neighbor = !freespaces.has(Vector2(0,-1))
	print("Wall: left=" + str(has_left_neighbor) + " right=" + str(has_right_neighbor) + " top=" + str(has_top_neighbor) + "bottom=" + str(has_lower_neighbor))
	
	# Upper left indented point
	polygon_vector.append(Vector2(VISIBLE_THICKNESS,VISIBLE_THICKNESS))
	# Left neighbor outdent
#	print("Wall has left neighbor: " + str(has_left_neighbor))
	if has_left_neighbor:
		polygon_vector.append(Vector2(0,VISIBLE_THICKNESS))
		polygon_vector.append(Vector2(0,tilesize-VISIBLE_THICKNESS))
	# Lower left indented point
	polygon_vector.append(Vector2(VISIBLE_THICKNESS,tilesize-VISIBLE_THICKNESS))
	# Lower neighbor outdent
	if has_lower_neighbor:
		polygon_vector.append(Vector2(VISIBLE_THICKNESS,tilesize))
		polygon_vector.append(Vector2(tilesize-VISIBLE_THICKNESS,tilesize))
	# Lower right indented point
	polygon_vector.append(Vector2(tilesize-VISIBLE_THICKNESS,tilesize-VISIBLE_THICKNESS))
	# Right neighbor outdent
	if has_right_neighbor:
		polygon_vector.append(Vector2(tilesize,tilesize-VISIBLE_THICKNESS))
		polygon_vector.append(Vector2(tilesize,VISIBLE_THICKNESS))
	# Upper right indented point
	polygon_vector.append(Vector2(tilesize-VISIBLE_THICKNESS,VISIBLE_THICKNESS))
	# Upper neighbor outdent
	if has_top_neighbor:
		polygon_vector.append(Vector2(tilesize-VISIBLE_THICKNESS,0))
		polygon_vector.append(Vector2(VISIBLE_THICKNESS,0))
	print("WALL NEW POLYGON: " + str(polygon_vector))
	
	var occluderr = OccluderPolygon2D.new()
	occluderr.set_polygon(polygon_vector)
	light_occluder.set_occluder_polygon(occluderr)
