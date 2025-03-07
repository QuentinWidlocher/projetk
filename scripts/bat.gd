class_name Bat
extends Enemy

const ARROW = preload("res://scenes/arrow.tscn")

@export var resource: BatResource = preload("res://resources/enemies/default_bat.tres")

@onready var target_area: Area2D = $TargetArea2D
@onready var target_shape: CollisionPolygon2D = $TargetArea2D/CollisionPolygon2D
@onready var attack_timer: Timer = $AttackTimer
@onready var move_timer: Timer = $MoveTimer
@onready var move_timeout_timer: Timer = $MoveTimeoutTimer

var safe_distance: float = 3
var too_close = false

func _ready():
	load_resource()
	health = max_health

func _process(delta: float) -> void:
	super(delta)

	var target_too_close = false
	for body in target_area.get_overlapping_areas():
		if body.get_parent() is Player:
			target_too_close = true

	debug_label.write("Target Too Close: %s" % target_too_close)
	debug_label.write("Timer: %0.1f" % move_timer.time_left)

	match current_state:
		State.IDLE:
			too_close = target_too_close
			if player != null:
				current_state = State.MOVE
				move_timeout_timer.start()
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
		State.ATTACK:
			if player == null:
				current_state = State.IDLE

			velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)
		State.DYING:
			animation_player.play("dying")

	move_and_slide()

func fire_arrow(direction: Vector2):
	var arrow_instance: Arrow = ARROW.instantiate()
	arrow_instance.knockback = knockback
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

func _on_move_timeout_timer_timeout() -> void:
	current_state = State.ATTACK
	move_timer.start()
	move_timeout_timer.stop()

func load_resource() -> void:
	_load_resource(resource as EnemyResource)
	target_shape.scale = Vector2(resource.safe_distance, resource.safe_distance)
	attack_timer.wait_time = resource.attack_interval
	move_timer.wait_time = resource.move_interval
	move_timeout_timer.wait_time = resource.move_timeout_interval
