## PATH TO BETA

# >>>>>>> ENEMY / PLAYER INTERACTION
# - Attack/Move Diagonally
# Display Player information/equipment
# Remove item.id (dumb)
# Draw item logic chart
# Effect Manager?

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
# - Tile_Lit bool, if a monster sees a tile_lit then it can pathfind to the player?

extends Node2D

# Consts -----------------------------------------------------------------------

const WINDOW_SIZE = Vector2(1920, 1080)
const TILE_SIZE = 128
const CHUNK_DIMENSION = 16
const MAX_TESTLOG_LENGTH = 10000

enum TILE { Test, Wall }
enum Shadow { Shadow }

# Node Refs --------------------------------------------------------------------

onready var ticker = $Ticker
onready var tile_map = $TileMap
onready var shadow_map = $ShadowMap
onready var textlog = $UI/TextLog
onready var item_manager = $Item_Manager
onready var Inventory_UI = $UI/HBoxContainer/Inventory
onready var PosInventory = $UI/HBoxContainer/PosInventory
onready var Mouse_Detection = $Mouse_Detection

# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Furniture = preload("res://actors/Furniture.tscn")
var PositionClass = preload("res://scenes/Position.tscn")
var Monster = preload("res://actors/Monster.tscn")
var Player = preload("res://actors/Player.tscn")
var Wall = preload("res://actors/Wall.tscn")
var SightNode = preload("res://util/SightNode.tscn")
var Item = preload("res://actors/Item.tscn")

# Texture preloads
var forest_tex = preload("res://assets/test_wall.png")

# Game State -------------------------------------------------------------------

var player = null
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
	#OS.set_window_size(WINDOW_SIZE)
	randomize()
	tile_map.cell_quadrant_size = TILE_SIZE
	item_manager.init()
	build_chunk()
	Mouse_Detection.init(self)
	
	### TESTING ###
	#map[2][2].print_pos()
	

		
	
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
	print("Moving to " + str(x) + "," + str(y))
	if can_move(x,y):
		# Remove the actor from its previous position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
		# Update actor's current tile
		actor.curr_tile = Vector2(x,y)
		# Add it to its new position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.append(actor)
		# Update the actor's node
		actor.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
		print("Actor's new position: " + str(actor.position))
		return true
	return false

# Move actor using a difference vector
func move_actor_vect(actor, vect):
	return move_actor(actor, actor.curr_tile.x + vect.x, actor.curr_tile.y + vect.y)

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

# UI ---------------------------------------------------------------------------



# Update -----------------------------------------------------------------------

# Call update on all actors in actor_list in order
#func update():
#	update()
#	for actor in actor_list:
#		actor.tick()
		
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
			pos.init_pos(self, TILE.Test, Vector2(x,y))
			map[x].append(pos)
			# Set the tile map
			tile_map.set_cell(x, y, map[x][y].tile)
			# Add sight node
			add_sight_node(x, y)

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

	add_item("ak_47",0,0)
	add_item("7.62×39mm",2,2)

	### TESTING ###
	#var item_inst1 = Item.instance()
	#item_inst1.init_clone(item_manager.item_dictionary.get("7.62×39mm"))
	#var item_inst2 = Item.instance()
	#item_inst2.init_clone(item_manager.item_dictionary.get("ak_47"))
	#player.equipment.hold_item(item_inst2)
	#player.equipment.print_hands()
	#player.equipment.hold_item(item_inst1)
	#player.equipment.print_hands()
	#player.equipment.hold_item(item_inst1)
	#player.equipment.print_hands()

	ticker.init()
	ticker.schedule_action(player,0)
	world_running = true
	run_until_player_turn()

# Running Game -----------------------------------------------------------------

# Call next_turn on the Ticker and incrememnt the ticks if it returns true.
func run_until_player_turn():
	while(ticker.next_turn()):
		ticker.ticks = ticker.ticks + 1
		#print("Tick " + str(ticker.ticks))
	player.has_turn = true

# Util -------------------------------------------------------------------------

# Remove an actor from the game
func remove_actor(actor):
	# Remove from actor list
	actor_list.erase(actor)
	# Remove from actor map
	map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
	# Remove node
	remove_child(actor)

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
	var character = Monster.instance()
	add_child(character)
	character.init(self,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
	character.init_character(health,ai)
	# Add character to actor list
	actor_list.append(character)
	# Add character to map Pos
	map[x][y].add_actor(character)

# Add item to position. Return false if it failed, true if it succeeded
func add_item(id,x,y):
	# Clone the item from the item manager
	var item_inst = Item.instance()
	var item_from_dict = item_manager.item_dictionary.get(id)
	if item_from_dict == null:
		print("Error: No item found in item_dictionary with ID: \"" + id + "\"")
		return false
	item_inst.init_clone(item_manager.item_dictionary.get(id))
	map[x][y].add_item(item_inst)
	return true

# TODO
func add_item_to_lootable(id,lootable):
	var item_inst = Item.instance()
	item_inst.init_clone(item_manager.item_dictionary.get(id))
	#lootable.add_item(item_inst)

# Return an updating unique ID value
func get_unique_id():
	var temp = unique_actor_id
	unique_actor_id = unique_actor_id + 1
	return temp
	
func load_tex(item):
	return load("res://assets/item_sprites/" + item.id + "_small.png")
	
# UI ---------------------------------------------------------------------------

# Log string to textlog
func addLog(string):
	var logLength = textlog.text.length() + string.length()
	# Remove a chunk of the textlog if it gets too long
	if logLength > MAX_TESTLOG_LENGTH:
		textlog.text = textlog.text.substr(int(MAX_TESTLOG_LENGTH - (MAX_TESTLOG_LENGTH/10.0)),logLength)
	textlog.text = textlog.text + "\n" + string

func open_loot_tray(pos):
	if !pos.items.empty():
		PosInventory.clear()
		var ind = 0
		for item in pos.items.values():
			PosInventory.add_item(item[0].item_name,load_tex(item[0]))
			PosInventory.set_item_metadata(ind,item[0].id)
			ind = ind + 1
		PosInventory.show()
	else:
		PosInventory.hide()


# The user selects an item in their inventory
func _on_Inventory_item_activated(index):
	print("Adding item at index " + str(index))
	var step1 = Inventory_UI.get_item_text(index)
	print("Step 1: " + str(step1))
	var step2 = player.inventory.remove_item_by_name(step1)
	print("Step 2: " + str(step2))
	player.equipment.hold_item(step2)
#	player.equipment.hold_item(
#		player.inventory.remove_item_by_name(
#			Inventory_UI.get_item_text(index)
#		)
#	)
	player.equipment.print_hands()

# The user selects an item from the ground
func _on_PosInventory_item_activated(index):
	var item_to_loot = map[player.curr_tile.x][player.curr_tile.y].loot_item(
			PosInventory.get_item_text(index)
		)
	# Add item to player inventory and remove from pos
	player.inventory.add_item(item_to_loot)
	# Remove item from ground
	PosInventory.remove_item(index)
