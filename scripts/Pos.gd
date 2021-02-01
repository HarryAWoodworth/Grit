extends Node2D

var actors
var items
var tile

func init_pos(tile_):
	tile = tile_
	actors = []
	items = []
	
func add_actor(actor):
	if actor.blocks_light:
		actors.push_front(actor)
	else:
		actors.append(actor)
