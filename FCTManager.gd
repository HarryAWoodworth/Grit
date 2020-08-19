extends Node2D

const TRAVEL_Y = -4
const TRAVEL_X = 0
const DEFAULT_TRAVEL = Vector2(TRAVEL_X, TRAVEL_Y)
const DEFAULT_DURATION = 0.5
const DEFAULT_SPREAD = 0

var FCT = preload("res://util/DamageText.tscn")

func show_value(value, crit=false, travel=DEFAULT_TRAVEL, duration=DEFAULT_DURATION, spread=DEFAULT_SPREAD):
	print("Showing value " + str(value))
	var fct = FCT.instance()
	add_child(fct)
	fct.show_value(str(value), travel, duration, spread, crit)
