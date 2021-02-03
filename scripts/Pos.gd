extends Node2D

onready var sprite = $Sprite
onready var loot_menu = $PopupMenu

var actors
var items
var tile
var curr_tile

func init_pos(game, tile_,curr_tile_):
	curr_tile = curr_tile_
	tile = tile_
	actors = []
	items = []
	position = Vector2(curr_tile.x * game.TILE_SIZE, curr_tile.y * game.TILE_SIZE)
	
func add_actor(actor):
	if actor.blocks_light:
		actors.push_front(actor)
	else:
		actors.append(actor)
		
func print_pos():
	print("Actors:")
	for actor in actors:
		print(actor.identifier + ": " + actor.title)
	print("Items: ")
	for item in items:
		print("-----------------------")
		item.print_item()
		
func add_item(item):
	print("Adding item " + item.id + " at position (" + str(curr_tile.x) + "," + str(curr_tile.y) + ")")
	if items.empty():
		print("pos drawing item")
		sprite.texture = load_tex(item)
	items.append(item)
	
func display_loot_menu():
	for item in items:
		loot_menu.add_icon_check_item(
			load_tex(item),
			item.item_name
		)
	loot_menu.show()
	
func load_tex(item):
	return load("res://assets/item_sprites/" + item.id + "_small.png")


# Double click opens loot list at pos
#func _on_ClickDetector_input_event(_viewport, event, _shape_idx):
#	if event is InputEventMouseButton and event.doubleclick:
#		display_loot_menu()
