extends Node2D

export (int) var speed = 30

var direction := Vector2.ZERO

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		position += velocity

func set_direction(direction_: Vector2):
	direction = direction_

# If a bullet hits a body, the body calls handle_hit()
func _on_Area2D_body_entered(body):
	queue_free()
	if body.has_method("handle_hit"):
		body.handle_hit()
		
