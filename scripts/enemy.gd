class_name Enemy
extends CharacterBody2D

var max_health: float = 100
var max_speed: float = 800
var acceleration: float = 10
var decceleration: float = 10
var knockback: float = 2000
var self_knockback_mult: float = 1

@onready var vision_area: Area2D = $VisionArea2D
@onready var vision_shape: CollisionPolygon2D = $VisionArea2D/CollisionPolygon2D
@onready var debug_label: DebugLabel = %DebugLabel
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var current_state: State = State.IDLE
var health = max_health
var player: Player = null

enum State {
	IDLE,
	MOVE,
	ATTACK,
	DYING,
}

const STATES = ["Idle", "Move", "Attack", "Dying"]

func _process(_delta: float) -> void:
	player = null
	for body in vision_area.get_overlapping_areas():
		if body.get_parent() is Player:
			player = body.get_parent()

	debug_label.write("State: %s" % STATES[current_state])
	debug_label.write("Health: %d/%d" % [health, max_health])
	debug_label.write("Can See Player: %s" % (player != null))

func on_hit(damage: int, source_position: Vector2, knockback_force: float):
	health -= damage
	velocity = (global_position - source_position).normalized() * knockback_force * self_knockback_mult
	animation_player.play("hit")
	if health <= 0:
		current_state = State.DYING

func _load_resource(enemy_resource: EnemyResource) -> void:
	max_health = enemy_resource.max_health
	max_speed = enemy_resource.max_speed
	acceleration = enemy_resource.acceleration
	decceleration = enemy_resource.decceleration
	knockback = enemy_resource.knockback
	self_knockback_mult = enemy_resource.self_knockback_mult
	vision_shape.scale = Vector2(enemy_resource.vision_distance, enemy_resource.vision_distance)
