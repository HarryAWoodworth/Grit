extends Node

var actors
var items
var tile

func init(tile_):
	actors = []
	items = []
	tile = tile_
	
func add_actor(actor):
	if actor.blocks_light:
		actors.push_front(actor)
	else:
		actors.append(actor)
