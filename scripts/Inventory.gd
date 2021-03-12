extends Node

# Item dict, weight values
var bag
var current_weight
var max_weight

# Item Manager ref
var item_manager
# Player ref
var player
# Game ref
var game

# Currently all items are identical in name, later on when attributes are added,
# Simply make sure to change the name of the item.
#bag = {
#	// "item_name":[{item}, count]
#	"ak_47": [{ak_47 Item Node}, 1]
#	"soda": [{soda Item Node}, 4]
#}

func init(current_weight_, max_weight_, game_):
	bag = {}
	current_weight = current_weight_
	max_weight = max_weight_
	game = game_
	item_manager = game.item_manager
	player = game.player

# Add item to inventory, increase weight
func add_item(item, num=1):
	#print("Adding item " + item.item_name + " to player inventory")
	# Add to inventory
	# Probably implement item.stacks here, make unique key with unique id?
	if bag.has(item.id):
			bag[item.id][1] += num
			#print("Incrementing invslot in player inventory of item " + item.id + " count to " + str(bag[item.item_name][1]))
			game.update_invslot_count(item.id, num)
	else:
			#print("Creating new invslot in player inventory to hold item " + item.id + " with num: " + str(num))
			bag[item.id] = [item, num]
			game.add_new_invslot(item,num)
	current_weight += (item.weight * num)
	# Encumberance
	#if current_weight > max_weight and !player.has_effect("Encumbered"):
		#pass
		#player.add_effect("Encumbered")

# Add item to inventory
func add_item_no_weight_change(item, num=1):
	#print("Adding item " + item.item_name + " to player inventory (no weight change)")
	# Add to inventory
	# Probably implement item.stacks here, make unique key with unique id?
	if bag.has(item.id):
		#print("Bag has item, updating count")
		bag[item.id][1] += num
		game.update_invslot_count(item.id,num)
	else:
		#print("Bag doesn't have item, creating new invslot")
		bag[item.id] = [item, num]
		game.add_new_invslot(item,num)

# Remove item and return it if it was removed, null otherwise
func remove_item(item,num=1):
	return remove_item_by_id(item.id,num)

# Remove an item by ID and return the item if it was removed, null otherwise
func remove_item_by_id(id,num=1):
	if bag.has(id) and num > bag[id][1]:
		print("ERROR: Trying to remove too many items from inventory with id: " + id + "-> " + str(num) + "/" + str(bag[id][1]))
	if bag.has(id) and bag[id][1] > 0:
		bag[id][1] -= num
		current_weight -= bag[id][0].weight * num
		var tempitem = bag[id][0]
		if bag[id][1] == 0:
			bag.erase(id)
		game.update_invslot_count(id, -1 * num)
		return tempitem
	print("ERROR: Trying to remove item from player inventory with id " + id + " but none was found! Bag has?: " + str(bag.has(id)))
	return null

# Change the max weight the player has
func change_max_weight(new_weight):
	max_weight = new_weight
	# Remove encumbered if the new max weight is more than the current weight and player is encumbered
	#if player.has_effect("Encumbered") and current_weight <= max_weight:
	#	player.remove_effect("Encumbered")
	#if !player.has_effect("Encumbered") and current_weight > max_weight:
	#	player.add_effect("Encumbered")
		
func load_tex(item):
	return load("res://assets/item_sprites/" + item.id + "_small.png")
