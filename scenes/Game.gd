## TODO
# UI text log string threshold reduction for performance
# Input button for opening
# Hover over shows actor details

## Extra special TODO
# Animation shaking head 'no' when command does nothing
# Pathfinding double click auto move

extends Node2D

const TILE_SIZE = 16
const ANIM_SPEED = 5
const CANT_MOVE_ANIM_DIST = 2
const ANIM_SPEED_CANT = 8
const CHUNK_DIMENSION = 16
const FOREST_DEPTH = 2
const MAX_BUILDING_DIMENSION = 8
const MIN_BUILDING_DIMENSION = 5

enum Tile { Wall, Unknown, Box, Grass, Forest, Opening }

# Node Refs --------------------------------------------------------------------

onready var tile_map = $TileMap
onready var player = $Actors/Player
onready var textlog = $CanvasLayer/RichTextLabel

var Box = preload("res://actors/Box.tscn")

# Game State -------------------------------------------------------------------

var anim_finished = true
var actor_list = []
var map = []
var buildings = []
var actor_map = []

func get_actor_at(x,y):
	if x < 0 or x > actor_map.size()-1 or y < 0 or y > actor_map[0].size()-1:
		print("No actor there")
		return 0
	#print("actor_map[" + str(x) + "][" + str(y) + "]: " + str(actor_map[x][y]))
	return actor_map[x][y]

# Ready ------------------------------------------------------------------------

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	randomize()
	textlog.text = "This is a test!"
	build_chunk()
	
# Input ------------------------------------------------------------------------

func can_move(dx, dy, node):
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	# Tiles actors cannot move into
	var arr_tile_no_move = [Tile.Forest]
	# Check x and y are in map
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check that tile_type and actor_type are valid
	var tile_type = map[x][y]
	var actor_type = actor_map[x][y]
	if typeof(actor_type) != 2 or arr_tile_no_move.has(tile_type):
		return false
	# Return true
	return true

# Move an actor node to a tile
func move_actor(vector, node, turn=1):
	
	# Set texture
	if turn == 1 and node.changeable_texture:
		match vector:
			Vector2(1,0):
				node.sprite.set_texture(node.right)
				node.curr_tex = "right"
			Vector2(-1,0):
				node.sprite.set_texture(node.left)
				node.curr_tex = "left"
			Vector2(0,-1):
				node.sprite.set_texture(node.up)
				node.curr_tex = "up"
			Vector2(0,1):
				node.sprite.set_texture(node.down)
				node.curr_tex = "down"
				
	var dx = vector.x
	var dy = vector.y
	var temp_x = node.curr_tile.x
	var temp_y = node.curr_tile.y
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	
	if can_move(dx, dy, node):
		var tile_type = map[x][y]
		var actor_type = actor_map[x][y]
		# Set animating bool
		anim_finished = false
		# Start tween
		node.tween.interpolate_property(node, "position", node.curr_tile * TILE_SIZE, Vector2(x,y) * TILE_SIZE, 1.0/ANIM_SPEED, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		# Set bool that anim is finished using callback
		node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
		# Start tween
		node.tween.start()
		# Update node's current tile
		node.curr_tile = Vector2(x,y)
		actor_map[temp_x][temp_y] = 0
		actor_map[x][y] = node
		return true
	
	else: 
		cant_move_anim(dx,dy,node)	
			
# Animate the actor moving halfway into the tile and bouncing back
func cant_move_anim(dx,dy,node):
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	anim_finished = false
	var dest = Vector2(x,y) * TILE_SIZE
	if dx != 0:
		dest.x = dest.x - (dx * (float(TILE_SIZE) / float(CANT_MOVE_ANIM_DIST)))
	if dy != 0:
		dest.y = dest.y - (dy * (float(TILE_SIZE) / float(CANT_MOVE_ANIM_DIST)))
	node.tween.interpolate_property(node, "position", node.curr_tile * TILE_SIZE, dest, 1.0/ANIM_SPEED_CANT, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	node.tween.interpolate_property(node, "position", dest, node.curr_tile * TILE_SIZE, 1.0/ANIM_SPEED_CANT, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,node.tween.get_runtime())
	node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
	node.tween.start()
		
func set_anim_done():
	anim_finished = true

# Tick -------------------------------------------------------------------------

func tick():
	for actor in actor_list:
		actor.tick()
		
func logg(string):
	textlog.text = textlog.text + "\n" + string

# Chunk Generation -------------------------------------------------------------

# Build a chunk
func build_chunk():
	# Start with a blank map
	buildings.clear()
	map.clear()
	actor_map.clear()
	
	# Init the map with tiles
	for x in range(CHUNK_DIMENSION):
		map.append([])
		actor_map.append([])
		for y in range(CHUNK_DIMENSION):
			actor_map[x].append(0)
			# Set the chunk's outer edge to forest tiles
			if x < FOREST_DEPTH or x > CHUNK_DIMENSION-(FOREST_DEPTH+1) or y < FOREST_DEPTH or y > CHUNK_DIMENSION-(FOREST_DEPTH+1):
				map[x].append(Tile.Forest)
				tile_map.set_cell(x, y, Tile.Forest)
			# Set every other tile to default grass
			else:
				map[x].append(Tile.Grass)
				tile_map.set_cell(x, y, Tile.Grass)
	
	# Extra forest tile for testing
	tile_map.set_cell(5, 5, Tile.Forest)
	map[5][5] = Tile.Forest
	
	# Place Player
	var player_start_coords = round(CHUNK_DIMENSION/2.0)
	player.curr_tile = Vector2(player_start_coords,player_start_coords)
	player.position = player.curr_tile * TILE_SIZE
	actor_list.append(player)
	actor_map[player_start_coords][player_start_coords] = player
	
	# Place Box
	var box_x = 7
	var box_y = 7
	var box = Box.instance()
	box.init(self,box_x,box_y)
	add_child(box)
	actor_list.append(box)
	actor_map[box_x][box_y] = box
	
# Set a tile at (x,y) with tile type
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)
	
func set_texture(texture, node):
	node.sprite.set_texture(texture)

## TODO
## Generate stuff around the chunk
## Prevent generation in meadow area in center
## Investigate why box spawning on player doesnt cause a problem
