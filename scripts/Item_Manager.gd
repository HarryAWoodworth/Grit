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
	var file_text = file.get_as_text()
	file.close()
	# Remove all comments
	var lines = file_text.split('\n')
	var json = ""
	for line in lines:
		if !line.strip_escapes().begins_with("//"):
			#print("Comment: " + line)
			json += line
	#print(json)
	# Read as JSON
	var json_parse = JSON.parse(json)
	#print(json_parse.error_string)
	var json_result = json_parse.result
	
	# Parse JSON into Item nodes
	var items = json_result["items"]
	for item in items:
		var item_inst = Item.instance()
		if !("name_specialized" in item):
			item.name_specialized = item.item_name
		if !("type" in item):
			item.type = null
		if !("hand_size" in item):
			item.hand_size = 1
		if !("damage_range" in item):
			item.damage_range = calculate_dmg_with_weight(item.weight)
		if !("innacuracy_angle" in item):
			item.innacuracy_angle = calculate_innacuracy_angle_with_weight(item.weight)
		if !("ammo_type" in item):
			item.ammo_type = null
		if !("max_ammo" in item):
			item.max_ammo = null
		if !("speed" in item):
			item.speed = null
		if !("stacks" in item):
			item.stacks = true
		if !("effect" in item):
			item.effect = null
		if !("reusable" in item):
			item.reusable = false
		if !("scrap" in item):
			item.scrap = null
		if !("armor_rating" in item):
			item.armor_rating = null
		if !("armor_slot" in item):
			item.armor_slot = null
		if !("weaknesses" in item):
			item.weaknesses = null
		if !("prevents" in item):
			item.prevents = null
		
		# Init item
		item_inst.init_item(item.id,item.item_name,item.name_specialized,item.description,item.weight,item.rarity,item.hand_size,item.type,item.damage_range,item.innacuracy_angle,item.ammo_type,item.max_ammo,item.speed,item.stacks,item.effect,item.scrap,item.armor_rating,item.armor_slot,item.weaknesses,item.prevents)
		# Add to item dictionary
		item_dictionary[item_inst.id] = item_inst

func load_item(id):
	return item_dictionary.get(id,null)
	
func new_uid():
	var temp = uid_counter
	uid_counter += 1
	return str(temp)

# Based on weight, calculate the ranged accuracy dropoff of the item if it is thrown
# The bigger the item, the more innacurate it is.
func calculate_innacuracy_angle_with_weight(weight):
	# TODO: Weight -> Ranged Accuracy Dropoff algorithm
	return 0

# Based on weight calculate the damage the item will do, the heavier it is, the
# more damage it will do
func calculate_dmg_with_weight(weight):
	# TODO: Weight -> Damage Range algorithm
	return Vector2(0,0)
