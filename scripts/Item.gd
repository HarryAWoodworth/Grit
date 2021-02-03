extends Node2D

# All items can be combined with other items
# All items can be used as weapons (no matter how awful)

var id: String
var item_name: String
# Weight
var weight: float
# What type of item? (Melee, ranged, ammo, item)
var type: String
# Damage range
var damage_range: Vector2
# How innacurate the weapon is at further ranges
var ranged_accuracy_dropoff: int
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
	weight = item.weight
	type = item.type
	damage_range = item.damage_range
	ranged_accuracy_dropoff = item.ranged_accuracy_dropoff
	ammo_type = item.ammo_type

# All items will have name, two textures, and a weight
func init_basic(id_,name_,weight_):
	id = id_
	item_name = name_
	weight = weight_

# Ranged items do not do damage themselves, so have (0,0) as the damage range.
# They also have a non-weight-based ranged_accuracy_dropoff, as well as ammo_type
func init_ranged(rad_,ammo_type_):
	type = "ranged"
	damage_range = Vector2(0,0)
	ranged_accuracy_dropoff = rad_
	ammo_type = ammo_type_
	stacks = false

func init_melee(damage_range_):
	type = "melee"
	damage_range = damage_range_
	ranged_accuracy_dropoff = calculate_rad_with_weight()
	ammo_type = ""
	stacks = false

# Ammo has its own damage range, and no ranged accuracy dropoff/ammo type itself 
func init_ammo(damage_range_):
	type = "ammo"
	damage_range = damage_range_
	ranged_accuracy_dropoff = 0
	ammo_type = ""
	stacks = true

# Consumables got nothing
func init_consumable():
	type = "consumable"
	damage_range = calculate_dmg_with_weight()
	ranged_accuracy_dropoff = calculate_rad_with_weight()
	ammo_type = ""
	stacks = true
	
# Ingredients got nothing
func init_ingredient():
	type = "ingredient"
	damage_range = calculate_dmg_with_weight()
	ranged_accuracy_dropoff = calculate_rad_with_weight()
	ammo_type = ""
	stacks = true

# Based on weight, calculate the ranged accuracy dropoff of the item if it is thrown
# The bigger the item, the more innacurate it is.
func calculate_rad_with_weight():
	# TODO: Weight -> Ranged Accuracy Dropoff algorithm
	return 0

# Based on weight calculate 
func calculate_dmg_with_weight():
	# TODO: Weight -> Damage Range algorithm
	return 0

func print_item():
	print("ID: " + id)
	print("Name: " + item_name)
	print("Type: " + type)
	print("Weight: " + str(weight))
	print("Damage_range: (" + str(damage_range.x) + "," + str(damage_range.y) + ")")
	print("RAD: " + str(ranged_accuracy_dropoff))
	print("Ammo Type: " + ammo_type)
