extends VBoxContainer

onready var actor_sprite = $ActorSprite
onready var actor_title = $ActorTitle
onready var actor_description = $ActorDescription

func _ready():
	actor_title.hide()
	actor_description.hide()

# Set the info based on the actor node
func list_info(actor):
	actor_sprite.texture = actor.sprite.texture
	actor_title.text = actor.title
	actor_description.text = actor.description
	actor_sprite.show()
	actor_title.show()
	actor_description.show()
func clear():
	actor_sprite.hide()
	actor_title.hide()
	actor_description.hide()
