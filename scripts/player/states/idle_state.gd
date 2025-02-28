class_name IdleState
extends BaseState

func process(_delta: float):
	var move_axis = player.get_move_axis().normalized()

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

	if Input.is_action_pressed("object_category_1"):
		if Input.is_action_just_pressed("fishing_rod"):
			if player.hooked_target != null:
				return ReelFishingRodState.new(player)
			else:
				return ThrowFishingRodState.new(player)

	if move_axis.length() > 0:
		return RunState.new(player)

func physics_process(delta: float):
	# Decelerate
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)
