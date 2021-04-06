extends Node

# Ticker class keeps track of a schedule of actor turns and the current tick count of the game

var ticks: int
var schedule
var player_turn_flag: bool

func init():
	ticks = 0
	schedule = {}
	player_turn_flag = false

# Initialize the ticker 
func load_ticker(ticks_, schedule_, player_turn_flag_=false):
	ticks = ticks_
	schedule = schedule_
	player_turn_flag = player_turn_flag_

# Schedule an actor in the ticker, 'interval' ticks away
func schedule_action(actor, interval):
	var tick_num = str(ticks + interval)
	if schedule.has(tick_num):
		schedule[tick_num].append(actor)
	else:
		schedule[tick_num] = [actor]
	#print("Ticker.schedule_action(" + actor.title + ", " + str(tick_num) + "): Schedule[" + str(tick_num) + "]: " + str(schedule[tick_num]))

func do_next_turn():
	# Get the array of turns at current ticks, or empty array if none
	#print("Schedule: " + str(schedule) + " Ticks: " + str(ticks))
	var turns_to_take = schedule.get(str(ticks),[])
	#print("Ticker.do_next_turn(): Tick: " + str(ticks) + ", turns_to_take: " + str(turns_to_take))
	# Set player_turn_flag to false
	player_turn_flag = false
	# Remove array from schedule to prevent dict bloat
	schedule.erase(str(ticks))
	# Increment Ticks
	ticks = ticks + 1
	# Call take_turn() on every scheduled event for the current tick
	for event in turns_to_take:
		# Set the player turn flag
		if event.identifier == "player":
			player_turn_flag = true
		# Tick an effect
		elif event.identifier == "effect":
				pass
		# Actor takes its turn
		else:
			event.take_turn()
	return player_turn_flag
	
func print_ticker():
	print("Ticks: " + str(ticks))
	print("Schedule: " + str(schedule))
