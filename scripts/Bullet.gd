extends Node2D

export (int) var speed = 30

var direction := Vector2.ZERO

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		position += velocity

func set_direction(direction_: Vector2):
	direction = direction_
