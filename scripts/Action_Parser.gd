extends Node

var game

func init(game_):
	game = game_

# Parse the effect string from item_list.json into an array of action strings
func parse(effect: String):
	# Remove tabs, spaces, and newlines
	var action_string = effect.dedent().strip_escapes()
	var actions = []
	var right_bracket = action_string.find(']')
	var left
	# Split all of the different actions into seperate strings and add to actions[]
	while right_bracket != -1:
		left = action_string.left(right_bracket)
		print("Action Found, Appending...: " + left)
		actions.append(left)
		action_string = action_string.substr(right_bracket+1)
		right_bracket = action_string.find(']')
	return actions
	
func do_action():
	# Go through all actions
	for action in actions:
		# Get the starting character
		var symb = action[0]
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
