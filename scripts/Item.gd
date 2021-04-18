extends Node2D

# All items can be combined with other items
# All items can be used as weapons (no matter how awful)
# !!! Add new keys to vars, clone(), init_basic()/other inits(), print_item(), and item_manager

var uid_counter

var uid: String
var id: String
var item_name: String
var name_specialized: String
var description: String
# Weight
var weight: float
# Item rarity value
var rarity: int
# How many hands it takes to hold this item
var hand_size #int, defaults to 1
# What type of item? (Melee, ranged, ammo, item)
var type #String
# Countable (do multiple instances of this item stack?)
var stacks #bool, defaults to FALSE

###### WEAPONS

# Damage range
var damage_range #Vector2
# The maximum difference in angle a weapon can fire (in each direction)

###### RANGED WEAPONS
var innacuracy_angle #int
# What type of ammo this weapon takes
var ammo_type #String
# How many bullets go into the weapon clip
var max_ammo #int
# How many bullets are fired per weapon firing action
var speed #int
# Current Ammunition Amount
var current_ammo #int

##### CONSUMABLE
var effect #Dictionary

##### INGREDIENT
var scrap #String

##### ARMOR
var armor_rating #int
var armor_slot #string
var weaknesses #string[]
var prevents #string[]

# Init this item based on another item (cloning it)
func init_clone(item, uid_):
	if item == null:
		print("Error: Attempting to clone a NULL item.")
		return
	uid = uid_
	id = item.id
	item_name = item.item_name
	name_specialized = item.name_specialized
	description = item.description
	weight = item.weight
	rarity = item.rarity
	hand_size = item.hand_size
	type = item.type
	stacks = item.stacks
	damage_range = item.damage_range
	innacuracy_angle = item.innacuracy_angle
	ammo_type = item.ammo_type
	max_ammo = item.max_ammo
	speed = item.speed
	current_ammo = item.current_ammo
	effect = item.effect
	scrap = item.scrap
	armor_rating = item.armor_rating
	armor_slot = item.armor_slot
	weaknesses = item.weaknesses
	prevents = item.prevents
	
	# Create a unique ID for non-stacking items
	if !stacks:
		id = id + "-" + uid

# All items will have these fields
# (Stacks determined by item type)
func init_item(id_,name_,name_specialized_,description_,weight_,rarity_,hand_size_,type_,damage_range_,innacuracy_angle_,ammo_type_,max_ammo_,speed_,stacks_,effect_,scrap_,armor_rating_,armor_slot_,weaknesses_,prevents_):
	id = id_
	item_name = name_
	name_specialized = name_specialized_
	description = description_
	weight = weight_
	rarity = rarity_
	hand_size = hand_size_
	type = type_
	damage_range = damage_range_
	innacuracy_angle = innacuracy_angle_
	ammo_type = ammo_type_
	max_ammo = max_ammo_
	speed = speed_
	stacks = stacks_
	current_ammo = 0
	effect = effect_
	scrap = scrap_
	armor_rating = armor_rating_
	armor_slot = armor_slot_
	weaknesses = weaknesses_
	prevents = prevents_

func get_speed():
	return speed

func print_item():
	print("UID: " + uid)
	print("ID: " + id)
	print("Name: " + item_name)
	print("Name Specialized: " + name_specialized)
	print("Description: " + description)
	print("Type: " + type)
	print("Stacks?: " + str(stacks))
	print("Weight: " + str(weight))
	print("Rarity: " + str(rarity))
	print("Hand Size: " + str(hand_size))
	print("Damage_range: (" + str(damage_range.x) + "," + str(damage_range.y) + ")")
	print("Innacuracy Angle: " + str(innacuracy_angle))
	if scrap != null:
		print("Scrap: " + scrap)
	if effect != null:
		print("Effect: " + JSON.print(effect))
	if type == "ranged":
		print("Ammo Type: " + ammo_type)
		print("Max Ammo: " + str(max_ammo))
		print("Speed: " + str(speed))
		print("Current Ammo: " + str(current_ammo))
	if type == "armor":
		print("Armor Rating: " + str(armor_rating))
		print("Armor Slot: " + armor_slot)
		print("Weaknesses: " + str(weaknesses))
		print("Prevents: " + str(prevents))
