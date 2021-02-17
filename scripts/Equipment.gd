extends Node

var hand_space
var hands
var selected_item

# Game and player ref
var game
var player

func init(game_, hand_space_):
	game = game_
	hands = []
	hand_space = hand_space_
	for _x in range(hand_space):
		hands.append(null)

# Add item to hands
func hold_item(item):
	print("ITEM HOLD_ITEM EQUIPMENT.gd: " + str(item))
	if hands.count(null) < item.hand_size:
		return false
	var ind = hands.find(null)
	for size in range(item.hand_size):
		hands[ind + size] = item
	selected_item = item
	return true
	
func move_item_to_inventory(index):
	var size = hands[index].hand_size
	# Remove item in hand
	for x in range(size):
		hands[index + x] = null
	# Move all nulls to right side
	hands.sort_custom(NullSorter,"sort_nulls_right")
		
class NullSorter:
	static func sort_nulls_right(a, b):
		if a == null and b != null:
			return false
		return true
		
func print_hands():
	print("HANDS: [")
	for item in hands:
		if item != null:
			print(item.item_name)
	print("]")
	
func empty():
	return hands.count(null) == hands.size()
	
