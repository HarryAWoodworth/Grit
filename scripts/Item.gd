extends Node2D

# All items can be combined with other items
# All items can be used as weapons (no matter how awful)
# There is no item degradation

var item_name: String
# Texture on ground
var texture_small: String
# Texture in inventory
var texture_big: String
# Weight
var Weight: float
# What type of item? (Melee, ranged, ammo, item)
var type: String
# Damage range
var damage_range: Vector2
# How innacurate the weapon is at further ranges
var ranged_accuracy_dropoff: int
# What type of ammo this weapon takes
var ammo_type: String
