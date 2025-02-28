class_name FishingRodState
extends BaseState

var area: Area2D
var direction: Vector2 = Vector2.ZERO
var speed: float = 1000.0
var max_time: float = 1.5
var current_time: float = 0.0
var catched: Node2D = null

func on_enter(_previous_state: BaseState):
	area = player.target.get_node("Area2D")

	area.body_entered.connect(self._on_body_entered)

	player.target.visible = true
	direction = player.direction
	current_time = 0.0

func on_exit():
	player.target.visible = false
	player.target.position = Vector2.ZERO

func process(delta: float):
	if catched != null:
		# TODO: catched state
		return IdleState.new(player)

	if current_time >= max_time:
		return IdleState.new(player)

	player.target.position += direction * speed * delta
	current_time += delta

func physics_process(delta: float):
	# Decelerate
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)

func _on_body_entered(body: Node2D):
	catched = body
