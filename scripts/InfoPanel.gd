extends ColorRect

onready var Icon = $TextureRect
onready var ActionGrid = $GridContainer
onready var Description = $Label

var ActionLabel = preload("res://scenes/ActionLabel.tscn")

var effect_dict = {}

func add_action(action_str, effect_str=null):
	
	if effect_str != null:
		effect_dict[action_str] = effect_str
	
	var newLabel = ActionLabel.instance()
	ActionGrid.add_child(newLabel)
	newLabel.text = action_str

# Hide Icon, clear description text, remove all ActionLabels, and clear dict
func clear():
	Icon.hide()
	Description.text = ""
	for child in ActionGrid.get_children():
		child.queue_free()
	effect_dict.clear()
