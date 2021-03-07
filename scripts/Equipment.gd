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
	print("HOLD ITEM EQUIPMENT.gd: " + item.item_name)
	if item.hand_size == 1:
		if both_hands != null:
			print("Swapping both hands, putting item in right hand")
			empty_hand("both")
			right_hand = item
		elif right_hand == null:
			print("Putting item in right hand")
			right_hand = item
		elif left_hand == null:
			print("Putting item in left hand")
			left_hand = item
		else:
			print("Swapping item in right hand")
			# Always swap right hand if both hands are full
			empty_hand("right")
			right_hand = item
	else:
		print("Putting in both hands")
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
		game.player.inventory.add_item_no_weight_change(both_hands)
		both_hands = null
			
func empty():
	return right_hand == null and left_hand == null
	
