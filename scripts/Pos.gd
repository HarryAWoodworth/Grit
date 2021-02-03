extends Node2D

onready var sprite = $Sprite
onready var loot_menu = $PopupMenu

var actors
var items
var tile
var rarest_item_rarity
var rarest_item_name
var curr_tile

func init_pos(game, tile_,curr_tile_):
	curr_tile = curr_tile_
	tile = tile_
	actors = []
	items = {}
	rarest_item_rarity = 0
	position = Vector2(curr_tile.x * game.TILE_SIZE, curr_tile.y * game.TILE_SIZE)

func add_actor(actor):
	if actor.blocks_light:
		actors.push_front(actor)
	else:
		actors.append(actor)

func print_pos():
	print("Actors:")
	for actor in actors:
		print(actor.identifier + ": " + actor.title)
	print("Items: ")
	for item in items.values():
		print("-----------------------")
		item[0].print_item()

func add_item(item):
	#print("Adding item " + item.id + " at position (" + str(curr_tile.x) + "," + str(curr_tile.y) + ")")
	# Update rarity, update sprite
	if item.rarity > rarest_item_rarity:
		rarest_item_rarity = item.rarity
		rarest_item_name = item.item_name
		sprite.texture = load_tex(item)
		if !sprite.visible:
			sprite.show()
	# Add the item to the items dict
	if items.has(item.item_name):
		items[item.item_name][1] += 1
	else:
		items[item.item_name] = [item, 1]

func remove_item(item):
	# Update rarest item/sprite if rarest item is removed
	if item.item_name == rarest_item_name and items[item.item_name][1] == 1:
		rarest_item_rarity = -1
		if !items.empty():
			print("Items: " + str(items))
			for item_entry in items.values():
				if rarest_item_rarity < item_entry[0].rarity:
					rarest_item_rarity = item_entry[0].rarity
					rarest_item_name = item_entry[0].item_name
			sprite.texture = load_tex(items[rarest_item_name][0])
		else:
			rarest_item_name = ""
			sprite.hide()
	# Remove item from item dict
	if items.has(item.item_name):
		items[item.item_name][1] -= 1
	# Remove entry from dict if count is 0
	if items[item.item_name][1] == 0:
		items.erase(item.item_name)

func loot_item(item_name):
	print("Looting " + item_name + ": " + str(items[item_name]))
	var item_temp = items[item_name][0]
	remove_item(item_temp)
	return item_temp

func display_loot_menu():
	for item in items:
		loot_menu.add_icon_check_item(
			load_tex(item),
			item.item_name
		)
	loot_menu.show()

func load_tex(item):
	return load("res://assets/item_sprites/" + item.id + "_small.png")

# Double click opens loot list at pos
#func _on_ClickDetector_input_event(_viewport, event, _shape_idx):
#	if event is InputEventMouseButton and event.doubleclick:
#		display_loot_menu()
