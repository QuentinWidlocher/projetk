class_name AimState
extends BaseState

func on_enter(_previous_state: BaseState):
	player.aim_arrow.visible = true

func on_exit():
	player.aim_arrow.visible = false

func process(_delta: float):
	player.aim_arrow.rotation = player.direction.angle()

	player.play_animation("idle")

	if Input.is_action_just_released("fishing_rod"):
		if player.hooked_target != null:
			return ReelFishingRodState.new(player)
		else:
			return ThrowFishingRodState.new(player)

	if Input.is_action_just_released("object_category_1"):
		return IdleState.new(player)


func physics_process(delta: float):
	player.decelerate(delta)
