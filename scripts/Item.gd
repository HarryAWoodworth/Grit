extends Node2D

# All items can be combined with other items
# All items can be used as weapons (no matter how awful)
# !!! Add new keys to vars, clone(), init_basic()/other inits(), print_item(), and item_manager

var id: String
var item_name: String
var name_specialized: String
var description: String
# Weight
var weight: float
# Item rarity value
var rarity: int
# How many hands it takes to hold this item
var hand_size: int
# What type of item? (Melee, ranged, ammo, item)
var type: String
# Damage range
var damage_range: Vector2
# The maximum difference in angle a weapon can fire (in each direction)
var innacuracy_angle: int
# What type of ammo this weapon takes
var ammo_type: String
# Countable (do multiple instances of this item stack?)
var stacks: bool

func init_clone(item):
	if item == null:
		print("Error: Attempting to clone a NULL item.")
		return
	id = item.id
	item_name = item.item_name
	name_specialized = item.name_specialized
	description = item.description
	weight = item.weight
	rarity = item.rarity
	hand_size = item.hand_size
	type = item.type
	damage_range = item.damage_range
	innacuracy_angle = item.innacuracy_angle
	ammo_type = item.ammo_type

# All items will have name, two textures, and a weight
func init_basic(id_,name_,name_specialized_,description_,weight_,rarity_,hand_size_,type_):
	id = id_
	item_name = name_
	name_specialized = name_specialized_
	description = description_
	weight = weight_
	rarity = rarity_
	hand_size = hand_size_
	type = type_

# Ranged items do not do damage themselves, so have (0,0) as the damage range.
# They also have a non-weight-based ranged_accuracy_dropoff, as well as ammo_type
func init_ranged(innacuracy_angle_,ammo_type_):
	damage_range = Vector2(0,0)
	innacuracy_angle = innacuracy_angle_
	ammo_type = ammo_type_
	stacks = false

func init_melee(damage_range_):
	damage_range = damage_range_
	innacuracy_angle = calculate_innacuracy_angle_with_weight()
	ammo_type = ""
	stacks = false

# Ammo has its own damage range, and no ranged accuracy dropoff/ammo type itself 
func init_ammo(damage_range_):
	damage_range = damage_range_
	innacuracy_angle = 0
	ammo_type = ""
	stacks = true

# Consumables got nothing
func init_consumable():
	damage_range = calculate_dmg_with_weight()
	innacuracy_angle = calculate_innacuracy_angle_with_weight()
	ammo_type = ""
	stacks = true

# Based on weight, calculate the ranged accuracy dropoff of the item if it is thrown
# The bigger the item, the more innacurate it is.
func calculate_innacuracy_angle_with_weight():
	# TODO: Weight -> Ranged Accuracy Dropoff algorithm
	return 0

# Based on weight calculate 
func calculate_dmg_with_weight():
	# TODO: Weight -> Damage Range algorithm
	return 0

func print_item():
	print("ID: " + id)
	print("Name: " + item_name)
	print("Name Specialized: " + name_specialized)
	print("Description: " + description)
	print("Type: " + type)
	print("Weight: " + str(weight))
	print("Rarity: " + str(rarity))
	print("Hand Size: " + str(hand_size))
	print("Damage_range: (" + str(damage_range.x) + "," + str(damage_range.y) + ")")
	print("RAD: " + str(innacuracy_angle))
	print("Ammo Type: " + ammo_type)
