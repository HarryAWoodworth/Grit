
# <<< A0.1 >>> -----------------------------------------------------------------

## TODO:
# [ ] Game.player_has_key()

## BUGS:

## INTERACTION UI
# [ ] Add Weight to UI somewhere (Info box)

## PLAYER EQUIPMENT
# [ ] Melee Weapons
# [ ] Melee Combat, turn action

## EFFECTS
# [ ] Effects class
# [ ] Effect Manager
# [ ] Display player effects (Effect class with bbcode?, Effect manager?)
# [ ] Monsters have effects
# [ ] Display Monster effects
# [ ] Action effects that can set on the scheduler and activate once the ticker hits it

## ENVIRONMENT INTERACTION
# [1] Doors
	# [ ] Sprite change when open, can see through
	# [ ] Hovering mouse over actor within range displays tile actions
# [ ] Containers
# [ ] Player can loot container
# [ ] Monster corpses
# [ ] Morning -> Noon -> Evening Cycle
# [ ] Hovering mouse over actor within range displays tile actions

## MONSTERS
# [ ] Check that pathfinding still works
# [ ] Different AI's? (check out bookmarked rougelike AI article)
	# [?] AI Tags? (Like Brogue)
# [ ] Monster manager from json file
# [ ] Info box shows monster's current action
# [ ] Different Monster actions with different speeds

## SETTINGS
# [ ] Set screen side of UI (switch ground and inv too [swap position?])
# [ ] Hide/Show/Shrink UI

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

## LOOT TABLES
# [ ] Loot Tables

## MAP GENERATION
# [ ] Prefabs

## GAME STATE
# [ ] Save Game
# [ ] Load Game

## AUDIO
# [ ] Ambient music
# [ ] Monster sound effects
# [ ] POI sound effects (falling off with distance)
# [ ] Weapon sound effects
# [ ] Bullet sound effects

## VISUAL
# [ ] Tune bullet look
# [ ] Fancy color/fonts in logs
# [ ] Fancy color/font in inventory
# [ ] Aiming animation (Mouse Detection draw(), change to ray cast so it hits things, or just draw something over mouse position)

# <<< A0.2 >>> -----------------------------------------------------------------

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

# <<< A0.3 >>> -----------------------------------------------------------------

## FARMING
# [ ] Seed Items
# [ ] Farm Plots
# [ ] Harvesting grown plants
# [ ] Seed Splicing

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< A0.4 >>> -----------------------------------------------------------------

## Monsters
# [ ] Monsters Wander

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< A0.5 >>> -----------------------------------------------------------------

## FLOORS
# [ ] Player can move between floors in buildings (transport to smaller map)

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< A0.6 >>> -----------------------------------------------------------------

## MODULAR WEAPONS
# [ ] Mod weapons with items
# [ ] Redesign gun item
# [ ] Allow hotswap of mods?
# [ ] Hotswap UI
# [ ] Using gun takes into account mods

## GENERAL
# [ ] More Prefabs
# [ ] More Items
# [ ] More Recipes
# [ ] More Enemies

# <<< Other >>> ----------------------------------------------------------------

## OTHER
# [?] Critical Attacks activate a quick time event

## MONSTER IDEAS
# [ ] Monster with action that "flashes" you, turns screen pure white for a set 
#		number of ticks

extends Node2D

# Consts -----------------------------------------------------------------------

const WINDOW_SIZE = Vector2(1920, 1080)
const TILE_SIZE = 128
const CHUNK_DIMENSION = 16
const MAX_TESTLOG_LENGTH = 10000

enum TILE { stone1, stone2, stone3, stone4 }
enum Shadow { Shadow }

# Node Refs --------------------------------------------------------------------

onready var ticker = $Ticker
onready var tile_map = $TileMap
onready var textlog = $UI/TextLog
onready var item_manager = $Item_Manager
onready var GroundScroller = $UI/GroundScroller
onready var InventoryScroller = $UI/InventoryScroller
onready var InfoPanel = $UI/InfoPanel
onready var Mouse_Detection = $Mouse_Detection
onready var Input_Manager = $Input_Manager
onready var UI = $UI
onready var HealthBar = $UI/PlayerInfo/HealthIndicator/HealthRect
# Weapon slots
onready var EquippedWeapon1 = $UI/PlayerInfo/EquippedWeapon
onready var EquippedWeapon2 = $UI/PlayerInfo/EquippedWeapon2
# Armor slots
onready var HeadArmor = $UI/PlayerInfo/Armor/ArmorSlot
onready var FaceArmor = $UI/PlayerInfo/Armor/ArmorSlot2
onready var TorsoArmor = $UI/PlayerInfo/Armor/ArmorSlot3
onready var JacketArmor = $UI/PlayerInfo/Armor/ArmorSlot4
onready var HandArmor = $UI/PlayerInfo/Armor/ArmorSlot5
onready var LegArmor = $UI/PlayerInfo/Armor/ArmorSlot6
onready var FeetArmor = $UI/PlayerInfo/Armor/ArmorSlot7

onready var Action_Parser = $Action_Parser


# Entity Preloads --------------------------------------------------------------

# Node preloads for instancing
var Furniture = preload("res://actors/Furniture.tscn")
var Pos = preload("res://scenes/Position.tscn")
var Monster = preload("res://actors/Monster.tscn")
var Player = preload("res://actors/Player.tscn")
var Wall = preload("res://actors/Wall.tscn")
var Door = preload("res://actors/Door.tscn")
var Item = preload("res://actors/Item.tscn")
var InventorySlot = preload("res://scenes/InventorySlot.tscn")

# Game State -------------------------------------------------------------------

var player = null
#var anim_finished = true
# List of actor unique_id 's 
var actor_list = []
# List of walls
var wall_list = []
# List of doors
var door_list = []
# Map of Pos nodes
var map = []
# Increasing number for actor unique id's
var unique_actor_id = 0
# Is the game world running?
var world_running = false
# What invslot is focused
var focus = null
var focused_actions = []
var aiming = false

## UI
var health_bar_max

# Ready ------------------------------------------------------------------------

# Init the game
func _ready():
	## NOTE: DON'T mess with orderings!
	#OS.set_window_size(WINDOW_SIZE)
	# Init the item manager
	item_manager.init()
	# Init the game, player, map
	randomize()
	build_chunk()
	# Init mouse detection input
	Mouse_Detection.init(self)
	# Init the UI
	UI.init(self)
	# Init the manager for player input
	Input_Manager.init(self)
	# Init the parser for actions
	Action_Parser.init(self)
	# Set Tile Size
	tile_map.cell_quadrant_size = TILE_SIZE
	# Healthbar UI
	health_bar_max = HealthBar.rect_size.y

# Actor Movement ------------------------------------------------------------------------

# Checks if an actor can move into a coordinate
func can_move(x, y, actor_x=0, actor_y=0) -> bool:
	#print("Game.can_move: actor: " + str(actor_x) + "," + str(actor_y))

	var y_diff = y-actor_y
	var x_diff = x-actor_x

	# Return false if coordinates are off the map
	# TODO: Remove when game done and map is surrounded by forest or whatever
	if x < 0 or x >= CHUNK_DIMENSION or y < 0 or y >= CHUNK_DIMENSION:
		return false
	# Check if thwwre is an actor that blocks movement in that path
	var actors = map[x][y].actors
	if actors.empty():
		return true
	var top_actor = actors[0]
	if top_actor.identifier == "DOOR" and !top_actor.open:
		if y_diff < 0:
			return actors[0].try_door("fromBottom")
		elif y_diff > 0:
			return actors[0].try_door("fromTop")
		elif x_diff < 0:
			return actors[0].try_door("fromRight")
		else:
			return actors[0].try_door("fromLeft")
	else:
		return !actors[0].blocks_other_actors

# Move an actor to a coordinate
func move_actor(actor, x ,y) -> bool:
	#print("Game.move_actor: Identifier: " + actor.identifier)
	if can_move(x,y,actor.curr_tile.x,actor.curr_tile.y):
		# Remove the actor from its previous position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.erase(actor)
		# Update actor's current tile
		actor.curr_tile = Vector2(x,y)
		# Add it to its new position
		map[actor.curr_tile.x][actor.curr_tile.y].actors.append(actor)
		# Update the actor's node
		actor.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
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
			pos = Pos.instance()
			add_child(pos)
			var floor_tile_num = randi()%4
			pos.init_pos(self, floor_tile_num, Vector2(x,y))
			
			map[x].append(pos)
			# Set the tile map
			tile_map.set_cell(x, y, map[x][y].tile)
			# Add sight node
			# add_sight_node(x, y)

	# Extra walls for testing
	add_wall(6, 4)
	add_wall(6, 5)
	add_wall(8, 5)
	add_wall(8, 6)
	add_wall(6, 7)
	add_wall(8, 7)
	add_wall(6, 8)
	add_wall(8, 8)
	add_wall(4, 8)
	add_wall(3, 8)
	add_wall(9, 8)
	add_wall(10, 8)
	add_wall(11, 8)
	add_wall(5, 3)
	add_wall(6, 3)
	add_wall(6, 2)
	add_wall(6, 10)
	add_wall(6, 4)
	add_wall(8, 4)
	add_wall(10, 4)
	add_wall(12, 4)
	add_wall(14, 4)
	add_wall(8, 6)
	add_wall(10, 6)
	add_wall(12, 6)
	add_wall(14, 6)
	add_wall(6, 8)
	add_wall(8, 8)
	add_wall(10, 8)
	add_wall(12, 8)
	add_wall(14, 8)
	
	# Doors for testing
	# DOORS NEED TO BE AFTER WALLS OR THEY WILL OPEN THEMSELVES
	add_door(7, 8)
	add_door(6, 9)

	# Set wall occluders
	for wall in wall_list:
		wall.occluder_set()

	# Turn doors
	for door in door_list:
		door.rotation_set()

	# Place Player
	var player_inst = Player.instance()
	add_child(player_inst)
	player_inst.init(self,7,10,"player","Basilisk","...",false,true,false)
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
	add_item("hunting_knife",1,0)
	
	add_item("leather_gloves",3,3)
	
	add_item("ak_47",0,1,"debug")
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
	player.add_effect("shrapnel")
	# var item_inst1 = Item.instance()
	# item_inst1.init_clone(item_manager.item_dictionary.get("canned_tuna"),"767676767")
	# var item_inst2 = Item.instance()
	# item_inst2.init_clone(item_manager.item_dictionary.get("hunting_knife"),"909090909")
	#Action_Parser.eval_if(item_inst1.effect.values()[0])
	#Action_Parser.eval_if(item_inst2.effect.values()[0])
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
	player.has_turn = false
	# Loop through all turns until Player
	while(!ticker.do_next_turn()):
		pass
		#print("Game.run_until_player_turn(): Tick " + str(ticker.ticks))
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

func set_texture(texture, node):
	node.sprite.set_texture(texture)

func add_wall(x,y,identifier="WALL",title="...",description="...",hidden=false,blocks_other_actors=true,blocks_light=true):
	var wall = Wall.instance()
	add_child(wall)
	wall.init(self,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
	#wall.sprite.texture = texture
	# Add wall to wall list
	wall_list.append(wall)
	# Add wall to map pos
	map[x][y].add_actor(wall)

func add_door(x,y,open=false,locked=false,key="nokey",identifier="DOOR",title="...",description="...",hidden=false,blocks_other_actors=true,blocks_light=true):
	var door = Door.instance()
	add_child(door)
	door.init(self,x,y,identifier,title,description,hidden,blocks_other_actors,blocks_light)
	door.init_door(open,locked,key)
	door_list.append(door)
	map[x][y].add_actor(door)

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
func add_item(id,x,y,debug=null):
	# Clone the item from the item manager
	var item_inst = get_item_from_manager(id)
	if debug != null:
		item_inst.description = "Volcano!"
	map[x][y].add_item(item_inst)
	return true

func get_item_from_manager(item_name):
	var item_inst = Item.instance()
	var item_from_dict = item_manager.item_dictionary.get(item_name)
	if item_from_dict == null:
		print("Error: No item found in item_dictionary with ID: \"" + item_name + "\"")
		return false
	item_inst.init_clone(item_manager.item_dictionary.get(item_name),item_manager.new_uid())
	return item_inst

# TODO
func add_item_to_lootable(id,_lootable):
	var item_inst = Item.instance()
	item_inst.init_clone(item_manager.item_dictionary.get(id))
	#lootable.add_item(item_inst)

# Return an updating unique ID value
func get_unique_id():
	var temp = unique_actor_id
	unique_actor_id = unique_actor_id + 1
	return temp
	
func load_tex(item):
	var tex_id = item.id.split("-")[0]
	return load("res://assets/item_sprites/" + tex_id + "_small.png")
	
func load_big_tex(item):
	var tex_id = item.id.split("-")[0]
	return load("res://assets/item_sprites/" + tex_id + "_big.png")
	
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
		pos.showing = true
	# Otherwise hide the scroller
	else:
		GroundScroller.hide()
		pos.showing = false

# Equip item from inventory
func inventory_item_double_clicked(_invslot):
	pass

# When the user double clicks an item in the ground list, move it to the player
# inventory and add it as an invslot in the UI
func ground_item_double_clicked(_id, _invslot):
	pass

# Add a new invslot item to the UI inventory list
func add_new_invslot(item, num, onGround=false):
	var newinvslot = InventorySlot.instance()
	# Add to Position or player inventory
	if onGround:
		GroundScroller.get_node("VBoxContainer").add_child(newinvslot)
	else:
		InventoryScroller.get_node("VBoxContainer").add_child(newinvslot)
	newinvslot.init(item,num,self,onGround)

# When an invslot is hovered over, show its info and action list
func show_invslot_info_ui(invslot):
	InfoPanel.hide()
	InfoPanel.clear()
	InfoPanel.Icon.texture = load_tex(invslot.item)
	InfoPanel.Icon.show()
	InfoPanel.Description.text = invslot.item.description
	addActionsInfoPanel(invslot)
	InfoPanel.show()

func show_equipment_info_ui(equipslot):
	#equipslot.toString()
	if equipslot.item != null:
		InfoPanel.hide()
		InfoPanel.clear()
		InfoPanel.Icon.texture = load_tex(equipslot.item)
		InfoPanel.Icon.show()
		InfoPanel.Description.text = equipslot.item.description
		addActionsInfoPanel(equipslot)
		InfoPanel.show()
	else:
		print("Game.show_equipment_info_ui(): ERROR: Equipslot item null.")

# Bring the added ui class into "focus", so it's item has actions attached to it
func addActionsInfoPanel(ui):
	# Set focus and clear actions, grab the focused item
	focus = ui
	focused_actions.clear()
	var item = focus.item
	# Add actions based on the item's "effect" dictionary
	if item.effect != null and !item.effect.empty():
		#print("Adding effects from item effect dict")
		# Var for selecting which extra action button to use
		var index_action_use_key = 1
		# For each effect, check if the action is an IF action (only shown if
		# the criteria are true), or just add the action
		var keys = item.effect.keys()
		var val
		var effect_string_and_ticks
		for key in keys:
			val = item.effect[key].replace(" ","")
			#print("Evaluating Action " + key + ": " + val)
			# Grab the Effect String and the ticks
			effect_string_and_ticks = val.right(val.find('>')+1).split("|")
			# If the action is do-able, show it
			if val[0] == '?':
				#print("Evaluating IF: " + val.left(val.find('>')))
				if Action_Parser.eval_if(val.left(val.find('>'))):
					InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_use_" + str(index_action_use_key))[0].as_text() + " ] " + key, "action_button_use_" + str(index_action_use_key), effect_string_and_ticks[1].to_int(), effect_string_and_ticks[0])
					focused_actions.append("action_button_use_" + str(index_action_use_key))
					index_action_use_key+=1
			else:
				InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_use_" + str(index_action_use_key))[0].as_text() + " ] " + key, "action_button_use_" + str(index_action_use_key),effect_string_and_ticks[1].to_int(), effect_string_and_ticks[0])
				focused_actions.append("action_button_use_" + str(index_action_use_key))
				index_action_use_key+=1
	
	# If the focus is from an inventory (player or position)...
	if "onGround" in focus:
		# Add Equip action
		InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_equip")[0].as_text() + " ] Equip","action_button_equip",     0)
		focused_actions.append("action_button_equip")
		# Add pick up/drop actions
		var action_str
		if !focus.onGround:
			action_str = "Drop"
		else:
			action_str = "Pick Up"
		if focus.num > 1:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ] " + action_str + " All", "action_button_move_inv",     0)
			InfoPanel.add_action("[ " + InputMap.get_action_list("shift")[0].as_text() + " + " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ] " + action_str + " 1", "action_button_move_inv_spec",     0)
			focused_actions.append("action_button_move_inv")
			focused_actions.append("action_button_move_inv_spec")
		else:
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ] " + action_str,"action_button_move_inv",     0)
			focused_actions.append("action_button_move_inv")
	
	# If the focus is on an equipment
	elif "equipped" in focus:
		#print("Game.gd.AddActionsInfoPanel(): Adding Equipment Actions!")
		# Add Unequip action
		InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_equip")[0].as_text() + " ] Unequip","action_button_equip",     0)
		focused_actions.append("action_button_equip")
		# Add Unequip action
		InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_move_inv")[0].as_text() + " ] Drop","action_button_move_inv",     0)
		focused_actions.append("action_button_move_inv")
		
		if "type" in focus.item and focus.item.type == "ranged":
			
			InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_use")[0].as_text() + " ] Aim","action_button_use",     0)
			focused_actions.append("action_button_use")
			
			if focus.item.current_ammo < focus.item.max_ammo:
				InfoPanel.add_action("[ " + InputMap.get_action_list("action_button_reload")[0].as_text() + " ] Reload","action_button_reload",     0)
				# Covered by user input
				#focused_actions.append("action_button_reload")
				
			#if focus.item.current_ammo < focus.item.max_ammo:
				#InfoPanel.add_action("[ M1 ] Shoot","action_button_click",     0)
				#focused_actions.append("action_button_click")

# Do an action witht the focused UI Item and available actions. Called from Input_Manager
func do_action(action):
	#print("Game.do_action(): Doing action " + action)
	if focus != null and focused_actions.has(action):
		#print("Game.do_action(): Has action " + action)
		match action:
			"action_button_use":
				if "type" in focus.item and focus.item.type == "ranged":
					aiming = !aiming
					#print("Game.do_action(): Aiming?:" + str(aiming))
			# Equip weapon from ground or inventory
			"action_button_equip": # G
				# Equip item to player equipment from inventory or ground
				if "onGround" in focus:
					if focus.onGround:
						var temp_item = map[player.curr_tile.x][player.curr_tile.y].loot_item(focus.item.id, 1)
						player.equipment.hold_item(temp_item)
						InfoPanel.clear()
					else:
						player.equipment.hold_item(player.inventory.remove_item(focus.item))
						InfoPanel.clear()
				# Unequip item from player equipment to player inventory
				elif "equipped" in focus:
					player.equipment.unequip_item(focus.item)
					focus.clear()
			"action_button_move_inv": # C
				# Swap items between player inventory & ground
				if "onGround" in focus:
					var temp_num = focus.num
					if focus.onGround:
						player.inventory.add_item(map[player.curr_tile.x][player.curr_tile.y].loot_item(focus.item.id,temp_num),temp_num)
					else:
						map[player.curr_tile.x][player.curr_tile.y].add_item(player.inventory.remove_item(focus.item,temp_num),temp_num)
				# Drop item to ground from player equipment
				elif "equipped" in focus:
					
					
					
					
					
					
					
					
					player.equipment.unequip_item(focus.item, true)
					focus.clear()
			"action_button_move_inv_spec":
				# Drop or Pick Up 1 item
				if "onGround" in focus:
					if focus.onGround:
						player.inventory.add_item(map[player.curr_tile.x][player.curr_tile.y].loot_item(focus.item.id, 1),1)
					else:
						map[player.curr_tile.x][player.curr_tile.y].add_item(player.inventory.remove_item(focus.item),1)
			# Use custom effect actions
			"action_button_use_1":
				Action_Parser.do_action(InfoPanel.get_action(action), focus)
			"action_button_use_2":
				Action_Parser.do_action(InfoPanel.get_action(action), focus)
			"action_button_use_3":
				Action_Parser.do_action(InfoPanel.get_action(action), focus)
			"action_button_use_4":
				Action_Parser.do_action(InfoPanel.get_action(action), focus)
			"action_button_use_5":
				Action_Parser.do_action(InfoPanel.get_action(action), focus)
	return true

# Find the invslot with the item matching ID, then update it's count with num
func update_invslot_count(id,num,onGround=false):
	var invslot = null
	var scroller
	# Determine which scroller to search in
	if onGround: 
		scroller = GroundScroller
	else:
		scroller = InventoryScroller
	# Find the invslot with the same item ID
	for slot in scroller.get_node("VBoxContainer").get_children():
		if slot.item.id == id:
			invslot = slot
			break
	if invslot == null:
		print("ERROR (Game.update_invslot_count()): Attempting to update invslot of item " + id + ", but no Invslot found!")
		return
	# Update its num
	invslot.change_count(num)

func update_equipment_ui(slotStr):
	var slotItem
	var slot
	match slotStr:
	# Update Hands
		"both":
			slotItem = player.equipment.both_hands
			if slotItem == null:
				EquippedWeapon2.clear()
				EquippedWeapon1.clear()
			else:
				EquippedWeapon2.clear()
				EquippedWeapon1.update_item(slotStr, slotItem, load_big_tex(slotItem))
				return
		"right":
			slotItem = player.equipment.right_hand
			if slotItem == null:
				EquippedWeapon1.clear()
			else:
				EquippedWeapon1.update_item(slotStr, slotItem,load_big_tex(slotItem))
			return
		"left":
			slotItem = player.equipment.left_hand
			if slotItem == null:
				EquippedWeapon2.clear()
			else:
				EquippedWeapon2.update_item(slotStr, slotItem,load_big_tex(slotItem))
			return
	# Update Armor
		"head":
			slotItem = player.equipment.head
			slot = HeadArmor
		"face":
			slotItem = player.equipment.face
			slot = FaceArmor
		"torso":
			slotItem = player.equipment.torso
			slot = TorsoArmor
		"jacket":
			slotItem = player.equipment.jacket
			slot = JacketArmor
		"hands":
			slotItem = player.equipment.hands
			slot = HandArmor
		"legs":
			slotItem = player.equipment.legs
			slot = LegArmor
		"feet":
			slotItem = player.equipment.feet
			slot = FeetArmor
	print("Game update_equipment_ui(): SlotStr: " + slotStr)
	if slotItem == null:
		slot.clear()
	else:
		slot.update_item(slotItem)

# Update the Equipment ammo UI using a slot string and a ref to the updated item
func update_equipment_ui_ammo(slot, updatedItem):
	if slot == "left_hand":
		EquippedWeapon2.Ammo.text = str(updatedItem.current_ammo) + "/" + str(updatedItem.max_ammo)
	else:
		EquippedWeapon1.Ammo.text = str(updatedItem.current_ammo) + "/" + str(updatedItem.max_ammo)

func display_actor_data(actor):
	InfoPanel.hide()
	InfoPanel.clear()
	if actor.has_node("AnimatedSprite"):
		InfoPanel.Icon.texture = actor.sprite.frames.get_frame("Idle",0)
	else:
		InfoPanel.Icon.texture = actor.sprite.texture
	InfoPanel.Icon.show()
	InfoPanel.Description.text = actor.description
	InfoPanel.show()
	
func player_health_update_ui(ratio):
	HealthBar.rect_size.y = ratio * health_bar_max
	HealthBar.rect_position.y = health_bar_max - HealthBar.rect_size.y

# ACTION HELPERS ---------------------------------------------------------------

# Return the number of bullets in inventory that can be removed up to num
# Remove the bullets before returning
func reload_from_inv(num,ammo_id):
	var removedItem
	var numInInv = player.inventory.num_of_item(ammo_id)
	if numInInv == null or numInInv <= 0:
		return 0
	# print("Game.reload_from_inv(): There are " + str(numInInv) + " in player inventory.")
	if num > numInInv:
		removedItem = player.inventory.remove_all_items_by_id(ammo_id)
		if removedItem == null:
			print("ERROR: Game.reload_from_inv(" + str(num) + "," + ammo_id + "): Player inventory did not contain ammo_id")
			return 0
		return numInInv
	else:
		removedItem = player.inventory.remove_item_by_id(ammo_id,num)
		if removedItem == null:
			print("ERROR: Game.reload_from_inv(" + str(num) + "," + ammo_id + "): Player inventory did not contain ammo_id")
			return 0
		return num

# Add item to position player is at
func item_drop(item):
	map[player.curr_tile.x][player.curr_tile.y].add_item(item)
	
# Check if player has the right key
# TODO
func player_has_key(key) -> bool:
	return true
