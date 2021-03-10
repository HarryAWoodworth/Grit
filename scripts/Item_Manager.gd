extends Node

# Loads Item nodes from a text file.

var Item = preload("res://actors/Item.tscn")

var item_dictionary
var uid_counter

func init(uid_counter_=0):
	
	uid_counter = uid_counter_
	item_dictionary = {}
	
	# Read item_list JSON file contents
	var file = File.new()
	file.open("res://item_list.json", file.READ)
	var json = file.get_as_text()
	var json_parse = JSON.parse(json)
	#print(json_parse.error_string)
	var json_result = json_parse.result
	file.close()
	
	# Parse JSON into Item nodes
	var items = json_result["items"]
	for item in items:
		var item_inst = Item.instance()
		#print(item)
		#print("ID: " + item.id)
		var nsp
		if "name_specialized" in item:
			nsp = item.name_specialized
		else:
			nsp = item.item_name
		# Init item properties
		if "damage_range" 
		item_inst.init_basic(item.id,item.item_name,nsp,item.description,item.weight,item.rarity,item.hand_size,item.type,item.damage_range,item.innacuracy_angle,item.ammo_type,item.burst_size,item.stacks,item.effect,item.reusable,item.scrap)
		# Add to item dictionary
		item_dictionary[item_inst.id] = item_inst

func load_item(id):
	return item_dictionary.get(id,null)
	
func new_uid():
	var temp = uid_counter
	uid_counter += 1
	return str(temp)
