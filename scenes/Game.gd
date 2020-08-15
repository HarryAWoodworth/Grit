extends Node2D

const TILE_SIZE = 16
const ANIM_SPEED = 5
const CHUNK_DIMENSION = 15
const FOREST_DEPTH = 2
const MAX_BUILDING_DIMENSION = 8
const MIN_BUILDING_DIMENSION = 5

enum Tile { Wall, Unknown, Box, Grass, Forest, Opening }

# Current Level ----------------------------------------------------------------

var map = []
var buildings = []
var actor_map = []

# Node Refs --------------------------------------------------------------------

onready var tile_map = $TileMap
onready var player = $Actors/Player

var Box = preload("res://actors/Box.tscn")

# Game State -------------------------------------------------------------------

var anim_finished = true
var actor_list = []

# Ready ------------------------------------------------------------------------

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	randomize()
	build_chunk()
	
# Input ------------------------------------------------------------------------

func _input(event):
	
	# Return if animating movement
	if(!anim_finished):
		return
	
	# Return if it is not a press event
	if !event.is_pressed():
		return
		
	if event.is_action("ui_left"):
		move_actor(-1,0,player)
		tick()
	if event.is_action("ui_right"):
		move_actor(1,0,player)
		tick()
	if event.is_action("ui_up"):
		move_actor(0,-1,player)
		tick()
	if event.is_action("ui_down"):
		move_actor(0,1,player)
		tick()

# Move an actor node to a tile
func move_actor(dx, dy, node):
	var temp_x = node.curr_tile.x
	var temp_y = node.curr_tile.y
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	
	var tile_type
	var actor_type
	# Get the tile/ actor on the tile the player is moving to
	if x >= 0 && x < CHUNK_DIMENSION && y >= 0 && y < CHUNK_DIMENSION:
		tile_type = map[x][y]
		actor_type = actor_map[x][y]
		
	if typeof(actor_type) != 2:
		return
		
	match tile_type:
		Tile.Grass:
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
		
func set_anim_done():
	anim_finished = true

# Tick -------------------------------------------------------------------------

func tick():
	for actor in actor_list:
		actor.tick()

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
	
	# Place Player
	var player_start_coords = int(round(CHUNK_DIMENSION/2))
	player.curr_tile = Vector2(player_start_coords,player_start_coords)
	actor_map[player_start_coords][player_start_coords] = player
	player.position = player.curr_tile * TILE_SIZE
	actor_list.append(player)
	
	# Place Box
	var box_x = 7
	var box_y = 7
	var box = Box.instance()
	box.init(self,box_x,box_y)
	add_child(box)
	actor_list.append(box)
	
# Set a tile at (x,y) with tile type
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)

## TODO
## Generate stuff around the chunk
## Prevent generation in meadow area in center
## Investigate why box spawning on player doesnt cause a problem
