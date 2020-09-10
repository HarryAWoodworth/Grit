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
		
	func equals(otherTile):
		return x == otherTile.x and y == otherTile.y
		
	func toStr():
		return "(" + str(x) + "," + str(y) + ") g=" + str(g) + " h=" + str(h) + " f=" + str(f) 

# AI's -------------------------------------------------------------------------

# AI types
var none_func = funcref(self, "none")
var monster_classic_func = funcref(self, "monster_classic")

func none(_node, _game):
	pass

# Monster Classic AI
# Uses A* Pathfinding
func monster_classic(node, game):
	if !node.target_aquired or node.target_just_aquired:
		return
	# Check adjacent, if so, attack
	if node.adjacent(node.target):
		return
	# Else find the best path through A* and move one tile closer
	# Open and closed lists
	var closed_list = []
	var open_list = []
	var goal = Tile.new(null,node.target.curr_tile,0,0)
	var path_found = false
	# Add the original position ot the open list
	open_list.append(Tile.new(null,node.curr_tile,0,calcH(node.curr_tile, goal)))
#	print(open_list[0].toStr())
	# Iterate while the open list is not empty and no path has been found
	while !open_list.empty() and !path_found:
		# Get the tile with the lowest F from the open list
		var currentTile = open_list.pop_front()
		# Add it to the closed list
		closed_list.append(currentTile)
		# If the goal is adjacent to the current search tile, path has been found
		if adjacent(currentTile, goal):
			path_found = true
			var tmp = currentTile
			while tmp.parent.parent != null:
				tmp = tmp.parent
			game.move_actor_xy(tmp.x, tmp.y, node)
			return
		# Get all of the surrounding free spaces
		var free_spaces_adjacent = adjacentList(game.get_surrounding_empty(currentTile.x,currentTile.y),currentTile,goal)
		# Do nothing if the node is boxed in
		if free_spaces_adjacent.empty():
			return
		# Go through each adjacent node and check if its in the closed/open lists
		for adj_tile in free_spaces_adjacent:
			# Ignore if in closed list
			if contains(closed_list, adj_tile) != -1:
				continue
			# If in open list, see if it can be updated to have a better F score on the current path
			var index_open = contains(open_list, adj_tile)
			if index_open != -1:
				if open_list[index_open].f > adj_tile.f:
					open_list.remove(index_open)
					insertFOrdered(open_list, adj_tile)
			# Otherwise add to open list
			else:
				insertFOrdered(open_list, adj_tile)
#			else:
				# Test if using the current G score make the aSquare F score lower, if yes update the parent because it means its a better path


# Util -------------------------------------------------------------------------

# Compare tile's x and y to see if in list
func contains(list, target_tile):
	var index = 0
	for tile in list:
		if tile.equals(target_tile):
			return index
		index = index + 1
	return -1

func adjacent(tile, goal):
	return abs(tile.x - goal.x) <= 1 and abs(tile.y - goal.y) <= 1
	
# Turn an array of adjacent spaces into an array of adjacent Tile objects
func adjacentList(free_spaces, parent, target_vec):
	var adjacent_arr = []
	for space in free_spaces:
		var space_loc = Vector2(parent.x + space.x, parent.y + space.y)
		adjacent_arr.append(Tile.new(parent, space_loc, parent.g+1, calcH(space_loc,target_vec)))
	return adjacent_arr

# Insert a tile into a list, keeping it ordered by lowest F in front
func insertFOrdered(list:Array, tile):
	if list.empty():
		list.append(tile)
		return
	for index in range (0,list.size()):
		if tile.f <= list[index].f:
			list.insert(index, tile)
			return

# Calc the Heuristic value to get from pos to target pos (ignoring walls)
func calcH(vec, target_vec):
	var ret = abs(vec.x - target_vec.x) + abs(vec.y - target_vec.y)
	return ret

# Get the AI tick function based on string name
func get_callback(func_name):
	match func_name:
		"none":
			return none_func
		"monster_classic":
			return monster_classic_func
