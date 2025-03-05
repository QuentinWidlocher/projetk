class_name Player
extends CharacterBody2D

@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10

@onready var debug_label: Label = %DebugLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var swoosh: Node2D = $Swoosh
@onready var swoosh_sprite: Sprite2D = $Swoosh/Sprite
@onready var swoosh_animation_player: AnimationPlayer = $Swoosh/AnimationPlayer
@onready var target: Node2D = $Target
@onready var target_line: Line2D = $Line2D
@onready var hooked_target: Node2D

var current_state: BaseState = IdleState.new(self)

var direction: Vector2 = Vector2.ZERO

var debug_lines: Array = []

func _ready():
	current_state.on_enter(null)
	pass

func _process(delta):
	debug("State: %s" % current_state.get_script().get_global_name().replace("State", ""))
	debug("Hooked: %s" % hooked_target.name if hooked_target else "None")
	var next_state = current_state.process(delta)
	if next_state != null and next_state != current_state:
		var old_state = current_state
		old_state.on_exit()
		current_state = next_state
		next_state.on_enter(old_state)


	# var rot = rad_to_deg(velocity.angle())
	var move_axis: Vector2 = get_move_axis()

	debug("Rotation: %0.2f" % rad_to_deg(move_axis.angle()))

	if velocity.length() > 0 and move_axis.length() > 0:
		direction = move_axis.normalized()

	var animation_name = "idle"
	if velocity.length() > acceleration * 10:
		animation_name = "run"

	var rot: float = rad_to_deg(direction.angle())

	# 8 directions

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

	if hooked_target != null:
		target_line.set_point_position(1, hooked_target.position - position)
	else:
		target_line.set_point_position(1, target.position)

	debug_label.text = "\n".join(debug_lines)
	debug_lines.clear()

func _physics_process(delta):
	current_state.physics_process(delta)
	move_and_slide()

func get_move_axis():
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_up", "move_down")
	return Vector2(x_axis, y_axis)

func debug(value: Variant):
	debug_lines.push_back(str(value))
