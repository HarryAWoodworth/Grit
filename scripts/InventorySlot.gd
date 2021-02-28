extends ColorRect

onready var icon = $TextureRect
onready var text = $RichTextLabel

func init(item):
	icon.texture = load("res://assets/item_sprites/" + item.id + "_small.png")
	text.text = item.item_name
