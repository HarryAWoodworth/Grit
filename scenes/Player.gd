extends Area2D

var curr_tile
onready var tween = $Sprite/Tween

func tick():
	print("Player ticked!")

func _input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			on_click()
			
func on_click():
	print("Player clicked!")
