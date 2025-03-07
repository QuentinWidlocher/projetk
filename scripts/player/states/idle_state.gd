class_name IdleState
extends BaseState

func process(_delta: float):
	if player.velocity.length() > player.acceleration * 10:
		player.play_animation("run")
	else:
		player.play_animation("idle")

	var move_axis = player.get_move_axis().normalized()

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

	if Input.is_action_pressed("object_category_1"):
		return AimState.new(player)

	if move_axis.length() > 0:
		return RunState.new(player)

func physics_process(delta: float):
	player.decelerate(delta)
