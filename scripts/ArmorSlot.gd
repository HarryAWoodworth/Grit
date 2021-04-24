extends Control

onready var Text = $RichTextLabel

# The item equipped in the slot
var item = null

# There is probably a better way of identifying this focus but oh well
var armorslot = true

# Does the slot have an item equipped?
var equipped = false

# Set text (bbcode)
func setText(string):
	Text.bbcode_text = string

func equip(item_):
	item = item_
	setText(item.name_specialized)
	equipped = true
	show()

# Set item to null and clear text
func clear():
	hide()
	item = null
	equipped = false

# Return the item and clear the slot
func unequip():
	var temp = item
	clear()
	return temp

# Update the slot with a new item and return the old
func update_item(newItem):
	var old = unequip()
	equip(newItem)
	return old
