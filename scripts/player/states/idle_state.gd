class_name IdleState
extends BaseState

var ready_for_object: bool = false

func on_enter(previous_state: BaseState):
	if (
			previous_state is ThrowBombState
		or 	previous_state is ReelFishingRodState
		or 	previous_state is ThrowFishingRodState
	):
		ready_for_object = false
		player.get_tree().create_timer(0.5).connect("timeout", func():
			ready_for_object = true
		)
	else:
		ready_for_object = true

func process(_delta: float):
	player.animate_running()

	var move_axis = player.get_move_axis().normalized()

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

	if ready_for_object and Input.is_action_pressed("object_category_1"):
		print("goin")
		return AimState.new(player)

	if move_axis.length() > 0:
		return RunState.new(player)

func physics_process(delta: float):
	player.decelerate(delta)
