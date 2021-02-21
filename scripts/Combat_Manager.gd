extends Node

var Bullet = preload("res://scenes/Bullet.tscn")

func _ready():
	set_process(true)

func init():
	pass

func shoot(mouse_position: Vector2, innacuracy_angle: int):
	# Add bullet to scene
	var b = Bullet.instance()
	add_child(b)
	# Set the position to parent position
	b.position = Vector2(get_parent().position.x + 64,get_parent().position.y + 64)
	# Get the vector to the mouse position
	var direction_to_mouse = b.global_position.direction_to(mouse_position)
	# Change the vector based on a randomly selected angle within the innacuracy_angle
	print("Direction_to_mouse: " + str(direction_to_mouse))
	#var angle = rand_range((-1 * innacuracy_angle),innacuracy_angle)
	var angle = 15
	var cosangle = cos(angle) * (180.0/PI)
	print("Cosangle: " + str(cosangle))
	var sinangle = sin(angle) * (180.0/PI)
	var x_ = direction_to_mouse.x
	var y_ = direction_to_mouse.y
	var bullet_vector = Vector2(
			x_ * cosangle - y_ * sinangle,
			x_ * sinangle + y_ * cosangle
		).normalized()
	print("Bullet Vector: " + str(bullet_vector))
	b.set_direction(bullet_vector)
