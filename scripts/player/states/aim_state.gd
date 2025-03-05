class_name AimState
extends BaseState

func process(_delta: float):
	var aim_axis = player.get_move_axis().normalized()

	if Input.is_action_just_released("object_category_1"):
		return IdleState.new(player)

	if Input.is_action_just_released("fishing_rod"):
		if player.hooked_target != null:
			return ReelFishingRodState.new(player)
		else:
			return ThrowFishingRodState.new(player)

func physics_process(delta: float):
	# Decelerate
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)
