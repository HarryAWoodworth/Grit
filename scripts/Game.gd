## PATH TO BETA
# Notification is gone


# ? Action queue?

# >>>>>>> ENEMY / PLAYER INTERACTION
# - Make light-blocking enemies work right
# - Attack Diagonally
# @ A* Pathfinding for enemies
# s Stealth
# @ Sound system
#	- Actions make sound
#	- Sound tile circles
#	- Player can hear sounds
#	- Question mark from sound location
# sl Enemies actually make sounds

# >>>>>> ITEMS, WEAPONS, INVENTORY
# @ Items
# @ Inventory System
#   - Display
#	- Dropping
#	- Using
#   - Dropping
#   - Picking up from ground
# s Corpses
# m Looting furniture
# @ Weapons (Equipping)
#   - Custom sound and visual effects for combat
#	- Gun raycast click and shoot
#   - Shooting effects
# - Crafting

# >>>>>>> ITEM COMBAT
# - Effects

# >>>>>>> UI
# ml Player and Enemy dictionary data
# ml Complete Player and Enemy information
#   sl Better, sharper fonts
#   ml Add Color Text
#	sl Max/min UI

# >>>>>>> WORLD GEN
# - Random generation
#   - Indoor
#   - Outdoor
# - Bunker
#   - Saving

# >>>>>>> CONTENT
# - CONTENT!!!

# >>>>>>> Long Term
# - Day/Night Cycle
#	- Light
#	- Logs
#	- Spawns
#	- Loot Rate
# - Season Cycle
# - Weather
# - Hiding in Objects
# - Multi-tile actors
# - Night brings complete darkness, inhuman horrors, enemies noticing your light source...
#  - Tile_Lit bool, if a monster sees a tile_lit then it can pathfind to the player?

extends Node2D

# Consts -----------------------------------------------------------------------

const TILE_SIZE = 32
const ANIM_SPEED = 5
const CANT_MOVE_ANIM_DIST = 2
const ANIM_SPEED_CANT = 8
const CHUNK_DIMENSION = 16
const FOREST_DEPTH = 2
const MAX_BUILDING_DIMENSION = 8
const MIN_BUILDING_DIMENSION = 5
const MAX_TESTLOG_LENGTH = 10000

enum Tile { Grass, Test, Grasss }
enum Shadow { Shadow }

# Node Refs --------------------------------------------------------------------

onready var tile_map = $TileMap
onready var shadow_map = $ShadowMap
onready var textlog = $UI/TextLog
onready var actor_info = $UI/ActorInfo
onready var player_info = $UI/PlayerInfo

# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Box = preload("res://actors/Box.tscn")
var Character = preload("res://actors/Character.tscn")
var Player = preload("res://actors/Player.tscn")
var Barrier = preload("res://actors/Barrier.tscn")
var SightNode = preload("res://util/SightNode.tscn")

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
var barrier_list = []
var unique_actor_id = 0

# Ready ------------------------------------------------------------------------

# Init the game
func _ready():
	#OS.set_window_size(Vector2(1280, 720))
	randomize()
	textlog.text = "This is a test!"
	build_chunk()
	
# Actor Movement ------------------------------------------------------------------------

# Checks if actor can move using a difference vector
func can_move(x, y, check_for_another_actor=true):
	# Check x and y are in map
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check that actor_type is valid
	if check_for_another_actor:
		var actor_type = actor_map[x][y]
		if typeof(actor_type) != 2:
			return false
	# Return true
	return true

func move_actor_xy(toNodeX, toNodeY, node, turn=1):
	var toNode = Vector2(toNodeX, toNodeY)
	var move_vec = toNode - node.curr_tile
	move_actor(move_vec, node, turn)

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
	
	if can_move(node.curr_tile.x + dx, node.curr_tile.y + dy):
		
		if node.hidden:
			# Update the node's current tile
			node.curr_tile = Vector2(x,y)
			actor_map[temp_x][temp_y] = 0
			actor_map[x][y] = node
			node.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
		# Animate Tween
		else:
			# Set animating bool
			anim_finished = false
			# Start tween
			node.tween.interpolate_property(node, "position", node.curr_tile * TILE_SIZE, (Vector2(x,y) * TILE_SIZE), 1.0/ANIM_SPEED, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			# Set bool that anim is finished using callback
			node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
			# Start tween
			node.tween.start()
			# Update the node's current tile
			node.curr_tile = Vector2(x,y)
			actor_map[temp_x][temp_y] = 0
			actor_map[x][y] = node
			# Wait for the tween to end
			if node.identifier == "player":
				#yield(get_tree().create_timer(1.0/ANIM_SPEED),"timeout")
				# Tick when player is moved
				tick()
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
	
# Return an array of movement vectors to empty spaces around a node
func get_surrounding_empty(x,y):
	var free_spaces = []
	if can_move(x+1,y):
		free_spaces.append(Vector2(1,0))
	if can_move(x-1,y):
		free_spaces.append(Vector2(-1,0))
	if can_move(x,y+1):
		free_spaces.append(Vector2(0,1))
	if can_move(x,y-1):
		free_spaces.append(Vector2(0,-1))
	return free_spaces

# Tick -------------------------------------------------------------------------

# Call tick on all actors in actor_list
func tick():
	update()
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
			map[x].append(Tile.Test)
			tile_map.set_cell(x, y, Tile.Test)
			add_sight_node(x, y)
			# Set the chunk's outer edge to forest tiles
			if x < FOREST_DEPTH or x > CHUNK_DIMENSION-(FOREST_DEPTH+1) or y < FOREST_DEPTH or y > CHUNK_DIMENSION-(FOREST_DEPTH+1):
				pass#add_barrier(x, y, forest_tex,"I'm not traversing those dark woods...")
				
	# Extra walls for testing
	add_barrier(6, 4, forest_tex)
	add_barrier(8, 4, forest_tex)
	add_barrier(6, 5, forest_tex)
	add_barrier(8, 5, forest_tex)
	add_barrier(6, 6, forest_tex)
	add_barrier(8, 6, forest_tex)
	add_barrier(6, 7, forest_tex)
	add_barrier(8, 7, forest_tex)
	add_barrier(6, 8, forest_tex)
	add_barrier(8, 8, forest_tex)
	add_barrier(5, 8, forest_tex)
	add_barrier(4, 8, forest_tex)
	add_barrier(3, 8, forest_tex)
	add_barrier(9, 8, forest_tex)
	add_barrier(10, 8, forest_tex)
	add_barrier(11, 8, forest_tex)

	add_barrier(5, 3, forest_tex)
	add_barrier(6, 3, forest_tex)
	add_barrier(6, 2, forest_tex)

	
	# Place Player
	#var player_start_coord = round(CHUNK_DIMENSION/2.0)
	var player_inst = Player.instance()
	add_child(player_inst)
	player_inst.init(self,
				0,0,
				"player",
				"Thunder Magee",
				"...",
				"none",
				true)
	player_inst.unique_id = get_unique_id()
	#player.position = player.curr_tile * TILE_SIZE
	actor_list.append(player_inst)
	actor_map[0][0] = player_inst
	player_info.list_player_info(player_inst)
	player_inst.init_player()
	player = player_inst
	
	
	# Place Box
#	var box_x = 4
#	var box_y = 10
#	var box = Box.instance()
#	box.init(self,box_x,box_y)
#	add_child(box)
#	actor_list.append(box)
#	actor_map[box_x][box_y] = box
	
	# Place Enemy
	add_character(0,15,
				"enemy",
				"Mutant Crab",
				"A 6 foot tall mutant crab is hungry for blood. Your blood. What's a crab doing in the middle of the forest? Who knows...",
				"monster_classic",
				false,
				"down",
				0,
				15,
				1)
#	add_character(12,2,
#				"enemy",
#				"Mutant Crab",
#				"A 6 foot tall mutant crab is hungry for blood. Your blood. What's a crab doing in the middle of the forest? Who knows...",
#				"monster_classic",
#				false,
#				"down",
#				0,
#				15,
#				1)
	
	# Init tick
	yield(get_tree().create_timer(1.0/ANIM_SPEED),"timeout")
	tick()
	
#	print("TEST")
#	print(str(get_surrounding_empty(4,4)))

# Tile visibility --------------------------------------------------------------


# Returns true if the tile at (x,y) blocks light
func blocksLight(x,y):
	var actor_x_y = actor_map[x][y]
	if typeof(actor_x_y) == 2:
		return false
	if "blocks_light" in actor_x_y:
		return actor_x_y.blocks_light
	return false
	
# Util -------------------------------------------------------------------------
	
# Get actor at coords
func get_actor_at(x,y):
	if x < 0 or x > actor_map.size()-1 or y < 0 or y > actor_map[0].size()-1:
		return 0
	return actor_map[x][y]
	
# Set a tile at (x,y) with tile type
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)

func add_sight_node(x,y):
	var sight_node = SightNode.instance()
	add_child(sight_node)
	sight_node.init(x, y, self)
	sight_node.unique_id = get_unique_id()
	
func darken_tile(x, y):
	shadow_map.set_cell(x, y, Shadow.Shadow)
	
func undarken_tile(x, y):
	shadow_map.set_cell(x, y, -1)
	
func set_texture(texture, node):
	node.sprite.set_texture(texture)
	
func add_character(x,y,identifier,name,descr,ai,change_tex,start_tex,level,health,armor):
	var character = Character.instance()
	add_child(character)
	character.init(self,x,y,identifier,name,descr,ai,change_tex,start_tex,level,health,armor)
	character.unique_id = get_unique_id()
	actor_list.append(character)
	actor_map[x][y] = character
	
func add_barrier(x,y,texture,descr="..."):
	var barrier = Barrier.instance()
	add_child(barrier)
	barrier.init(x,y,texture,descr)
	barrier.unique_id = get_unique_id()
	actor_map[x][y] = barrier
	barrier_list.append(barrier)
	actor_list.append(barrier)
	
func get_unique_id():
	var temp = unique_actor_id
	unique_actor_id = unique_actor_id + 1
	return temp
	
