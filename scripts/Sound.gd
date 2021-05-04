extends Node

# This node is a helper for sounds made in game (not audio, but action sound rings)

# Get an array of Actors within 'volume' tiles of x,y location
# (Return actors that heard a noise)
func actors_that_heard_noise(volume: int, sound_origin) -> Array:
	# List of actors to return
	var actor_arr = []
	var temp_actor
	var pos
	# Array of positions to search
	var search_array = sound_origin.get_neighbors()
	# Array of positons already searched
	var searched = []
	
	# Search every tile in search_array
	while !search_array.empty():
		# Search next Pos
		pos = search_array.pop_front()
		# Add actor if present and can listen
		if !pos.actors.empty() and pos.top_actor().has_method("listen"):
			actor_arr.append(pos.top_actor())
		# Add Pos to searched list
		searched.append(pos)
		# Add neighbors if within volume distance and not already searched
		for neighbor in pos.get_neighbors():
			if !searched.has(neighbor) and neighbor.distance(sound_origin) <= volume:
				search_array.append(neighbor)
		
	
	return actor_arr
	
