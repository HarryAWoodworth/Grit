extends Control

onready var icon = $TextureRect
onready var text = $RichTextLabel
onready var count = $Label
onready var rect = $ColorRect

var num: int

func init(item, num_):
	icon.texture = load("res://assets/item_sprites/" + item.id + "_small.png")
	text.text = item.name_specialized
	num = num_
	count.text = "x" + str(num)
	
func dec_count(dec):
	num -= dec
	count.text = "x" + str(num)
	
func inc_count(inc):
	num += inc
	count.text = "x" + str(num)

func _on_InventorySlot_mouse_entered():
	rect.color = Color(0.30,0.30,0.50)

func _on_InventorySlot_mouse_exited():
	rect.color = Color(0.37,0.37,0.37)
