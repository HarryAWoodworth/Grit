extends Node

var Bullet = preload("res://scenes/Bullet.tscn")

func _ready():
	set_process(true)

func init():
	pass

func shoot(mouse_position: Vector2, ranged_accuracy_dropoff: int):
	var b = Bullet.instance()
	add_child(b)
	var inaccuracy = rand_range((-1 * ranged_accuracy_dropoff), ranged_accuracy_dropoff)
	b.position = get_parent().Center_Of_Player.position
	var direction_to_mouse = b.global_position.direction_to(mouse_position)
	direction_to_mouse.x = direction_to_mouse.x + inaccuracy
	direction_to_mouse.y = direction_to_mouse.y - inaccuracy
	var vec = direction_to_mouse.normalized()
	print("DIRECTION_TO_MOUSE: " + str(vec))
	b.set_direction(vec)
