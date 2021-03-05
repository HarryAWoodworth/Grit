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
	# Add to inventory
	# Probably implement item.stacks here, make unique key with unique id?
	if bag.has(item.item_name):
			bag[item.item_name][1] += num
			game.update_invslot_count(item.item_name, num)
	else:
			bag[item.item_name] = [item, num]
			game.add_new_invslot(item,num)
	current_weight += (item.weight * num)
	# Adjust weight
	#if current_weight > max_weight and !player.has_effect("Encumbered"):
#		pass
		#player.add_effect("Encumbered")

# Add item to inventory
func add_item_no_weight_change(item, num=1):
	# Add to inventory
	# Probably implement item.stacks here, make unique key with unique id?
	if bag.has(item.item_name):
			bag[item.item_name][1] += num
			game.update_invslot_count(item.item_name,num)
	else:
			bag[item.item_name] = [item, num]
			game.add_new_invslot(item,num)

func remove_item(item):
	if bag.has(item.item_name) and !bag[item.item_name][1] > 0:
		bag[item.item_name][1] -= 1
		game.update_invslot_count(item.item_name, -1)
		current_weight -= item.weight
		return bag[item.item_name][0]
	return null
	
func remove_item_by_name(item_name):
	if bag.has(item_name) and bag[item_name][1] > 0:
		bag[item_name][1] -= 1
		game.update_invslot_count(item_name, -1)
		current_weight -= bag[item_name][0].weight
		return bag[item_name][0]
	return null

# Change the max weight the player has
func change_max_weight(new_weight):
	max_weight = new_weight
	# Remove encumbered if the new max weight is more than the current weight and player is encumbered
	if player.has_effect("Encumbered") and current_weight <= max_weight:
		player.remove_effect("Encumbered")
	if !player.has_effect("Encumbered") and current_weight > max_weight:
		player.add_effect("Encumbered")
		
func load_tex(item):
	return load("res://assets/item_sprites/" + item.id + "_small.png")
