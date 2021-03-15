extends Node

var game

func init(game_):
	game = game_

func parse_and_do(action_string: String):
	# Remove tabs and spaces
	action_string = action_string.dedent()
	# Consume the entire string
	while !action_string.empty():
		# Get the starting character
		var symb = action_string[0]
		# Evaluate Action
		if symb == '[':
			action_string.trim_prefix('[')
			var 
		# Evaluate IF
		elif symb == '?':
			symb = action_string[1]
			action_string.trim_prefix("?" + symb)
			print("Action String ? Trim: " + action_string)
			# E -> Has Effect, H -> Health, U -> Hunger
			match symb:
				'E':
					pass
				'H':
					pass
				'U':
					pass
		else:
			print("ERROR: Parsing Action String:\n" + action_string + "Invalid start character '" + action_string)
