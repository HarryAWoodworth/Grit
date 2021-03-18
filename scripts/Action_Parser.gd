extends Node

var game
var player

func init(game_):
	game = game_
	player = game.player

# Parse an IF criteria action. Return true 
func eval_if(effect_eval):
	# The type of statement we are evaluating
	var evaluation_type = effect_eval.substr(1,3)
	var evaluation_str = effect_eval.substr(4)
	print("Eval type: " + evaluation_type + ", Eval str: " + evaluation_str)
	match evaluation_type:
		# Has Effect
		"EFF":
			return player.has_effect(evaluation_str)
		# Health Greater Than
		"HE>":
			return player.health > evaluation_str.to_int()
		# Health Less Than
		"HE<":
			return player.health < evaluation_str.to_int()
	return false

# Parse an effect string and execute its effect(s) on the Player
func do_action(effect_string, focus=null):
	print("Action_Parse do_action(): " + effect_string)
	# Split into all actions
	var effect_arr = effect_string.split(',')
	for effect in effect_arr:
		var effect_type = effect.substr(0,3)
		var effect_value = effect.substr(3)
		print("Effect Type: " + effect_type + ", Effect Val: " + effect_value)
		match effect_type:
			"DES":
				focus.remove_item()
			# Remove Effect
			"RME":
				player.remove_effect(effect_value)
			# Add Effect
			"ADE":
				player.add_effect(effect_value)
			# Create Item In Player's Inventory
			"CR8":
				player.inventory.add_item(game.get_item_from_manager(effect_value))
			# Health Gain
			"HE+":
				player.gain_health(effect_value.to_int())
			# Health Loss
			"HE-":
				player.lose_health(effect_value.to_int())
