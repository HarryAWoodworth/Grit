extends Node

var game
var player

func init(game_):
	game = game_
	player = game.player


# Parse an IF criteria action. Return true 
func eval_if(parseable):
	# The type of statement we are evaluating
	var evaluation_type = parseable.substr(1,3)
	var evaluation_str = parseable.substr(4)
	print("Eval type: " + evaluation_type + ", Eval str: " + evaluation_str)
	match evaluation_type:
		"EFF":
			return player.has_effect(evaluation_str)
		"HE>":
			return player.health > evaluation_str.to_int()
		"HE<":
			return player.health < evaluation_str.to_int()
	return false
	
# REfungus_leech
# H+5,Cmetal_can
func do_action(effect_string):
	print("Action_Parse do_action(): " + effect_string)
	var effect_type = effect_string.substr(0,3)
	var effect_value = effect_string.substr(3)
	print("Effect Type: " + effect_type + ", Effect Val: " + effect_value)
	match effect_type:
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
			
	# Go through all actions
		# Get the starting character
		# Evaluate Action
#		if symb == '[':
#			action_string = action_string.trim_prefix('[')
		# Evaluate IF
#		elif symb == '?':
#			symb = action_string[1]
#			action_string = action_string.trim_prefix("?" + symb)
			# E -> Has Effect, H -> Health, U -> Hunger
#			match symb:
#				'E':
#					pass
#				'H':
#					pass
#				'U':
#					pass
#		else:
#			print("ERROR: Parsing Action String:\n" + action_string + "Invalid start character '" + action_string)
