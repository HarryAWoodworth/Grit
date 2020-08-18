extends VBoxContainer

onready var actor_sprite = $ActorSprite
onready var actor_title = $ActorTitle
onready var actor_description = $ActorDescription

# Default hide all elements
func _ready():
	actor_sprite.hide()
	actor_title.hide()
	actor_description.hide()
	
# Set the info based on the actor node, show elements
func list_info(actor):
	#Set
	actor_sprite.texture = actor.sprite.texture
	actor_title.text = actor.title
	actor_description.text = actor.description
	#Show
	actor_sprite.show()
	actor_title.show()
	actor_description.show()
	
# Hide all UI elements
func clear():
	actor_sprite.hide()
	actor_title.hide()
	actor_description.hide()
