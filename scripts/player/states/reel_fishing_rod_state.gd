class_name ReelFishingRodState
extends BaseState

var max_reel_speed = 500.0
var current_reel_speed = max_reel_speed / 2
var acceleration = 100.0
var reel_distance = 300.0

func on_enter(_previous_state: BaseState):
	var reelable_hooked_target := get_reelable_hooked_target()
	if reelable_hooked_target:
		reelable_hooked_target.set_collision_mask_value(3, false) # prevent falling into holes
		reelable_hooked_target.set_collision_mask_value(4, false) # prevent damaging player
	else:
		player.set_collision_mask_value(3, false)

func on_exit():

	var reelable_hooked_target := get_reelable_hooked_target()
	if reelable_hooked_target:
		reelable_hooked_target.set_collision_mask_value(3, true)
		reelable_hooked_target.set_collision_mask_value(4, true)
	else:
		player.set_collision_mask_value(3, true)

	player.hooked_target = null

func process(delta: float):

	var dir = player.hooked_target.position - player.position

	var reelable_hooked_target := get_reelable_hooked_target()
	if reelable_hooked_target:
		player.run(delta)
		player.animate_running()
		reelable_hooked_target.velocity = reelable_hooked_target.velocity.lerp(-dir.normalized() * current_reel_speed, delta)
	else:
		player.animate_running()
		player.velocity = player.velocity.lerp(dir.normalized() * current_reel_speed, delta)

	current_reel_speed += acceleration

	if dir.length() < reel_distance:
		return IdleState.new(player)

func physics_process(_delta: float):
	pass

func get_reelable_hooked_target() -> CharacterBody2D:
	if player.hooked_target.is_in_group("reelable") and player.hooked_target is CharacterBody2D:
		return player.hooked_target as CharacterBody2D
	else:
		return null
