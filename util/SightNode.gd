extends Node2D

var curr_tile
var game
var identifier = "sightnode"
var unique_id

func init(x, y, gameRef):
	game = gameRef
	#var half_tile = game.TILE_SIZE / 2.0
	curr_tile = Vector2(x,y)
	position = Vector2(x * game.TILE_SIZE, y * game.TILE_SIZE)
	#position = Vector2((x * game.TILE_SIZE) + half_tile, (y * game.TILE_SIZE) + half_tile)

func unshadow():
	get_parent().undarken_tile(curr_tile.x,curr_tile.y)
	
func shadow():
	get_parent().darken_tile(curr_tile.x,curr_tile.y)
