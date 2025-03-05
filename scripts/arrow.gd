class_name Arrow
extends StaticBody2D

@export var speed = 500
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta
