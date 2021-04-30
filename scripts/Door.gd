extends "res://scripts/Actor.gd"

onready var light_occluder = $LightOccluder2D

var opened: bool
var locked: bool
var key: String
var rotated = false

func init_door(opened_: bool=false, locked_: bool=false, key_:String="nokey"):
	opened = opened_
	if opened:
		blocks_other_actors = false
	locked = locked_
	key = key_
	# Move door to tile
	# Cant set position in base scene because it needs to be centered
	position.x += 64
	position.y += 64

func open(direction: String):
	opened = true
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
		"fromRight":
			rotation_degrees += 90
			position.x -= game.TILE_SIZE/2
			position.y -= game.TILE_SIZE/2
		"fromLeft":
			rotation_degrees -= 90
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
	opened = false
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
func rotation_set():
	# Top Wall (Default)
	if game.map[curr_tile.x][curr_tile.y-1].has_wall():
		return
	# Lower Wall, flip
	elif game.map[curr_tile.x][curr_tile.y+1].has_wall():
		self.rotation_degrees = 180
		rotated = true
	# Right Wall, turn 90
	elif game.map[curr_tile.x+1][curr_tile.y].has_wall():
		self.rotation_degrees = 90
		rotated = true
	# Left Wall, turn 270
	elif game.map[curr_tile.x-1][curr_tile.y].has_wall():
		self.rotation_degrees = 270
		rotated = true

func try_door(direction) -> bool:
	if locked:
		if game.player_has_key(key):
			locked = false
	if !opened:
		open(direction)
		return true
	return true
		
		
