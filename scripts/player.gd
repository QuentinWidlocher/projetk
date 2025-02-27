class_name Player
extends CharacterBody2D

@export var speed: float = 200

func _ready():
	pass

func _process(_delta):
	pass

func _physics_process(_delta):
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_up", "move_down")
	velocity = Vector2(x_axis, y_axis) * speed
	print(velocity)
	move_and_slide()
