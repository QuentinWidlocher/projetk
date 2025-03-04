class_name Player
extends CharacterBody2D

@export var max_speed: float = 800
@export var acceleration: float = 10
@export var decceleration: float = 10

@onready var debug_label: Label = %DebugLabel
@onready var floor_area: Area2D = $FloorArea2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var swoosh: Node2D = $Swoosh
@onready var swoosh_sprite: Sprite2D = $Swoosh/Sprite
@onready var swoosh_animation_player: AnimationPlayer = $Swoosh/AnimationPlayer
@onready var target: Node2D = $Target
@onready var hooked_target: Node2D
@onready var raycast: RayCast2D = $RayCast2D

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

var direction: Vector2 = Vector2.ZERO
var z_position: float = 0.0

var debug_lines: Array = []

func _ready():
	current_state.on_enter(null)
	pass

func _process(delta):
	if raycast.is_colliding():
		print(raycast.get_collider().name)
	position.y += z_position * 310
	z_index = lerp(z_position, z_position * 10, delta)
	debug("Z: %0.1f" % z_position)
	for body in floor_area.get_overlapping_bodies():
		if body is TileMapLayer:
			var tilemap: TileMapLayer = body as TileMapLayer
			var coords := tilemap.local_to_map(position)
			var tile_data := tilemap.get_cell_tile_data(coords)
			if tile_data != null:
				if tile_data.has_custom_data("Height"):
					var height: float = tile_data.get_custom_data("Height")
					z_position = height
				if tile_data.has_custom_data("Stairs"):
					var stairs_direction: String = tile_data.get_custom_data("Stairs")

					if not STAIRS_DIRECTIONS.has(stairs_direction):
						continue

					var dir: Vector2 = STAIRS_DIRECTIONS[stairs_direction] * 380

					var stairs_pos: Vector2 = tilemap.map_to_local(coords) + OFFSETS[stairs_direction]
					DebugDraw2D.arrow(stairs_pos, stairs_pos + dir, Color.RED, 3)
					var x_delta := stairs_pos.x - position.x

					var z_delta = lerp(0, 1, x_delta)
					debug(x_delta)

	position.y -= z_position * 310
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

# func _on_floor_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
# 	if body is TileMapLayer:
# 		var tilemap: TileMapLayer = body as TileMapLayer
# 		var coords := tilemap.get_coords_for_body_rid(body_rid)
# 		var tile_data := tilemap.get_cell_tile_data(coords)
# 		if tile_data.has_custom_data("Stairs"):
# 			var stairs_vector: Vector2 = tile_data.get_custom_data("Stairs")
# 			var stairs_pos := tilemap.map_to_local(coords)
# 			var x_delta := stairs_pos.x - position.x
# 			var y_delta := stairs_pos.y - position.y

# 			var z_delta = lerp(0, 1, x_delta)
# 			print(z_delta)
