extends Node2D

# Actor's current tile (Vector2)
var curr_tile: Vector2
# Actor's current sprite
var curr_sprite: Sprite
# Actor's id
var identifier: String
# Specific actor instance's unique ID
var unique_id: int
# Info
var title
var description
# Does this actor block light?
var blocks_light := false
# Does this actor block other actors?
var blocks_other_actors := false
# Is this actor hidden?
var hidden := false

# Copy of the game instance
var game

# Get the distance between the player and this Actor as a Vector2
func player_distance():
	var player_pos = game.player.curr_tile
	return player_pos - curr_tile

func init(game_,x,y,identifier_="...",title_="...",description_="...",hidden_=false,blocks_other_actors_=false,blocks_light_=false):
	game = game_
	curr_tile = Vector2(x,y)
	position = curr_tile * game.TILE_SIZE
	unique_id = game.get_unique_id()
	identifier = identifier_
	title = title_
	description = description_
	hidden = hidden_
	blocks_other_actors = blocks_other_actors_
	blocks_light = blocks_light_

func tick():
	pass

func take_turn():
	pass
