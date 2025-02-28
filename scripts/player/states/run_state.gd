class_name RunState
extends BaseState

func on_enter(_previous_state: BaseState):
	pass

func on_exit():
	pass

func process(_delta: float):
	var move_axis = player.get_move_axis().normalized()

	if move_axis.length() == 0:
		return IdleState.new(player)

	if Input.is_action_pressed("object_category_1"):
		if Input.is_action_pressed("fishing_rod"):
			if player.hooked_target != null:
				return ReelFishingRodState.new(player)
			else:
				return ThrowFishingRodState.new(player)

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

func physics_process(delta: float):
	var move_axis = player.get_move_axis()

	if move_axis.length() > 0:
		player.velocity = player.velocity.lerp(move_axis * player.max_speed, delta * player.acceleration)
	else:
		# Decelerate
		player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)
