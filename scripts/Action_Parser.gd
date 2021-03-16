extends Node

var game

func init(game_):
	game = game_


# Parse an IF criteria action. Return true 
func eval_if(parseable):
	var evaluation_type = parseable[1]
	var evaluation_str = parseable.substr(2)
	
	# TODO
	print("Parseable: " + evaluation_str)
	return true

# Parse the effect string from item_list.json into a dictionary of commands and effect strings
func parse(effects):
	for key in effects.keys():
		pass
	
func do_action():
	pass
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
