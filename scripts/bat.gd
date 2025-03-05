class_name Bat
extends CharacterBody2D

enum State {
	IDLE,
	MOVE,
	ATTACK,
	COOLDOWN,
}

const STATES = ["Idle", "Move", "Attack", "Cooldown"]
const ARROW = preload("res://scenes/arrow.tscn")

@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10

@onready var target_area: Area2D = $TargetArea2D
@onready var vision_area: Area2D = $VisionArea2D
@onready var move_timer: Timer = $MoveTimer
@onready var debug_label: Label = %DebugLabel
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state: State = State.IDLE

var player: Player = null

var too_close = false

func _process(delta: float) -> void:
	player = null
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			player = body

	var target_too_close = false
	for body in target_area.get_overlapping_bodies():
		if body is Player:
			target_too_close = true

	debug_label.text = "State: %s\nCan See Player: %s\nTarget Too Close: %s\nTimer: %0.1f" % [STATES[current_state], player != null, target_too_close, move_timer.time_left]

	match current_state:
		State.IDLE:
			too_close = target_too_close
			if player != null:
				current_state = State.MOVE
		State.MOVE:
			# If the bat can't see the player, just stay idle
			if player == null:
				current_state = State.IDLE
			else:
				var direction = (player.position - position).normalized()

				if not too_close and target_too_close:
					# bat is now too close
					current_state = State.ATTACK
					move_timer.start()
					velocity = Vector2.ZERO
					return

				if too_close and target_too_close:
					# bat is now too far away
					direction *= -1

				too_close = target_too_close

				velocity = velocity.lerp(direction * max_speed, delta * acceleration)

	move_and_slide()

func fire_arrow(direction: Vector2):
	var arrow_instance: Arrow = ARROW.instantiate()
	arrow_instance.global_rotation = direction.angle()
	arrow_instance.global_position = sprite.global_position + direction * 100
	get_tree().current_scene.add_child(arrow_instance)


func _on_attack_timer_timeout() -> void:
	if current_state == State.ATTACK and player != null:
		var direction = (player.position - position).normalized()
		fire_arrow(direction)

func _on_move_timer_timeout() -> void:
	current_state = State.IDLE
	move_timer.stop()
