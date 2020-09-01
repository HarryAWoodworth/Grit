extends Node

class Tile extends Reference:
	var x
	var y
	var g
	var h
	var f
	var parent
	
	func _init(n_parent,pos,n_g,n_h):
		parent = n_parent
		x = pos.x
		y = pos.y
		g = n_g
		h = n_h
		f = g + h

# AI's -------------------------------------------------------------------------

# AI types
var none_func = funcref(self, "none")
var monster_classic_func = funcref(self, "monster_classic")

func none(_node, _game):
	pass

# Monster Classic AI
# Uses A* Pathfinding
func monster_classic(node, game):
	if !node.target_aquired:
		print("Enemy does not have a target aquired...")
		return
	# Check adjacent, if so, attack
	
	# Open and closed lists
	var closed_list = []
	var open_list = []
	var goal = node.target.curr_tile
	var path_found = false
	# Add the original position ot the open list
	open_list.append(Tile.new(null,node.curr_tile,0,calcH(node.curr_tile, goal)))
	while !open_list.empty():
		# Get the tile with the lowest F from the open list
		var currentTile = open_list.pop_front()
		# Move it from the open to the closed list
		closed_list.append(currentTile)
		# Get all of the surrounding free spaces, incrementing G
		var free_spaces_adjacent = adjacentList(game.get_surrounding_empty(node),currentTile,goal)
		# Return if the node is boxed in
		if free_spaces_adjacent.empty():
			return
		if contains(free_spaces_adjacent, goal):
			path_found = true
			var tmp = currentTile
			while tmp != null:
				print("pos = (" + str(currentTile.x) +"," + str(currentTile.y) + ") g=" +str(currentTile.g) + " h=" + str(currentTile.h) + " f=" + str(currentTile.f))
				tmp = tmp.parent
			break
		# Go through each adjacent node and check if its in the closed/open lists
		for adj_tile in free_spaces_adjacent:
			# Ignore if in closed_list
			if contains(closed_list, adj_tile):
				continue
			# Add to open_list
			if !contains(open_list, adj_tile):
				insertFOrdered(open_list, adj_tile)
			else:
				# Test if using the current G score make the aSquare F score lower, if yes update the parent because it means its a better path
				pass
		# Do nothing if there are no free spaces to move
		
			
	

# Util -------------------------------------------------------------------------

# Compare tile's x and y to see if in a list
func contains(list, target_tile):
	for tile in list:
		if tile.x == target_tile.x and tile.y == target_tile.y:
			return true
	return false

# Turn an array of adjacent spaces into an array of adjacent Tile objects
func adjacentList(free_spaces, parent, target_vec):
	var adjacent_arr = []
	for space in free_spaces:
		adjacent_arr.append(Tile.new(parent, space, parent.g+1, calcH(space,target_vec)))
	return adjacent_arr

# Insert a tile into a list, keeping it ordered by lowest F in front
func insertFOrdered(tile, list):
	for index in range (0,list.size()):
		if tile.f <= list[index]:
			list.insert(index, tile)
			return


# Calc the Heuristic value to get from pos to target pos (ignoring walls)
func calcH(vec, target_vec):
	return abs(vec.x - target_vec.x) + abs(vec.y - target_vec.y)

# Get the ai tick function based on string name
func get_callback(func_name):
	match func_name:
		"none":
			return none_func
		"monster_classic":
			return monster_classic_func
