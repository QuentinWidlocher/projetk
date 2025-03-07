class_name EnemyResource
extends Resource

@export_group("Stats")
@export var max_health: float = 100
@export var knockback: float = 1
@export_range(0.1, 10, 0.1, "suffix: x") var self_knockback_mult: float = 1

@export_group("Vision")
@export_range(1, 30, 0.5, "suffix: cases") var vision_distance: float = 5

@export_group("Movement")
@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10
