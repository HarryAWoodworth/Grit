extends Node2D

const TILE_SIZE = 16

const CHUNK_DIMENSION = 20

const FOREST_DEPTH = 2

const MAX_BUILDING_DIMENSION = 8
const MIN_BUILDING_DIMENSION = 5

enum Tile { Wall, Unknown, Box, Grass, Forest, Opening }

# Current Level ----------------------

var map = []
var buildings = []

# Node Refs --------------------------

onready var tile_map = $TileMap
onready var player = $Player

# Game State -------------------------

var player_tile


func _ready():
	OS.set_window_size(Vector2(1280, 720))
	randomize()
	build_chunk()
	
# Input ------------------------------

func _input(event):
	if !event.is_pressed():
		return
		
	if event.is_action("Left"):
		try_move(-1,0)
	if event.is_action("Right"):
		try_move(1,0)
	if event.is_action("Up"):
		try_move(0,-1)
	if event.is_action("Left"):
		try_move(0,1)

func try_move(dx, dy):
	var x = player_tile.x + dx
	var y = player_tile.y + dy
	
	var tile_type = Tile.Wall
	if x >= 0 && x < CHUNK_DIMENSION && y >= 0 && y < CHUNK_DIMENSION:
		tile_type = map[x][y]
		
	match tile_type:
		Tile.Grass:
			player_tile = Vector2(x,y)
			
	update_visuals()
		
	
# Chunk Generation -------------------

# Build a chunk
func build_chunk():
	# Start with a blank map
	buildings.clear()
	map.clear()
	
	# Init the map with tiles
	for x in range(CHUNK_DIMENSION):
		map.append([])
		for y in range(CHUNK_DIMENSION):
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
	player_tile = Vector2(player_start_coords,player_start_coords)
	update_visuals()
	
func update_visuals():
	player.position = player_tile * TILE_SIZE
	
# Set a tile at (x,y) with tile type
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)

## TODO
## Generate stuff around the chunk
## Prevent generation in meadow area in center
