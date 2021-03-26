extends ColorRect

onready var Icon = $TextureRect
onready var ActionGrid = $GridContainer
onready var Description = $Label

var ActionLabel = preload("res://scenes/ActionLabel.tscn")

var effect_dict = {}

func add_action(action_str, key_str, effect_ticks=0, effect_str=null):
	if effect_str != null:
		print("Adding Action to InfoPanel: " + action_str + ", key: " + key_str + ", effect: " + effect_str + ", ticks: " + str(effect_ticks))
		effect_dict[key_str] = [effect_str, effect_ticks]
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

func get_action(input: String):
	if effect_dict.has(input):
		return effect_dict[input][0]
	print("ERROR: Effect Dict does not have action: " + input)
	return null

func get_ticks(input: String):
	if effect_dict.has(input):
		return effect_dict[input][1]
	print("ERROR: Effect Dict does not have action: " + input)
	return -1
