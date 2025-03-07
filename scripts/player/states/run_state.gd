class_name RunState
extends BaseState

func process(_delta: float):
	player.play_animation("run")

	var move_axis = player.get_move_axis().normalized()

	if move_axis.length() == 0:
		return IdleState.new(player)

	if Input.is_action_pressed("object_category_1"):
		return AimState.new(player)

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

func physics_process(delta: float):
	var move_axis = player.get_move_axis()

	if move_axis.length() > 0:
		player.velocity = player.velocity.lerp(move_axis * player.max_speed, delta * player.acceleration)
	else:
		player.decelerate(delta)
