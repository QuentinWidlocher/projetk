class_name Enemy
extends CharacterBody2D

@export var max_health: float = 100
@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10
@export var knockback: float = 2000

@onready var vision_area: Area2D = $VisionArea2D
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
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			player = body

	debug_label.write("State: %s" % STATES[current_state])
	debug_label.write("Health: %d/%d" % [health, max_health])
	debug_label.write("Can See Player: %s" % (player != null))

func on_hit(damage: int, source_position: Vector2):
	health -= damage
	velocity = (global_position - source_position).normalized() * knockback
	animation_player.play("hit")
	if health <= 0:
		current_state = State.DYING
