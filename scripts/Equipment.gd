extends Node

var right_hand
var left_hand
var both_hands

# Game and player ref
var game
var player

func init(game_):
	game = game_
	right_hand = null
	left_hand = null

# Add item to hands (first empty hand, or default swap right)
func hold_item(item):
	# print("HOLD ITEM EQUIPMENT.gd: " + str(item))
	if item.hand_size == 1:
		if right_hand == null:
			right_hand = item
			return
		elif left_hand == null:
			left_hand = item
			return
		else:
			# Always swap right hand if both hands are full
			empty_hand("right")
			right_hand = item
			return
	else:
		empty_hand("right")
		empty_hand("left")
		both_hands = item
		
	game.update_equipment_ui()

# Empty input hand to inventory, or both hands
func empty_hand(hand):
	if hand == "right":
		if right_hand == null:
			return
		game.player.inventory.add_item_no_weight_change(right_hand)
		right_hand = null
	elif hand == "left":
		if left_hand == null:
			return
		game.player.inventory.add_item_no_weight_change(left_hand)
	else:
		if right_hand != null:
			empty_hand("right")
		if left_hand != null:
			empty_hand("left")
			
func empty():
	return right_hand == null and left_hand == null
	
