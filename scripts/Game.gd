## PATH TO BETA

# >>>>>>> ENEMY / PLAYER INTERACTION
# - Attack/Move Diagonally

# Enemies detect you (broken)
	# A* Pathfinding for enemies
# s Stealth
# @ Sound system
#	- Actions make sound
#	- Sound tile circles
#	- Player can hear sounds
#	- Question mark from sound location
# sl Enemies actually make sounds
# Speed -> How many blocks they can move
# Initiative -> What order they tick in

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

const WINDOW_SIZE = Vector2(1920, 1080)
const TILE_SIZE = 32
const CHUNK_DIMENSION = 16
const MAX_TESTLOG_LENGTH = 10000
#const ANIM_SPEED = 5
#const CANT_MOVE_ANIM_DIST = 2
#const ANIM_SPEED_CANT = 8
#const FOREST_DEPTH = 2
#const MAX_BUILDING_DIMENSION = 8
#const MIN_BUILDING_DIMENSION = 5

enum TILE { Grass, Test, Grasss }
enum Shadow { Shadow }

# Node Refs --------------------------------------------------------------------

onready var ticker = $Ticker
onready var tile_map = $TileMap
onready var shadow_map = $ShadowMap
onready var textlog = $UI/TextLog
onready var actor_info = $UI/ActorInfo
onready var player_info = $UI/PlayerInfo

# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Furniture = preload("res://actors/Furniture.tscn")
var PositionClass = preload("res://scenes/Position.tscn")
var Character = preload("res://actors/Character.tscn")
var Player = preload("res://actors/Player.tscn")
var Wall = preload("res://actors/Wall.tscn")
var SightNode = preload("res://util/SightNode.tscn")

# Texture preloads
var wall_tex = preload("res://assets/wall.png")
var forest_tex = preload("res://assets/forest.png")

# Game State -------------------------------------------------------------------

var player
#var anim_finished = true
# List of actor unique_id 's 
var actor_list = []
# Map of Pos nodes
var map = []
# Increasing number for actor unique id's
var unique_actor_id = 0
# Is the game world running?
var world_running = false

# Ready ------------------------------------------------------------------------

# Init the game
func _ready():
	OS.set_window_size(WINDOW_SIZE)
	randomize()
	# textlog.text = "This is a test!"
	build_chunk()
	
# Actor Movement ------------------------------------------------------------------------

# Checks if an actor can move into a coordinate
func can_move(x, y):
	# Return false if coordinates are off the map
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check if there is an actor that blocks movement in that path
	var actors = map[x][y].actors
	if actors.empty():
		return true
	else:
		return !actors[0].blocks_other_actors

# Move an actor to a coordinate
func move_actor(actor, x ,y):
	if can_move(x,y):
		# Remove the actor from its previous position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
		# Update actor's current tile
		actor.curr_tile = Vector2(x,y)
		# Add it to its new position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.append(actor)
		# Update the actor's node
		actor.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
	
# Move actor using a difference vector
func move_actor_vect(actor, vect):
	move_actor(actor, actor.curr_tile.x + vect.x, actor.curr_tile.y + vect.y)
	
# Return an array of movement vectors to empty spaces around a coordinate
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
	if can_move(x+1,y+1):
		free_spaces.append(Vector2(1,1))
	if can_move(x-1,y-1):
		free_spaces.append(Vector2(-1,-1))
	if can_move(x-1,y+1):
		free_spaces.append(Vector2(-1,1))
	if can_move(x+1,y-1):
		free_spaces.append(Vector2(1,-1))
	return free_spaces

# Tick -------------------------------------------------------------------------

# Call tick on all actors in actor_list in order
func tick():
	update()
	for actor in actor_list:
		actor.tick()

# Actor Combat -----------------------------------------------------------------
	
#func exchange_combat_damage(agressor, defender):
#	defender.take_dmg(agressor.dmg)
	
# Remove an actor from the game
func remove_actor(actor):
	# Remove from actor list
	actor_list.erase(actor)
	# Remove from actor map
	map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
	# Remove node
	remove_child(actor)

# Chunk Generation -------------------------------------------------------------

# Build a chunk
func build_chunk():
	# Start with a blank map
	map.clear()
	# Position var
	var pos
	
	# Init the map with tiles
	for x in range(CHUNK_DIMENSION):
		map.append([])
		for y in range(CHUNK_DIMENSION):
			# Instance/Init a PositionClass node
			pos = PositionClass.instance()
			add_child(pos)
			pos.init_pos(TILE.Test)
			map[x].append(pos)
			# Set the tile map
			tile_map.set_cell(x, y, map[x][y].tile)
			# Add sight node
			add_sight_node(x, y)
#			# Set the chunk's outer edge to forest tiles
#			if x < FOREST_DEPTH or x > CHUNK_DIMENSION-(FOREST_DEPTH+1) or y < FOREST_DEPTH or y > CHUNK_DIMENSION-(FOREST_DEPTH+1):
#				pass#add_wall(x, y, forest_tex,"I'm not traversing those dark woods...")
				
	# Extra walls for testing
	add_wall(6, 4, forest_tex)
	add_wall(8, 4, forest_tex)
	add_wall(6, 5, forest_tex)
	add_wall(8, 5, forest_tex)
	add_wall(6, 6, forest_tex)
	add_wall(8, 6, forest_tex)
	add_wall(6, 7, forest_tex)
	add_wall(8, 7, forest_tex)
	add_wall(6, 8, forest_tex)
	add_wall(8, 8, forest_tex)
	add_wall(5, 8, forest_tex)
	add_wall(4, 8, forest_tex)
	add_wall(3, 8, forest_tex)
	add_wall(9, 8, forest_tex)
	add_wall(10, 8, forest_tex)
	add_wall(11, 8, forest_tex)
	add_wall(5, 3, forest_tex)
	add_wall(6, 3, forest_tex)
	add_wall(6, 2, forest_tex)

	add_wall(6, 4, forest_tex)
	add_wall(8, 4, forest_tex)
	add_wall(10, 4, forest_tex)
	add_wall(12, 4, forest_tex)
	add_wall(14, 4, forest_tex)
	add_wall(6, 6, forest_tex)
	add_wall(8, 6, forest_tex)
	add_wall(10, 6, forest_tex)
	add_wall(12, 6, forest_tex)
	add_wall(14, 6, forest_tex)
	add_wall(6, 8, forest_tex)
	add_wall(8, 8, forest_tex)
	add_wall(10, 8, forest_tex)
	add_wall(12, 8, forest_tex)
	add_wall(14, 8, forest_tex)

	
	# Place Player
	var player_inst = Player.instance()
	add_child(player_inst)
	player_inst.init(self,0,0,"player","Basilisk","...",false,true,false)
	player_inst.init_player()
	actor_list.append(player_inst)
	map[0][0].actors.push_front(player_inst)
	#player_info.list_player_info(player_inst)
	player = player_inst
	
	# Place Enemy
	add_character(0,15,10,
				"monster_classic",
				"enemy",
				"monster",
				"description",
				false,
				true,
				false)

	ticker.init()
	ticker.schedule(player,0)
	world_running = true
	run_until_player_turn()
	
	# Init tick
#	yield(get_tree().create_timer(1.0/ANIM_SPEED),"timeout")
#	tick()

# Running Game -----------------------------------------------------------------

# Call next_turn on the Ticker and incrememnt the ticks if it returns true.
func run_until_player_turn():
	while(ticker.next_turn()):
		ticker.ticks = ticker.ticks + 1
		print("Tick " + str(ticker.ticks))
	player.has_turn = true

# Util -------------------------------------------------------------------------

# Returns true if an actor at the position (x,y) blocks light
func blocksLight(x,y):
	var pos = map[x][y]
	if pos.actors.empty:
		return false
	else:
		return pos.actors[0].blocks_light

# Get actors at position (x,y)
func get_actors_at(x,y):
	if x < 0 or x > map.size()-1 or y < 0 or y > map[0].size()-1:
		return null
	return map[x][y].actors
	
# Set a position at (x,y) with tile type, and update tile_map
func set_tile(x, y, type):
	map[x][y].tile = type
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
	
func add_wall(x,y,texture,identifier="...",title="...",description="...",hidden=false,blocks_other_actors=true,blocks_light=true):
	var wall = Wall.instance()
	add_child(wall)
	wall.init(self,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
	wall.sprite.texture = texture
	# Add wall to map pos
	map[x][y].add_actor(wall)
	
# init(game,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
func add_character(x,y,health=10,ai="none",identifier="...",title="...",description="...",hidden=false,blocks_other_actors=false,blocks_light=false):
	var character = Character.instance()
	add_child(character)
	character.init(self,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
	character.init_character(health,ai)
	# Add character to actor list
	actor_list.append(character)
	# Add character to map Pos
	map[x][y].add_actor(character)
	
# Return an updating unique ID value
func get_unique_id():
	var temp = unique_actor_id
	unique_actor_id = unique_actor_id + 1
	return temp
	
# UI ---------------------------------------------------------------------------

# Log string to textlog
func addLog(string):
	var logLength = textlog.text.length() + string.length()
	# Remove a chunk of the textlog if it gets too long
	if logLength > MAX_TESTLOG_LENGTH:
		textlog.text = textlog.text.substr(int(MAX_TESTLOG_LENGTH - (MAX_TESTLOG_LENGTH/10.0)),logLength)
	textlog.text = textlog.text + "\n" + string

# Display actor data
func display_actor_data(actor):
	actor_info.list_info(actor)
	
# Clear actor data
func clear_actor_data():
	actor_info.clear()
	
