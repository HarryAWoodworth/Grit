extends Node2D

# All items can be combined with other items
# All items can be used as weapons (no matter how awful)
# There is no item degradation

var item_name: String
# Texture in inventory
var texture_big
# Texture on ground
var texture_small


# Damage range
var damage_range: Vector2
# Is the weapon ranged?
var ranged: bool
# How much innacurate the weapon is at further ranges
var ranged_accuracy_dropoff: int
