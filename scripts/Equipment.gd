extends Node

var right_hand
var left_hand
var both_hands

# Game and player ref
var game
var player

func init(game_, player_):
	game = game_
	player = player_
	right_hand = null
	left_hand = null

# Add item to hands (first empty hand, or default swap right)
func hold_item(item):
	#print("HOLD ITEM EQUIPMENT.gd: " + item.item_name)
	if item.hand_size == 1:
		if both_hands != null:
			#print("Swapping both hands, putting item in right hand")
			empty_hand("both")
			right_hand = item
		elif right_hand == null:
			#print("Putting item in right hand")
			right_hand = item
		elif left_hand == null:
			#print("Putting item in left hand")
			left_hand = item
		else:
			#print("Swapping item in right hand")
			# Always swap right hand if both hands are full
			empty_hand("right")
			right_hand = item
	else:
		#print("Putting in both hands")
		if both_hands != null:
			empty_hand("both")
		else:
			#print("Emptying both hands first")
			if right_hand != null:
				empty_hand("right")
			if left_hand != null:
				empty_hand("left")
		both_hands = item
	game.update_equipment_ui()

func unequip_item(item, drop=false):
	if item == null:
		print("Equipment.gd.drop_item(): Trying to drop/unequip a null item!")
	elif both_hands != null and both_hands == item:
		if !drop:
			empty_hand("both_hands")
		else:
			empty_hand_drop("both_hands")
	elif right_hand != null and right_hand == item:
		if !drop:
			empty_hand("right")
		else:
			empty_hand_drop("right")
	elif left_hand != null and left_hand == item:
		if !drop:
			empty_hand("left")
		else:
			empty_hand_drop("left")
	else:
		print("Equipment.gd.drop_item(): Failed to drop/unequip item with id: " + item.id + ", not present in equipment!")

# Empty input hand to inventory, or both hands
func empty_hand(hand):
	if hand == "right":
		if right_hand == null:
			print("Equipment.gd.empty_hand(): Trying to unequip item from empty right hand")
			return
		#print("Emptying right hand: " + right_hand.item_name)
		player.inventory.add_item_no_weight_change(right_hand)
		right_hand = null
	elif hand == "left":
		if left_hand == null:
			print("Equipment.gd.empty_hand(): Trying to unequip item from empty left hand")
			return
		#print("Emptying left hand: " + left_hand.item_name)
		player.inventory.add_item_no_weight_change(left_hand)
		left_hand = null
	else:
		if both_hands == null:
			print("Equipment.gd.empty_hand(): Trying to unequip item from empty both hands")
		player.inventory.add_item_no_weight_change(both_hands)
		both_hands = null
	
func empty_hand_drop(hand):
	if hand == "right":
		if right_hand == null:
			print("Equipment.gd.empty_hand_drop(): Trying to drop item from empty right hand")
			return
		player.inventory.reduce_weight(right_hand.weight)
		game.item_drop(right_hand)
		right_hand = null
	elif hand == "left":
		if left_hand == null:
			print("Equipment.gd.empty_hand(): Trying to drop item from empty right hand")
			return
		player.inventory.reduce_weight(left_hand.weight)
		game.item_drop(left_hand)
		left_hand = null
	else:
		if both_hands == null:
			print("Equipment.gd.empty_hand(): Trying to drop item from empty both hands")
		player.inventory.reduce_weight(both_hands.weight)
		game.item_drop(both_hands)
		both_hands = null

func empty():
	return right_hand == null and left_hand == null and both_hands == null

func decrement(string):
	if string == "both_hands":
		both_hands.current_ammo = both_hands.current_ammo - 1
	elif string == "right_hand":
		right_hand.current_ammo = right_hand.current_ammo - 1
	elif string == "left_hand":
		left_hand.current_ammo = left_hand.current_ammo - 1

func reload():
	# return if empty
	if empty():
		return
	# Reload all weapons in hands
	var reloaded = false
	var toReload
	if both_hands != null and both_hands.max_ammo != null:
		# game.reload_from_inv removes bullets from inventory and returns number of bullets removed
		toReload = game.reload_from_inv(both_hands.max_ammo - both_hands.current_ammo, both_hands.ammo_type)
		if toReload == 0:
			print("Equipment.reload(): No bullets to reload")
			return false
		both_hands.current_ammo = both_hands.current_ammo + toReload
		game.update_equipment_ui_ammo("both_hands", both_hands)
	else:
		# Reloads RIGHT HAND FIRST ALWAYS!
		if right_hand != null and right_hand.max_ammo != null:
			toReload = game.reload_from_inv(right_hand.max_ammo - right_hand.current_ammo, right_hand.ammo_type)
			right_hand.current_ammo = right_hand.current_ammo + toReload
			game.update_equipment_ui_ammo("right_hand", right_hand)
		if left_hand != null and left_hand.max_ammo != null:
			toReload = game.reload_from_inv(left_hand.max_ammo - left_hand.current_ammo, left_hand.ammo_type)
			left_hand.current_ammo = left_hand.current_ammo + toReload
			game.update_equipment_ui_ammo("left_hand", left_hand)
