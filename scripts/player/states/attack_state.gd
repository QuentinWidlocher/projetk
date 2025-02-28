class_name AttackState
extends BaseState

var rotation_to_face_right = deg_to_rad(-127)
var done = false
var previous_state: BaseState

func _init(player_: Player) -> void:
	self.player = player_

func on_enter(previous_state_: BaseState):
	self.previous_state = previous_state_
	var aim_angle = player.direction.angle()
	player.swoosh_sprite.rotation = rotation_to_face_right + aim_angle
	player.swoosh_animation_player.animation_finished.connect(self._on_animation_finished)
	player.swoosh_animation_player.play("swoosh")

func on_exit():
	pass

func process(delta: float):
	# previous_state.process(delta)
	if done:
		return IdleState.new(player)

func physics_process(delta: float):
	previous_state.physics_process(delta)

func _on_animation_finished(_old_name: String):
	done = true
