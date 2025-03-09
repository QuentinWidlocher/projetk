class_name IdleState
extends BaseState

func process(_delta: float):
	player.animate_running()

	var move_axis = player.get_move_axis().normalized()

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

	if Input.is_action_pressed("object_category_1"):
		return AimState.new(player)

	if move_axis.length() > 0:
		return RunState.new(player)

func physics_process(delta: float):
	player.decelerate(delta)
