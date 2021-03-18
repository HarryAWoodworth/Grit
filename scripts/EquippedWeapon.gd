extends Control

onready var Icon = $EquippedWeaponImage
onready var Name = $EquippedWeaponName
onready var HandUse = $HandUseLabel
onready var Ammo = $CurrentAmmo

var item = null
var slot: String

func set_slot(slot_: String):
	slot = slot_

func unequip():
	return item

func set_item(item_):
	item = item_

# Deletes the Item
func remove_item():
	var tempitem = item
	item = null
	tempitem.queue_free()
	
func toString():
	print("EQUIPMENT SLOT!")
	print("Item:::::::::::::::")
	if item != null:
		item.print_item()
	else:
		print("Item is null!")
	print("Slot: " + slot)
