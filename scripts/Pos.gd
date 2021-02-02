extends Node2D

onready var sprite = $Sprite

var actors
var items
var tile
var ground_texture
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
	print("Adding item " + item.item_name + " at position (" + str(curr_tile.x) + "," + str(curr_tile.y) + ")")
	if items.empty():
		print("pos drawing item")
		sprite.texture = load("res://assets/item_sprites/" + item.item_name + "_small.png")
	items.append(item)
