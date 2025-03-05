class_name Player3DVersion
extends CharacterBody3D

@export var max_speed: float = 5
@export var acceleration: float = 1
@export var decceleration: float = 3

@onready var debug_label: Label3D = %DebugLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var DIRECTIONS: Dictionary = {
	"N": Vector2.RIGHT.rotated(deg_to_rad(-25)), # WHY NOT 45 WTF
	"NE": Vector2.RIGHT,
	"W": Vector2.LEFT.rotated(deg_to_rad(25)),
	"NW": Vector2.UP,
	"SW": Vector2.LEFT,
	"S": Vector2.LEFT.rotated(deg_to_rad(-25)),
	"SE": Vector2.DOWN,
	"E": Vector2.RIGHT.rotated(deg_to_rad(25)),
}

var STAIRS_DIRECTIONS: Dictionary = {
	"N": Vector2.RIGHT.rotated(deg_to_rad(-47)), # WHY NOT 45 WTF
	"NE": Vector2.RIGHT,
	"W": Vector2.LEFT.rotated(deg_to_rad(25)),
	"NW": Vector2.UP,
	"SW": Vector2.LEFT,
	"S": Vector2.LEFT.rotated(deg_to_rad(-25)),
	"SE": Vector2.DOWN,
	"E": Vector2.RIGHT.rotated(deg_to_rad(25)),
}

var OFFSETS: Dictionary = {
	"N": DIRECTIONS["S"] * 145,
	"NE": DIRECTIONS["SW"] * 256,
	"W": DIRECTIONS["E"] * 145,
	"NW": DIRECTIONS["SE"] * 256,
	"SW": DIRECTIONS["NE"] * 256,
	"S": DIRECTIONS["N"] * 145,
	"SE": DIRECTIONS["NW"] * 256,
	"E": DIRECTIONS["W"] * 145,
}

var current_state: BaseState = IdleState.new(self)

var direction: Vector3 = Vector3.ZERO

var debug_lines: Array = []

func _ready():
	current_state.on_enter(null)
	pass

func _process(delta):

	debug("State: %s" % current_state.get_script().get_global_name().replace("State", ""))

	var next_state = current_state.process(delta)
	if next_state != null and next_state != current_state:
		var old_state = current_state
		old_state.on_exit()
		current_state = next_state
		next_state.on_enter(old_state)

	var rot = rad_to_deg(Vector2(velocity.x, velocity.z).angle())
	debug("Rotation: %0.2f" % rot)

	var speed = Vector2(velocity.x, velocity.z).length()
	debug("Speed: %0.2f" % speed)

	var animation_name = "idle"
	if speed > 0.1:
		direction = velocity.normalized()
		animation_name = "run"

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

	debug_label.text = "\n".join(debug_lines)
	debug_lines.clear()

func _physics_process(delta):
	current_state.physics_process(delta)

	# gravity
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	move_and_slide()


func get_move_axis() -> Vector3:
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_up", "move_down")
	return Vector3(x_axis, 0, y_axis)

func debug(value: Variant):
	debug_lines.push_back(str(value))
