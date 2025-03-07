class_name Swoosh
extends Node2D

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body is Enemy:
		body.on_hit(10, global_position, 1000)
