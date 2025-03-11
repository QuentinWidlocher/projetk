class_name ReelFishingRodState
extends BaseState

var max_reel_speed = 500.0
var current_reel_speed = max_reel_speed / 2
var acceleration = 100.0
var reel_distance = 300.0

func on_enter(_previous_state: BaseState):
	var reelable_enemy := get_reelable_enemy()
	if reelable_enemy:
		reelable_enemy.toggle_reeled_colisions(false)
	else:
		player.set_collision_mask_value(3, false)
		player.hole_ray_cast.enabled = false

func on_exit():

	var reelable_enemy := get_reelable_enemy()
	if reelable_enemy:
		reelable_enemy.toggle_reeled_colisions(true)
	else:
		player.set_collision_mask_value(3, true)
		player.hole_ray_cast.enabled = true

	player.hooked_target = null

func process(delta: float):

	var dir = player.hooked_target.position - player.position

	var reelable_enemy := get_reelable_enemy()
	if reelable_enemy:
		player.run(delta)
		player.animate_running()
		reelable_enemy.velocity = reelable_enemy.velocity.lerp(-dir.normalized() * current_reel_speed, delta)
	else:
		player.animate_running()
		player.velocity = player.velocity.lerp(dir.normalized() * current_reel_speed, delta)

	current_reel_speed += acceleration

	if dir.length() < reel_distance or Input.is_action_just_pressed("attack"):
		return IdleState.new(player)

func physics_process(_delta: float):
	pass

func get_reelable_enemy() -> Enemy:
	if player.hooked_target.is_in_group("reelable") and player.hooked_target is Enemy:
		return player.hooked_target as Enemy
	else:
		return null
