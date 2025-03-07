class_name HitState
extends BaseState

var done = false
var damage = 0.0
var source_position = Vector2.ZERO
var knockback_force = 0.0
var knockback_time = 0.3

func _init(player_: Player, damage_: float, source_position_: Vector2, knockback_force_: float) -> void:
	player = player_
	damage = damage_
	source_position = source_position_
	knockback_force = knockback_force_
	knockback_time = knockback_force / 10 * 2

func on_enter(_previous_state: BaseState):
	player.get_tree().create_timer(knockback_time).timeout.connect(self._on_knockback_finished)
	var direction := (player.global_position - source_position).normalized()
	player.direction = -direction
	player.play_animation("hit")
	player.hit_animation_player.play("hit")
	player.health -= damage
	player.velocity = direction * knockback_force * 1000

	if player.health <= 0:
		player.get_tree().quit()

func process(delta: float):
	if done:
		return IdleState.new(player)

	player.decelerate(delta)

func _on_knockback_finished():
	done = true
