class_name Bat
extends Enemy

const ARROW = preload("res://scenes/arrow.tscn")

@onready var target_area: Area2D = $TargetArea2D
@onready var move_timer: Timer = $MoveTimer

var too_close = false

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
			velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)
		State.DYING:
			velocity = Vector2.ZERO
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
