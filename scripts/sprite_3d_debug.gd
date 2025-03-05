extends Node3D

@onready var sprite: Sprite3D = $Sprite3D

func _process(_delat):
	var center = sprite.get_aabb().get_center()
	DebugDraw2D.cube(Vector2(center.x, center.z), 10, Color.RED, 3.0)
