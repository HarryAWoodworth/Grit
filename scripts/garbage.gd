# Move an actor node to a tile
#func move_actor(vector, node, turn=1):
#	
#	# Set texture
#	if turn == 1 and node.changeable_texture:
#		match vector:
#			Vector2(1,0):
#				node.sprite.set_texture(node.right)
#				node.curr_tex = "right"
#			Vector2(-1,0):
#				node.sprite.set_texture(node.left)
#				node.curr_tex = "left"
#			Vector2(0,-1):
#				node.sprite.set_texture(node.up)
#				node.curr_tex = "up"
#			Vector2(0,1):
#				node.sprite.set_texture(node.down)
#				node.curr_tex = "down"
#				
#	# Coords
#	var dx = vector.x
#	var dy = vector.y
#	var temp_x = node.curr_tile.x
#	var temp_y = node.curr_tile.y
#	var x = node.curr_tile.x + dx
#	var y = node.curr_tile.y + dy
#	
#	# Melee combat via running into enemy
#	var actor_adjacent = get_actor_at(x,y)
#	if typeof(actor_adjacent) != 2:
#		if (node.identifier == "player" and actor_adjacent.identifier == "enemy") or (node.identifier == "enemy" and actor_adjacent.identifier == "player"):
#			exchange_combat_damage(node, actor_adjacent)
#			cant_move_anim(dx,dy,node)
#			return true
#	
#	if can_move(node.curr_tile.x + dx, node.curr_tile.y + dy):
#		
#		if node.hidden:
#			# Update the node's current tile
#			node.curr_tile = Vector2(x,y)
#			actor_map[temp_x][temp_y] = 0
#			actor_map[x][y] = node
#			node.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
#		# Animate Tween
#		else:
#			# Set animating bool
#			#anim_finished = false
#			# Start tween
#			node.tween.interpolate_property(node, "position", node.curr_tile * TILE_SIZE, (Vector2(x,y) * TILE_SIZE), 1.0/ANIM_SPEED, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#			# Set bool that anim is finished using callback
#			#node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
#			# Start tween
#			node.tween.start()
#			# Update the node's current tile
#			node.curr_tile = Vector2(x,y)
#			actor_map[temp_x][temp_y] = 0
#			actor_map[x][y] = node
#			# Wait for the tween to end
#			if node.identifier == "player":
#				yield(get_tree().create_timer(0.25),"timeout")
#				# Tick when player is moved
#				tick()
#	else: 
#		cant_move_anim(dx,dy,node)

# Animate the actor moving halfway into the tile and bouncing back
#func cant_move_anim(dx,dy,node):
#	var x = node.curr_tile.x + dx
#	var y = node.curr_tile.y + dy
#	anim_finished = false
#	var dest = Vector2(x,y) * TILE_SIZE
#	if dx != 0:
#		dest.x = dest.x - (dx * (float(TILE_SIZE) / float(CANT_MOVE_ANIM_DIST)))
#	if dy != 0:
#		dest.y = dest.y - (dy * (float(TILE_SIZE) / float(CANT_MOVE_ANIM_DIST)))
#	node.tween.interpolate_property(node, "position", node.curr_tile * TILE_SIZE, dest, 1.0/ANIM_SPEED_CANT, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	node.tween.interpolate_property(node, "position", dest, node.curr_tile * TILE_SIZE, 1.0/ANIM_SPEED_CANT, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,node.tween.get_runtime())
#	node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
#	node.tween.interpolate_callback(self, node.tween.get_runtime(), "set_anim_done")
#	node.tween.start()
		
#func set_anim_done():
#	anim_finished = true


	
# Return true if nodes are adjacent (including diagonal)
#func adjacent(node):
#	var x = curr_tile.x
#	var y = curr_tile.y
#	var _x = node.curr_tile.x
#	var _y = node.curr_tile.y
#	return abs(x - _x) <= 1 and abs(y - _y) <= 1

# Optimizations:
# Check after every corner raycast result
#func check_los():
#	update()
#	var corner_res
#	var space_state = get_world_2d().direct_space_state
#	var tile_len = game.TILE_SIZE
#	var half_tile = tile_len/2
#	var center_of_player = Vector2(position.x + half_tile, position.y + half_tile)
#	for target in targets:
#		var iden = target.unique_id
#		var sightnodeOrEnemy = target.identifier == "sightnode" or target.identifier == "enemy"
#		var raymask = self.collision_mask
#		var exceptarr = [self]
#		# Floor sightnodes are onlyblocked by barriers and light-blocking actors
#		if sightnodeOrEnemy:
#			raymask = 20
#		# Side 1
#		#  and !corner_res.empty() 
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + half_tile, target.position.y), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 2
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + tile_len, target.position.y + half_tile), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 3
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x, target.position.y + half_tile), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		# Side 4
#		corner_res = space_state.intersect_ray(center_of_player, Vector2(target.position.x + half_tile, target.position.y + tile_len), exceptarr, raymask)
#		if (sightnodeOrEnemy and corner_res.empty()) or (!sightnodeOrEnemy and !corner_res.empty() and corner_res.collider.unique_id == iden):
#			show_target(target)
#			continue
#		hide_target(target)

#func show_target(target):
	#target.unshadow()
	
	
#func hide_target(target):
	#target.shadow()
	
	#	var size = hands[index].hand_size
#	# Remove item in hand
#	for x in range(size):
#		hands[index + x] = null
#	# Move all nulls to right side
#	hands.sort_custom(NullSorter,"sort_nulls_right")
		
#class NullSorter:
#	static func sort_nulls_right(a, b):
#		if a == null and b != null:
#			return false
#		return true

#func print_hands():
#	print("HANDS: [")
#	for item in hands:
#		if item != null:
#			print(item.item_name)
#	print("]")
