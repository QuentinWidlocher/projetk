class_name ThrowFishingRodState
extends BaseState

var area: Area2D
var direction: Vector2 = Vector2.ZERO
var speed: float = 1000.0
var max_time: float = 1.5
var current_time: float = 0.0
var hooked: Node2D = null
var touched := false

func on_enter(_previous_state: BaseState):
	area = player.target.get_node("Area2D")

	area.body_shape_entered.connect(self._on_body_shape_entered)

	player.target.visible = true
	player.target_line.visible = true
	direction = player.direction
	current_time = 0.0

	player.hooked_target = null

func on_exit():
	player.target.visible = false
	player.target.position = Vector2.ZERO

func process(delta: float):
	if hooked != null:
		player.hooked_target = hooked
		return IdleState.new(player)

	if touched:
		return IdleState.new(player)

	if current_time >= max_time:
		player.target_line.visible = false
		return IdleState.new(player)

	player.target.position += direction * speed * delta
	current_time += delta

	if Input.is_action_just_pressed("fishing_rod"):
		return IdleState.new(player)


func physics_process(delta: float):
	# Decelerate
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * player.decceleration)

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int):
	if body is TileMapLayer:
		touched = true

		var tilemap: TileMapLayer = body as TileMapLayer
		var coords := tilemap.get_coords_for_body_rid(body_rid)
		var tile_data := tilemap.get_cell_tile_data(coords)
		if tile_data.get_custom_data("FishingRodTarget"):
			var pos := tilemap.map_to_local(coords)
			var node_at_pos := Node2D.new()
			node_at_pos.position = pos
			hooked = node_at_pos
