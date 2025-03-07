class_name Arrow
extends Area2D

@export var speed = 500
@export var damage = 10
@export var knockback = 100
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_area_entered(area:Area2D) -> void:
	var collided = area

	if not (collided is Player or collided is Enemy) or not collided.has_method("on_hit"):
		collided = area.get_parent()

	if (collided is Player or collided is Enemy) and collided.has_method("on_hit"):
		collided.on_hit(damage, global_position, knockback)

	queue_free()
