extends Node

var Bullet = preload("res://scenes/Bullet.tscn")

func _ready():
	set_process(true)

func init():
	pass

func shoot(mouse_position: Vector2, ranged_accuracy_dropoff: int):
	var b = Bullet.instance()
	add_child(b)
	b.position = get_parent().Center_Of_Player.position
	var direction_to_mouse = b.global_position.direction_to(mouse_position).normalized()
	b.rotation = direction_to_mouse.angle() + rand_range((-1 * ranged_accuracy_dropoff), ranged_accuracy_dropoff)
	b.set_direction(direction_to_mouse)
