class_name Slime
extends Enemy

const SlimeScene: PackedScene = preload("res://scenes/slime.tscn")

@export var resource: SlimeResource = preload("res://resources/enemies/default_slime.tres")
@export var jump_curve: Curve

@onready var target_area: Area2D = $TargetArea2D
@onready var target_shape: CollisionPolygon2D = $TargetArea2D/CollisionPolygon2D
@onready var damage_area: Area2D = $DamageArea2D
@onready var attack_timer: Timer = $AttackTimer

var iteration_left: int = 0

var jump_force: float = 50
var max_jump_height: float = 50

var in_range: bool = false
var base_height: float = 0
var jump_direction: Vector2 = Vector2.ZERO

func _ready():
	load_resource()
	base_height = sprite.position.y
	health = max_health

func _process(delta: float) -> void:
	super(delta)

	var now_in_range = false
	for body in target_area.get_overlapping_bodies():
		if body is Player:
			now_in_range = true

	debug_label.write("Target in range: %s" % now_in_range)
	debug_label.write("Attack timeout: %0.1f" % attack_timer.time_left)

	match current_state:
		State.IDLE:
			damage_area.monitorable = false
			sprite.position.y = base_height
			velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)
			in_range = now_in_range
			if player != null:
				current_state = State.MOVE

		State.MOVE:
			damage_area.monitorable = false

			if player == null:
				current_state = State.IDLE
			else:
				var direction = (player.position - position).normalized()

				if now_in_range:

					if attack_timer.is_stopped():
						# slime is now too close
						current_state = State.ATTACK
						velocity = direction * jump_force
						attack_timer.start()
					else:
						velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)
				else:
					velocity = velocity.lerp(direction * max_speed, delta * acceleration)

				in_range = now_in_range

		State.ATTACK:
			var height_factor = jump_curve.sample((velocity.length() / jump_force) * -1 + 1)
			sprite.position.y = base_height - height_factor * max_jump_height

			# Only damage when jumping
			damage_area.monitorable = height_factor > 0

			velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)

			if player == null or attack_timer.is_stopped():
				current_state = State.IDLE

		State.DYING:
			velocity = velocity.lerp(Vector2.ZERO, delta * decceleration)
			damage_area.monitorable = true
			animation_player.play("dying")

		State.FALLING:
			velocity = velocity.lerp(Vector2.DOWN * 4000, delta)

	move_and_slide()

func _on_attack_timer_timeout() -> void:
	attack_timer.stop()

func load_resource() -> void:
	_load_resource(resource as EnemyResource)
	target_shape.scale = Vector2(resource.target_distance, resource.target_distance)

	max_jump_height = resource.max_jump_height
	jump_force = resource.target_distance * 750

	attack_timer.wait_time = resource.attack_interval
	iteration_left = resource.iterations

func _on_damage_area_2d_area_entered(area:Area2D) -> void:
	var collided = area

	if not (collided is Player or collided is Enemy) or not collided.has_method("on_hit"):
		collided = area.get_parent()

	if (collided is Player or collided is Enemy) and collided.has_method("on_hit"):
		collided.on_hit(damage, global_position, knockback)

func _spawn_smaller_slime() -> void:
	if iteration_left <= 0:
		return

	for _i in range(2):
		var slime: Slime = SlimeScene.instantiate()
		get_parent().add_child(slime)
		slime.resource = resource
		slime.resource.max_health = resource.max_health / 2
		slime.resource.damage = resource.damage / 2

		# we need to compensate for the smaller size
		slime.resource.vision_distance = resource.vision_distance * 2
		# slime.resource.target_distance = resource.target_distance * 2

		slime.load_resource()
		slime.position = position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		slime.scale = scale / 2
		slime.iteration_left = iteration_left - 1
