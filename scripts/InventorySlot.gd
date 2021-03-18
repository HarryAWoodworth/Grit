extends Control

onready var icon = $TextureRect
onready var text = $RichTextLabel
onready var count = $Label
onready var rect = $ColorRect

var num: int
var item
var onGround: bool
var game

func init(item_, num_, game_, onGround_=true):
	item = item_
	var tex_id = item.id.split("-")[0]
	icon.texture = load("res://assets/item_sprites/" + tex_id + "_small.png")
	text.text = item.name_specialized
	num = num_
	game = game_
	onGround = onGround_
	count.text = "x" + str(num)

func remove_item():
	change_count(-1)

func change_count(dec):
	num += dec
	# Delete if no more items
	if num <= 0:
		queue_free()
	# Set count string to reflect new num
	count.text = "x" + str(num)

func _on_InventorySlot_mouse_entered():
	rect.color = Color(0.30,0.30,0.50)
	game.show_invslot_info_ui(self)

func _on_InventorySlot_mouse_exited():
	rect.color = Color(0.37,0.37,0.37)

# If double clicked, call ground_item_selected() in game 
func _on_InventorySlot_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and event.doubleclick:
		if onGround:
			game.ground_item_double_clicked(item.id,self)
		else:
			game.inventory_item_double_clicked(self)
