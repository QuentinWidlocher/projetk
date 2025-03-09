class_name PlayerUI
extends CanvasLayer

@export var player: Player

@onready var health_bar: ProgressBar = %HealthBar

func _on_player_hp_changed(new_hp:float) -> void:
	print("Health changed to ", new_hp)
	health_bar.value = new_hp
	health_bar.max_value = player.max_health
