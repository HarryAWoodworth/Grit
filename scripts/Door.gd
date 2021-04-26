extends "res://scripts/Actor.gd"

onready var light_occluder = $LightOccluder2D

var open: bool
var locked: bool
var key: String

func init_door(open_: bool=false, locked_: bool=false, key_:String="nokey"):
	open = open_
	if open:
		blocks_other_actors = false
	locked = locked_
	key = key_
	position.x += 64
	position.y += 64

func open(direction: String):
	open = true
	blocks_other_actors = false
	match direction:
		"fromTop":
			rotation_degrees -= 90
			position.x += game.TILE_SIZE/2
			position.y += game.TILE_SIZE/2
		"fromBottom":
			rotation_degrees += 90
			position.x += game.TILE_SIZE/2
			position.y -= game.TILE_SIZE/2
	
	# Hide occluder
	light_occluder.hide()
	
	# Shrink occluder to inside door
#	var polygon_vector = PoolVector2Array([])
#	var occluderr = OccluderPolygon2D.new()
#	var arr_poly = [Vector2(64,0),Vector2(64,122),Vector2(70,122),Vector2(70,0)]
#	polygon_vector.append_array(arr_poly)
#	occluderr.set_polygon(polygon_vector)
#	light_occluder.set_occluder_polygon(occluderr)

func close():
	open = false
	blocks_other_actors = true
	rotation_degrees += 90
	# Show occluder
	light_occluder.show()

# Return true if the door can be and is locked with the key 
func lock(key_:String) -> bool:
	if !locked and key_ == key:
		locked = true
		return true
	return false

# Set the rotation based on what is next to it
func rotation_set(freespaces):
	if !freespaces.has(Vector2(0,1)):
		self.flip_v = true
	elif !freespaces.has(Vector2(1,0)):
		self.rotation_degrees = 90
	elif !freespaces.has(Vector2(-1,0)):
		self.rotation_degrees = 270
	pass

func try_door(direction) -> bool:
	if locked:
		if game.player_has_key(key):
			locked = false
	if !open:
		open(direction)
		return true
	return true
		
		
