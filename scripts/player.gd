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

	debug("Rotation: %0.2f" % rad_to_deg(velocity.angle()))
	var rot = rad_to_deg(velocity.angle())

	var animation_name = "idle"
	if velocity.length() > acceleration * 10:
		direction = velocity.normalized()
		animation_name = "run"

	if rot < 0 and rot > -90:
		animation_name += "_N"
	elif rot < -90 and rot > -180:
		animation_name += "_W"
	elif rot > 0 and rot < 90:
		animation_name += "_E"
	elif rot > 90 and rot < 180:
		animation_name += "_S"
	else:
		animation_name += "_N"

	animation_player.play(animation_name)

	if hooked_target != null:
		DebugDraw2D.line(position, hooked_target.position, Color.RED, 3.0)

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
