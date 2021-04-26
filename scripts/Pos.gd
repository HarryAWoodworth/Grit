extends Sprite

var actors
var items
var tile
var rarest_item_rarity
var rarest_item_id
var curr_tile
var showing

# Game ref
var game

func init_pos(game_, tile_, curr_tile_):
	game = game_
	curr_tile = curr_tile_
	tile = tile_
	actors = []
	items = {}
	rarest_item_rarity = 0
	showing = false
	position = Vector2(curr_tile.x * game.TILE_SIZE, curr_tile.y * game.TILE_SIZE)

func add_actor(actor):
	if actor.blocks_light:
		actors.push_front(actor)
	else:
		actors.append(actor)

func print_pos():
	print("//////////// PRINTING POS (" + str(curr_tile.x) + "," + str(curr_tile.y) + ") ////////////")
	print("Rarest Rarity: " + str(rarest_item_rarity))
	print("Rarest Item: " + rarest_item_id)
	print("Actors:")
	for actor in actors:
		print(actor.identifier + ": " + actor.title)
	print("Items: ")
	for item in items.values():
		print("-----------------------")
		item[0].print_item()

func add_item(item,num=1):
	#print("Adding item " + item.id + " at position (" + str(curr_tile.x) + "," + str(curr_tile.y) + ")")
	# Update rarity, update sprite
	if item.rarity > rarest_item_rarity:
		rarest_item_rarity = item.rarity
		rarest_item_id = item.id
		texture = load_tex(item)
		if !visible:
			show()
	# Add the item to the items dict
	if items.has(item.id):
		items[item.id][1] += 1
		if showing:
			game.update_invslot_count(item.id,num,true)
	else:
		items[item.id] = [item, num]
		if showing:
			game.add_new_invslot(item,num,true)

func remove_item(item, num):
	
	var item_id = item.id
	
	# Remove item from item dict
	if items.has(item_id):
		if (items[item_id][1] - num) < 0:
			print("ERROR: Removing too many items: " + item_id + " Num: " + str(num) + " Actual: " + str(items[item_id][1]))
		items[item_id][1] = items[item_id][1] - num
		game.update_invslot_count(item.id,-1*num,true)
	
	# Remove entry from dict if count is 0
	if items[item_id][1] <= 0:
		items.erase(item_id)
		
		# Update rarest item/sprite if rarest item is removed
		if item.id == rarest_item_id:
			#print("Readjusting rarity after " + item.id + "/" + rarest_item_id + " removed...")
			rarest_item_rarity = -1
			if !items.empty():
				#print("Items: " + str(items))
				for item_entry in items.values():
					if rarest_item_rarity < item_entry[0].rarity:
						rarest_item_rarity = item_entry[0].rarity
						rarest_item_id = item_entry[0].id
				#print("New rarest item at pos: " + rarest_item_name)
				texture = load_tex(items[rarest_item_id][0])
			else:
				rarest_item_id = ""
				hide()

# Return true if position has a wall in it
func has_wall():
	if actors.empty():
		return false
	return actors[0].identifier == "WALL"

func loot_item(id, num):
	#print("Looting " + str(num) + " " + id + "(s): " + str(items[id]))
	# Get the item from Pos items dict
	var item_temp = items[id][0]
	if item_temp == null:
		print("ERROR (Pos.gd, loot_item): No item found at pos with id " + id)
		return null
	# Remove the item(s)
	remove_item(item_temp, num)
	#print_pos()
	return item_temp

func load_tex(item):
	var tex_id = item.id.split("-")[0]
	return load("res://assets/item_sprites/" + tex_id + "_small.png")
