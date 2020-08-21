## TODO
# More player info
# More enemy info
# Dictionary object for Character creations
# Noticed animation
# Add kinematicBody2D to barrier
# Detect if player is in sight
# Get array of in sight actors

# Long Term
# Weather
# Shooting Effects
# Stealth
# Hiding in Objects

## TODO to beta:
# [2/4] Player character
#	[X] Move
#	[X] Drag
#	[1/2] Fight
#		[X] Melee
#		[] Ranged
#	[] Inventory
# [1/3] Enemies 
#	[] Move towards player
#		[] Detect if in sight
#		[] A* Following
#		[] Out of sight non-following
# 	[X] Fight
#	[] Hover over info
#	[] Corpse
#		[] Drop items
# [] Combat
#	[] Visual effect
#	[] Sound effect
# [] Inventory system
#	[] Drop Items
#	[] Use Items
#	[] Equip Items
# [] Items
#	[] Open furniture
# [] Weapons
#	[] Degredation
#	[] Unique visual effect?
# [] Bunker
# [] Random world gen
#	[] Buildings
#	[] Items
# [] Permadeath

## Extra special TODO
# Better, sharper fonts
# Colors in textlog
# Animation shaking head 'no' when command does nothing
# Pathfinding double click auto move

extends Node2D

# Consts -----------------------------------------------------------------------

const TILE_SIZE = 16
const ANIM_SPEED = 5
const CANT_MOVE_ANIM_DIST = 2
const ANIM_SPEED_CANT = 8
const CHUNK_DIMENSION = 16
const FOREST_DEPTH = 2
const MAX_BUILDING_DIMENSION = 8
const MIN_BUILDING_DIMENSION = 5
const MAX_TESTLOG_LENGTH = 10000

enum Tile { Wall, Unknown, Box, Grass, Forest, Opening, Goal }

# Node Refs --------------------------------------------------------------------

onready var tile_map = $TileMap
onready var textlog = $UI/TextLog
onready var actor_info = $UI/ActorInfo
onready var player_info = $UI/PlayerInfo

# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Box = preload("res://actors/Box.tscn")
var Character = preload("res://actors/Character.tscn")
var Player = preload("res://actors/Player.tscn")
var Barrier = preload("res://actors/Barrier.tscn")

# Texture preloads
var wall_tex = preload("res://assets/wall.png")
var forest_tex = preload("res://assets/forest.png")

# Game State -------------------------------------------------------------------

var player
var anim_finished = true
var actor_list = []
var map = []
var buildings = []
var actor_map = []

# Ready ------------------------------------------------------------------------

# Init the game
func _ready():
	OS.set_window_size(Vector2(1280, 720))
	randomize()
	textlog.text = "This is a test!"
	build_chunk()
	
# Actor Movement ------------------------------------------------------------------------

# Checks if actor can move using a difference vector
func can_move(dx, dy, node, check_for_another_actor=true):
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	# Check x and y are in map
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check that actor_type is valid
	if check_for_another_actor:
		var actor_type = actor_map[x][y]
		if typeof(actor_type) != 2:
			if actor_type.identifier == "barrier" and actor_type.has_description:
				logg(actor_type.description)
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
				
	# Coords
	var dx = vector.x
	var dy = vector.y
	var temp_x = node.curr_tile.x
	var temp_y = node.curr_tile.y
	var x = node.curr_tile.x + dx
	var y = node.curr_tile.y + dy
	
	# Melee combat via running into enemy
	var actor_adjacent = get_actor_at(x,y)
	if typeof(actor_adjacent) != 2:
		if (node.identifier == "player" and actor_adjacent.identifier == "enemy") or (node.identifier == "enemy" and actor_adjacent.identifier == "player"):
			exchange_combat_damage(node, actor_adjacent)
			cant_move_anim(dx,dy,node)
			return true
	
	if can_move(dx, dy, node):
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

# Call tick on all actors in actor_list
func tick():
	for actor in actor_list:
		actor.tick()

# Actor Combat -----------------------------------------------------------------
		
func exchange_combat_damage(agressor, defender):
	defender.take_dmg(agressor.dmg)
	
func remove_node(node):
	# Remove from actor_list
	actor_list.erase(node)
	# Remove from actor_map
	actor_map[node.curr_tile.x][node.curr_tile.y] = 0
	# Remove child from parent
	remove_child(node)
		
# UI ---------------------------------------------------------------------------

# Log string to textlog
func logg(string):
	var strlen = textlog.text.length()
	if strlen > MAX_TESTLOG_LENGTH:
		textlog.text = textlog.text.substr(int(MAX_TESTLOG_LENGTH - (MAX_TESTLOG_LENGTH/10.0)),strlen)
	textlog.text = textlog.text + "\n" + string

# Display actor data
func display_actor_data(actor):
	actor_info.list_info(actor)
	
# CLear actor data
func clear_actor_data():
	actor_info.clear()

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
			map[x].append(Tile.Grass)
			tile_map.set_cell(x, y, Tile.Goal)
			# Set the chunk's outer edge to forest tiles
			if x < FOREST_DEPTH or x > CHUNK_DIMENSION-(FOREST_DEPTH+1) or y < FOREST_DEPTH or y > CHUNK_DIMENSION-(FOREST_DEPTH+1):
				add_barrier(x, y, forest_tex,"I'm not traversing those dark woods...")
				
	# Extra walls for testing
	add_barrier(2, 8, wall_tex)
	add_barrier(3, 8, wall_tex)
	add_barrier(4, 8, wall_tex)
	add_barrier(4, 8, wall_tex)
	add_barrier(5, 8, wall_tex)
	add_barrier(6, 8, wall_tex)
	add_barrier(7, 8, wall_tex)
	
	# Place Player
	var player_start_coord = round(CHUNK_DIMENSION/2.0)
	var player_inst = Player.instance()
	add_child(player_inst)
	player_inst.init(self,
				player_start_coord,player_start_coord,
				"player",
				"Thunder Magee",
				"...",
				"none",
				true)
	
	
	#player.position = player.curr_tile * TILE_SIZE
	actor_list.append(player_inst)
	actor_map[player_start_coord][player_start_coord] = player_inst
	player_info.list_player_info(player_inst)
	player = player_inst
	
	# Place Box
	var box_x = 4
	var box_y = 10
	var box = Box.instance()
	box.init(self,box_x,box_y)
	add_child(box)
	actor_list.append(box)
	actor_map[box_x][box_y] = box
	
	# Place Enemy
	add_character(13,2,
				"enemy",
				"Mutant Crab",
				"A 6 foot tall mutant crab is hungry for blood. Your blood. What's a crab doing in the middle of the forest? Who knows...",
				"monster_classic",
				false,
				"down",
				0,
				150,
				1)
	
# Util -------------------------------------------------------------------------
	
# Get actor at coords
func get_actor_at(x,y):
	if x < 0 or x > actor_map.size()-1 or y < 0 or y > actor_map[0].size()-1:
		print("No actor there")
		return 0
	#print("actor_map[" + str(x) + "][" + str(y) + "]: " + str(actor_map[x][y]))
	return actor_map[x][y]
	
# Set a tile at (x,y) with tile type
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)
	
func set_texture(texture, node):
	node.sprite.set_texture(texture)
	
func add_character(x,y,identifier,name,descr,ai,change_tex,start_tex,level,health,armor):
	var character = Character.instance()
	add_child(character)
	character.init(self,x,y,identifier,name,descr,ai,change_tex,start_tex,level,health,armor)
	actor_list.append(character)
	actor_map[x][y] = character
	
func add_barrier(x,y,texture,descr="..."):
	var barrier = Barrier.instance()
	add_child(barrier)
	barrier.init(x,y,texture,descr)
	actor_map[x][y] = barrier
	
