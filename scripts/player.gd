class_name Player
extends Node2D

@onready var rb: CharacterBody2D = %CharacterBody2D

func _ready():
	pass

func _process(_delta):
	pass

func _physics_process(_delta):
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_up", "move_down")
	# rb.velocity = Vector2(x_axis, y_axis) * 100
	# rb.move_and_slide()
