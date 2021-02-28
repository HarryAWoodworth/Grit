extends ColorRect

onready var Icon = $TextureRect
onready var ActionGrid = $GridContainer
onready var Description = $Label

var ActionLabel = preload("res://scenes/ActionLabel.tscn")

func add_action(action_str):
	var newLabel = ActionLabel.instance()
	ActionGrid.add_child(newLabel)
	newLabel.text = action_str
