class_name ReelFishingRodState
extends BaseState

var reel_speed = 100.0
var reel_distance = 10.0

func on_enter(_previous_state: BaseState):
	pass

func on_exit():
	pass

func process(delta: float):
	var dir = player.hooked_target.position - player.position
	player.velocity = player.velocity.lerp(dir, delta * reel_speed)

	if dir.length() < reel_distance:
		return IdleState.new(player)

func physics_process(delta: float):
	pass
