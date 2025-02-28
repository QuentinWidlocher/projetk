class_name IdleState
extends BaseState


func on_enter(_previous_state: BaseState):
	pass

func on_exit():
	pass

func process(_delta: float):
	var move_axis = player.get_move_axis().normalized()

	if Input.is_action_just_pressed("attack"):
		return AttackState.new(player)

	if move_axis.length() > 0:
		return RunState.new(player)


func physics_process(delta: float):
	# Decelerate
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)
