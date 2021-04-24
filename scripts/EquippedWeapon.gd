extends Control

onready var Icon = $EquippedWeaponImage
#onready var Name = $EquippedWeaponName
onready var HandUse = $HandUseLabel
onready var Ammo = $CurrentAmmo

var item = null
var slot: String
var equipped = true

func set_ammo(ammo):
	Ammo.text = ammo

func set_slot(slot_: String):
	slot = slot_

func unequip():
	return item

func set_item(item_):
	item = item_

func clear():
	item = null
	slot = ""
	equipped = false
	Icon.hide()
	#Name.hide()
	HandUse.hide()
	Ammo.hide()

func reveal():
	Icon.show()
	#Name.show()
	HandUse.show()
	Ammo.show()
	equipped = true
	show()

func update_item(slotStr, newItem, tex):
		hide()
		Icon.texture = tex
		match slotStr:
			"left":
				HandUse.text = "L"
			"right":
				HandUse.text = "R"
			"both":
				HandUse.text = "LR"
		#Name.bbcode_text = newItem.name_specialized
		set_item(newItem)
		#set_slot("both-1")
		if newItem.type == "ranged":
			Ammo.text = str(newItem.current_ammo) + "/" + str(newItem.max_ammo)
		else:
			Ammo.text = ""
		reveal()

# Deletes the Item
func remove_item():
	item = null
	
func toString():
	print("EQUIPMENT SLOT!")
	print("Item:::::::::::::::")
	if item != null:
		item.print_item()
	else:
		print("Item is null!")
	print("Slot: " + slot)
