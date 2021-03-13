extends Node

# Ticker class keeps track of a schedule of actor turns and the current tick count of the game

var ticks: int
var schedule

func init():
	ticks = 0
	schedule = {}

func load_ticker(ticks_, schedule_):
	ticks = ticks_
	schedule = schedule_

func schedule_action(actor, interval):
	var tick_num = ticks + interval
	if schedule.has(tick_num):
		schedule[tick_num].append(actor)
	else:
		schedule[tick_num] = [actor]
		
func next_turn():
	# Get the array of turns at current ticks, or empty array if none
	var turns_to_take = schedule.get(ticks,[])
	# Call take_turn() on every actor in the list
	for actor in turns_to_take:
		if actor.identifier != "player":
			actor.take_turn()
			turns_to_take.erase(actor)
		else:
			turns_to_take.erase(actor)
			# return false if player is taking their turn
			return false
	# Erase the entry so that the dictionary doesn;t get titanic
	schedule.erase(ticks)
	return true
	
func print_ticker():
	print("Ticks: " + str(ticks))
	print("Schedule: " + str(schedule))
