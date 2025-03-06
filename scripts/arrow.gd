class_name Arrow
extends CharacterBody2D

@export var speed = 500
@export var damage = 10
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	var collided = move_and_collide(Vector2.RIGHT.rotated(rotation) * speed * delta)
	if collided != null:
		if collided is Player or collided is Bat or collided.has_method("on_hit"):
			collided.call("on_hit", damage, global_position)
		queue_free()
