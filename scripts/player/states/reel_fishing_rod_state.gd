class_name ReelFishingRodState
extends BaseState

var max_reel_speed = 500.0
var current_reel_speed = max_reel_speed / 2
var acceleration = 100.0
var reel_distance = 300.0

func on_enter(_previous_state: BaseState):
	player.set_collision_mask_value(3, false)
	pass

func on_exit():
	player.set_collision_mask_value(3, true)
	player.hooked_target = null
	player.target_line.visible = false

func process(delta: float):
	var dir = player.hooked_target.position - player.position
	player.velocity = player.velocity.lerp(dir.normalized() * current_reel_speed, delta)
	current_reel_speed += acceleration

	if dir.length() < reel_distance:
		return IdleState.new(player)

func physics_process(delta: float):
	pass
