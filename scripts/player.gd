class_name Player
extends CharacterBody2D

@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10
@export var max_health: float = 50

@onready var debug_label: DebugLabel = %DebugLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hit_animation_player: AnimationPlayer = %HitAnimationPlayer
@onready var swoosh: Node2D = $Swoosh
@onready var swoosh_sprite: Sprite2D = $Swoosh/Sprite
@onready var swoosh_animation_player: AnimationPlayer = $Swoosh/AnimationPlayer
@onready var target: Node2D = $Target
@onready var target_shape: CollisionShape2D = $Target/Area2D/CollisionShape2D
@onready var target_line: BezierLine2D = $BezierLine2D
@onready var target_bomb_radius_area: Area2D = $Target/BombRadiusArea
@onready var aim_arrow: Node2D = %AimArrow/Pivot
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var hole_ray_cast: RayCast2D = $HoleRayCast2D

signal hp_changed(new_hp: float)

var hooked_target: Node2D:
	get:
		return hooked_target
	set(new_target):
		hooked_target = new_target
		target_line.visible = hooked_target != null

var current_state: BaseState = IdleState.new(self)
var direction: Vector2 = Vector2.ZERO
var health: float:
	get:
		return health
	set(new_health):
		health = new_health
		emit_signal("hp_changed", health)

func _ready():
	health = max_health
	current_state.on_enter(null)
	pass

func _process(delta):
	if hole_ray_cast.is_colliding() and current_state is not FallingInHoleState :
		switch_state(FallingInHoleState.new(self))
		return

	debug_label.write("State: %s" % current_state.get_script().get_global_name().replace("State", ""))
	debug_label.write("HP: %0.2f/%0.2f" % [health, max_health])
	debug_label.write("Hooked: %s" % (str(hooked_target.name) if hooked_target else "None"))

	var next_state = await current_state.process(delta)
	if next_state != null and next_state != current_state:
		switch_state(next_state)

	# var rot = rad_to_deg(velocity.angle())
	var move_axis: Vector2 = get_move_axis()

	debug_label.write("Rotation: %0.2f" % rad_to_deg(move_axis.angle()))

	if velocity.length() > 0 and move_axis.length() > 0:
		direction = move_axis.normalized()

	var first_point = Vector2(0, -150)
	var second_point = Vector2(0, -200)

	if hooked_target != null:
		second_point = hooked_target.position - position
	elif target != null:
		second_point = target.global_position - global_position

	var mid_point = (first_point - second_point) / 1.3
	if target_line.visible:
		target_line.curve.set_point_position(0, first_point)
		target_line.curve.set_point_position(1, second_point)
		target_line.curve.set_point_in(1, Vector2(mid_point.x, mid_point.y - 400))
		target_line.queue_redraw()

func _physics_process(delta):
	current_state.physics_process(delta)
	move_and_slide()

func get_move_axis():
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_up", "move_down")
	return Vector2(x_axis, y_axis)

func on_hit(damage: float, source_position: Vector2, knockback_force: float):
	if invincibility_timer.is_stopped():
		switch_state(HitState.new(self, damage, source_position, knockback_force))

func play_animation(animation_name: String):
	var rot: float = rad_to_deg(direction.angle())

	if rot < -157.5 and rot > -180:
		animation_name += "_SW"
	elif rot < -112.5 and rot > -157.5:
		animation_name += "_W"
	elif rot < -67.5 and rot > -112.5:
		animation_name += "_NW"
	elif rot < -22.5 and rot > -67.5:
		animation_name += "_N"
	elif rot > -22.5 and rot < 22.5:
		animation_name += "_NE"
	elif rot > 22.5 and rot < 67.5:
		animation_name += "_E"
	elif rot > 67.5 and rot < 112.5:
		animation_name += "_SE"
	elif rot > 112.5 and rot < 157.5:
		animation_name += "_S"
	elif rot > 157.5 and rot < 180:
		animation_name += "_SW"
	else:
		animation_name += "_N"

	animation_player.play(animation_name)

func decelerate(delta: float):
	velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)

func run(delta: float):
	var move_axis = get_move_axis()

	if move_axis.length() > 0:
		velocity = velocity.lerp(move_axis * max_speed, delta * acceleration)
	else:
		decelerate(delta)

func animate_running():
	if velocity.length() > acceleration * 10:
		play_animation("run")
	else:
		play_animation("idle")

func switch_state(new_state: BaseState):
	print(current_state.get_script().get_global_name().replace("State", ""), "->", new_state.get_script().get_global_name().replace("State", ""))
	var old_state = current_state
	old_state.on_exit()
	current_state = new_state
	new_state.on_enter(old_state)

func _on_invincibility_timer_timeout() -> void:
	hit_animation_player.stop()
	invincibility_timer.stop()
