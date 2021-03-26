extends Node

var Bullet = preload("res://scenes/Bullet.tscn")

func _ready():
	set_process(true)

func init():
	pass

func shoot(mouse_position: Vector2, weapon):
	var innacuracy_angle = weapon.innacuracy_angle
	# Add bullet to scene
	var b = Bullet.instance()
	add_child(b)
	# Set the position to parent position
	b.position = Vector2(get_parent().position.x + 64,get_parent().position.y + 64)
	# Get the vector to the mouse position
	var direction_to_mouse = b.global_position.direction_to(mouse_position)
	# Change the vector based on a randomly selected angle within the innacuracy_angle
	var angle = rand_range((-1 * innacuracy_angle),innacuracy_angle) * (PI/180)
	var cosangle = cos(angle)
	var sinangle = sin(angle)
	var x_ = direction_to_mouse.x
	var y_ = direction_to_mouse.y
	var bullet_vector = Vector2(
			x_ * cosangle - y_ * sinangle,
			x_ * sinangle + y_ * cosangle
		).normalized()
	# Rotate the bullet and set it's direction
	b.rotation = (mouse_position - b.global_position).angle() + angle
	b.set_direction(bullet_vector)
