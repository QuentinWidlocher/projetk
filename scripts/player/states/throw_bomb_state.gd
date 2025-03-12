class_name ThrowBombState
extends BaseState

var area: Area2D
var direction: Vector2 = Vector2.ZERO
var speed: float = 1500.0
var max_time: float = 1.5
var current_time: float = 0.0
var touched := false
var damage := 10
var knockback := 1000

func on_enter(_previous_state: BaseState):
	player.play_animation("idle")
	area = player.target.get_node("Area2D")

	area.body_entered.connect(self._on_body_shape_entered)

	player.target.visible = true
	player.target_line.visible = true
	player.target_bomb_radius_area.visible = true
	direction = player.direction
	current_time = 0.0

func on_exit():
	player.target.visible = false
	player.target_line.visible = false
	player.target_bomb_radius_area.visible = false
	player.target.position = Vector2.ZERO

func process(delta: float):
	if touched:
		explode()
		return IdleState.new(player)

	if current_time >= max_time:
		return IdleState.new(player)

	if Input.is_action_just_pressed("attack"):
		return IdleState.new(player)

	if Input.is_action_just_pressed("bomb"):
		explode()
		return IdleState.new(player)

	player.target.position += direction * speed * delta
	current_time += delta

func physics_process(delta: float):
	player.decelerate(delta)

func _on_body_shape_entered(body: Node2D):
	if body is TileMapLayer:
		touched = true

func explode():
	print("Exploding bomb")
	for body in player.target_bomb_radius_area.get_overlapping_bodies():
		if body is TileMapLayer:
			var tilemap: TileMapLayer = body as TileMapLayer
			var target_coords: Vector2i = tilemap.local_to_map(player.target.global_position)

			# We need to check cells one by one because area2D.get_overlapping_bodies() only returns the layer and not the specific cell.
			for cell in tilemap.get_used_cells():
				if int((target_coords - cell).length()) <= player.target_bomb_radius_area.scale.x:
					var tile_data := tilemap.get_cell_tile_data(cell)
					if tile_data != null and tile_data.get_custom_data("Bombable"):
						# TODO: Explosion animation + sound
						tilemap.set_cell(cell, -1)

		elif body is Enemy:
			(body as Enemy).on_hit(damage, player.target.global_position, knockback)
