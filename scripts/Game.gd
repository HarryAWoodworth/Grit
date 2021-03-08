
# <<< A0.1 >>>

## TODO:
# [ ] Don't stack unstackable items
# [ ] Implement actions
# [ ] Change Equip from double click to action

## BUGS:
# [ ] Giant texture in bullet equip

## PLAYER INTERACTION
# [ ] Burstfire turn action
# [ ] Reloading Gun (Ammo, removing ammo, turn action)
# [ ] Melee Weapons
# [ ] Melee Combat, turn action
# [ ] Move Diagonally
# [W] Player armor equipment
# [?] What if you made each bullet 1 smal action and kept the aim state? (Would be like shooting moving targets coming at you)

## PLAYER UI
# [W] Display Player information/equipment/inventory
#	{ } Weapon
#   { } Armor 
# [W] Hovering mouse over tile within range displays tile actions
# [ ] Double click on item in inventory to equip
# [ ] Hovering over item in player info box opens it in info box with actions
# [ ] Hovering over item in inventory/ground opens it in info box with actions
# [ ] Implements Item.stacks (in Inventory.gd)
# [ ] Add Weight to UI somewhere (Info box)

## ENVIRONMENT INTERACTION
# [ ] Doors
# [ ] Containers
# [ ] Loot Tables
# [ ] Player can loot container
# [ ] Monster corpses
# [ ] Morning -> Noon -> Evening Cycle

## MONSTERS
# [ ] Check that pathfinding still works
# [ ] Different AI's? (check out bookmarked rougelike AI article)
# [ ] Monster manager from json file
# [ ] Monsters Wander
# [ ] Different Monster actions? Speed for actions?

## SETTINGS
# [ ] Set screen side of UI

## GAME STATE
# [ ] Save Game
# [ ] Load Game

## STEALTH SYSTEM
# [ ] Sound ring when actions are done (based on action/container/door?)
# [ ] Player can throw an item to make noise as a distraction
# [ ] Monsters move towards noises

## ITEMS & CRAFTING
# [ ] Food Items
# [ ] Weapons
# [ ] Crafting
# [ ] Item Recipes
# [ ] Crafting Blueprints (change recipes to need fewer items)
# [ ] Books?
# [ ] Cooking Items
# [ ] Cooking Recipes

## MAP GENERATION
# [ ] Prefabs

## AUDIO
# [ ] Ambient music
# [ ] Weapon sound effects
# [ ] Bullet sound effects

## VISUAL
# [ ] Tune bullet look
# [ ] Fancy color/fonts in logs
# [ ] Fancy color/font in inventory

# <<< A0.2 >>>

## PLAYER AND MONSTER EFFECTS
# [ ] Effect types
# [ ] Effect checks
# [ ] Effect Manager?

## WEATHER
# [ ] Weather Types
# [ ] Seasons (winter - cold buff, etc)
# [ ] Weather Animations
# [ ] Weather Effects

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< A0.3 >>> 

## FARMING
# [ ] Seed Items
# [ ] Farm Plots
# [ ] Harvesting grown plants
# [ ] Seed Splicing

## FLOORS
# [ ] Player can move between floors in buildings (transport to smaller map)

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< A0.4 >>>

## MODULAR WEAPONS
# [ ] Mod weapons with items
# [ ] Redesign gun item
# [ ] Allow hotswap of mods?
# [ ] Hotswap UI
# [ ] Using gun takes into account mods

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
onready var GroundScroller = $UI/GroundScroller
onready var InventoryScroller = $UI/InventoryScroller
onready var InfoPanel = $UI/InfoPanel
onready var Mouse_Detection = $Mouse_Detection
onready var HealthBar = $UI/PlayerInfo/HealthRect
onready var EquippedWeapon1 = $UI/PlayerInfo/EquippedWeapon
onready var EquippedWeapon2 = $UI/PlayerInfo/EquippedWeapon2


# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Furniture = preload("res://actors/Furniture.tscn")
var PositionClass = preload("res://scenes/Position.tscn")
var Monster = preload("res://actors/Monster.tscn")
var Player = preload("res://actors/Player.tscn")
var Wall = preload("res://actors/Wall.tscn")
var SightNode = preload("res://util/SightNode.tscn")
var Item = preload("res://actors/Item.tscn")
var InventorySlot = preload("res://scenes/InventorySlot.tscn")

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

## UI
var health_bar_max

# Ready ------------------------------------------------------------------------

# Init the game
func _ready():
	#OS.set_window_size(WINDOW_SIZE)
	randomize()
	tile_map.cell_quadrant_size = TILE_SIZE
	item_manager.init()
	build_chunk()
	Mouse_Detection.init(self)
	health_bar_max = HealthBar.rect_size.y
	### TESTING ###
	#map[2][2].print_pos()
	

# Actor Movement ------------------------------------------------------------------------

# Checks if an actor can move into a coordinate
func can_move(x, y):
	# Return false if coordinates are off the map
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check if thwwre is an actor that blocks movement in that path
	var actors = map[x][y].actors
	if actors.empty():
		return true
	else:
		return !actors[0].blocks_other_actors

# Move an actor to a coordinate
func move_actor(actor, x ,y):
	#print("Moving to " + str(x) + "," + str(y))
	if can_move(x,y):
		# Remove the actor from its previous position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
		# Update actor's current tile
		actor.curr_tile = Vector2(x,y)
		# Add it to its new position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.append(actor)
		# Update the actor's node
		actor.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
		#print("Actor's new position: " + str(actor.position))
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
			# add_sight_node(x, y)

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

	# Place Dummy
	#x,y,health=10,ai="none",identifier="...",title="...",description="..."
	add_character(2,1,1,"none","enemy","Hay Bale 1","A orange haybale.")
	add_character(2,2,1,"none","enemy","Hay Bale 2","A yellow hay bale.")

	add_item("ak_47",0,1)
	add_item("7.62×39mm",0,1)
	add_item("7.62×39mm",0,1)
	
	add_item("ak_47",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	add_item("7.62×39mm",0,2)
	
	add_item("canned_tuna",0,3)

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
#func blocksLight(x,y):
#	var pos = map[x][y]
#	if pos.actors.empty:
#		return false
#	else:
#		return pos.actors[0].blocks_light

# Get actors at position (x,y)
func get_actors_at(x,y):
	if x < 0 or x > map.size()-1 or y < 0 or y > map[0].size()-1:
		return null
	return map[x][y].actors
	
# Set a position at (x,y) with tile type, and update tile_map
func set_tile(x, y, type):
	map[x][y].tile = type
	tile_map.set_cell(x, y, type)

#func add_sight_node(x,y):
#	var sight_node = SightNode.instance()
#	add_child(sight_node)
#	sight_node.init(x, y, self)
#	sight_node.unique_id = get_unique_id()

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
func add_character(x,y,health=10,ai="none",identifier="...",title="...",description="...",hidden=false,blocks_other_actors=true,blocks_light=false):
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
	
func load_big_tex(item):
	# print("Loading texture from " + item.item_name)
	return load("res://assets/item_sprites/" + item.id + "_big.png")
	
# UI ---------------------------------------------------------------------------

# Log string to textlog
func addLog(string):
	var logLength = textlog.text.length() + string.length()
	# Remove a chunk of the textlog if it gets too long
	if logLength > MAX_TESTLOG_LENGTH:
		textlog.text = textlog.text.substr(int(MAX_TESTLOG_LENGTH - (MAX_TESTLOG_LENGTH/10.0)),logLength)
	textlog.text = textlog.text + "\n" + string

func open_loot_tray(pos):
	# If there are items on the ground, display them in the scroller
	if !pos.items.empty():
		for n in GroundScroller.get_node("VBoxContainer").get_children():
			GroundScroller.get_node("VBoxContainer").remove_child(n)
			n.queue_free()
		for item in pos.items.values():
			# item[0] is the item, item[1] is the count
			var invslot = InventorySlot.instance()
			GroundScroller.get_node("VBoxContainer").add_child(invslot)
			invslot.init(item[0],item[1], self)
		GroundScroller.show()
	# Otherwise hide the scroller
	else:
		GroundScroller.hide()

# Equip item from inventory
func inventory_item_double_clicked(invslot):
	# print("Inventory item " + invslot.item.item_name + " double clicked")
	player.equipment.hold_item(player.inventory.remove_item(invslot.item))

# When the user double clicks an item in the ground list, move it to the player
# inventory and add it as an invslot in the UI
func ground_item_double_clicked(item_name, invslot):
	# Get the item to loot (and remove the item from Pos)
	var item_to_loot = map[player.curr_tile.x][player.curr_tile.y].loot_item(item_name, invslot.num)
	if item_to_loot != null:
		# print("Looting item " + item_to_loot.item_name)
		# Add to player's Inventory and add to Inventory UI
		player.inventory.add_item(item_to_loot, invslot.num)
		# Remove from Ground UI
		GroundScroller.get_node("VBoxContainer").remove_child(invslot)
		# Add to Inventory UI
		# add_new_invslot(invslot.item,invslot.num)
		# var newinvslot = InventorySlot.instance()
		# InventoryScroller.get_node("VBoxContainer").add_child(newinvslot)
		# newinvslot.init(invslot.item,invslot.num,self,false)
		# Free the inventory node
		invslot.queue_free()
	else:
		print("ERROR: Attempted to loot item " + item_name + " but it was not found!")

# Add a new invslot item to the UI inventory list
func add_new_invslot(item, num):
	var newinvslot = InventorySlot.instance()
	InventoryScroller.get_node("VBoxContainer").add_child(newinvslot)
	newinvslot.init(item,num,self,false)

# When an invslot is hovered over, show its info and action list
func show_invslot_info_ui(invslot):
	InfoPanel.hide()
	clearInfoPanel()
	InfoPanel.Icon.texture = load_tex(invslot.item)
	InfoPanel.Icon.show()
	InfoPanel.Description.text = invslot.item.description
	addActionsInfoPanel(invslot)
	# Equip
	# Drop
	# Use
	InfoPanel.show()

func clearInfoPanel():
	InfoPanel.Icon.hide()
	InfoPanel.Description.text = ""
	for child in InfoPanel.ActionGrid.get_children():
		child.queue_free()

func addActionsInfoPanel(invslot):
	var item = invslot.item
	if !invslot.onGround:
		if invslot.num > 1:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ]: Drop All")
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv_spec")[0].as_text() + " ]: Drop 1")
		else:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ]: Drop")
	else:
		if invslot.num > 1:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ]: Pick Up All")
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv_spec")[0].as_text() + " ]: Pick Up 1")
		else:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ]: Pick Up")
	if item.type == "consumable":
		InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_use")[0].as_text() + " ]: Eat")

# Update the count in invslot
func update_invslot_count(item_name,num):
	var invslot = null
	for slot in InventoryScroller.get_node("VBoxContainer").get_children():
		if slot.item.item_name == item_name:
			invslot = slot
			break
	if invslot == null:
		print("ERROR: Attempting to update invslot of item " + item_name + ", but no Invslot found!")
		return
	invslot.change_count(num)

func update_equipment_ui():
	var both_item = player.equipment.both_hands
	if both_item != null:
		EquippedWeapon2.hide()
		EquippedWeapon1.hide()
		EquippedWeapon1.get_node("EquippedWeaponImage").texture = load_big_tex(both_item)
		EquippedWeapon1.get_node("EquippedWeaponImage")
		EquippedWeapon1.get_node("HandUseLabel").text = "LR"
		EquippedWeapon1.get_node("EquippedWeaponName").bbcode_text = both_item.name_specialized
		if both_item.type == "ranged":
			EquippedWeapon1.get_node("CurrentAmmo").text = str(both_item.current_ammo) + "/" + str(both_item.max_ammo)
		else:
			EquippedWeapon1.get_node("CurrentAmmo").text = ""
		EquippedWeapon1.show()
	else:
		var right_item = player.equipment.right_hand
		var left_item = player.equipment.left_hand
		EquippedWeapon1.hide()
		EquippedWeapon2.hide()
		if right_item != null:
			EquippedWeapon1.get_node("EquippedWeaponImage").texture = load_big_tex(right_item)
			EquippedWeapon1.get_node("EquippedWeaponImage")
			EquippedWeapon1.get_node("HandUseLabel").text = "R"
			EquippedWeapon1.get_node("EquippedWeaponName").bbcode_text = right_item.name_specialized
			if right_item.type == "ranged":
				EquippedWeapon1.get_node("CurrentAmmo").text = str(right_item.current_ammo) + "/" + str(right_item.max_ammo)
			else:
				EquippedWeapon1.get_node("CurrentAmmo").text = ""
			EquippedWeapon1.show()
		if left_item != null:
			EquippedWeapon2.get_node("EquippedWeaponImage").texture = load_big_tex(left_item)
			EquippedWeapon2.get_node("EquippedWeaponImage")
			EquippedWeapon2.get_node("HandUseLabel").text = "L"
			EquippedWeapon2.get_node("EquippedWeaponName").bbcode_text = left_item.name_specialized
			if left_item.type == "ranged":
				EquippedWeapon2.get_node("CurrentAmmo").text = str(left_item.current_ammo) + "/" + str(left_item.max_ammo)
			else:
				EquippedWeapon2.get_node("CurrentAmmo").text = ""
			EquippedWeapon2.show()

func display_actor_data(actor):
	InfoPanel.hide()
	clearInfoPanel()
	InfoPanel.Icon.texture = actor.sprite.texture
	InfoPanel.Icon.show()
	InfoPanel.Description.text = actor.description
	InfoPanel.show()
	
func player_health_update_ui(ratio):
	HealthBar.rect_size.y = ratio * health_bar_max
	HealthBar.rect_position.y = health_bar_max - HealthBar.rect_size.y
