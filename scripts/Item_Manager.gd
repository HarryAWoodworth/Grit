extends Node

# Loads Item nodes from a text file.

var Item = preload("res://actors/Item.tscn")

var item_dictionary

func init():
	item_dictionary = {}
	
	# Read item_list JSON file contents
	var file = File.new()
	file.open("res://item_list.json", file.READ)
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	file.close()
	
	# Parse JSON into Item nodes
	var items = json_result["items"]
	for item in items:
		var item_inst = Item.instance()
		# init basic item properties
		item_inst.init_basic(item.item_name,item.weight)
		# Match the item type to init differently
		var item_type = item.type
		match item_type:
			"ranged":
				item_inst.init_ranged(item.ranged_accuracy_dropoff,item.ammo_type)
			"ammo":
				item_inst.init_ammo(Vector2(item.damage_range.low,item.damage_range.high))
			"melee":
				item_inst.init_melee()
			"consumable":
				item_inst.init_consumable()
			"ingredient":
				item_inst.init_ingredient()
		# Add to item dictionary
		item_dictionary[item_inst.item_name] = item_inst

func load_item(item_name):
	return item_dictionary.get(item_name,null)
