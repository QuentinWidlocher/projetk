class_name FallingInHoleState
extends BaseState

var z_index_before_fall: int = 0
var collision_layer_before_fall: int = 0
var collision_mask_before_fall: int = 0
var position_before_fall: Vector2
var direction_before_fall: Vector2

var done: bool = false
var damage: int = 10

func on_enter(_previous_state: BaseState):
	position_before_fall = player.global_position
	direction_before_fall = player.direction

	player.get_tree().create_timer(1).timeout.connect(self._on_fall_finished)
	collision_layer_before_fall = player.collision_layer
	collision_mask_before_fall = player.collision_mask
	z_index_before_fall = player.z_index

	player.collision_layer = 0
	player.collision_mask = 0
	player.velocity.y /= 2
	player.z_index = -1
	player.y_sort_enabled = true

func on_exit():
	player.velocity = Vector2.ZERO
	player.global_position = position_before_fall - direction_before_fall * 200

	player.collision_layer = collision_layer_before_fall
	player.collision_mask = collision_mask_before_fall
	player.z_index = z_index_before_fall
	player.y_sort_enabled = false

	player.health -= damage
	player.hit_animation_player.play("invincible")
	player.invincibility_timer.start()

func process(_delta: float):
	if done:
		return IdleState.new(player)

func physics_process(delta: float):
	player.velocity = player.velocity.lerp(Vector2.DOWN * 4000, delta)

func _on_fall_finished():
	done = true
