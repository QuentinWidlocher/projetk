class_name SlimeResource
extends EnemyResource

@export var iterations: int = 2

@export_group("Jump")
## Hauteur max de saut
@export var max_jump_height: float = 200

@export_group("Vision")
## Distance où le slime attaque
@export_range(0.5, 10, 0.5, "suffix: cases") var target_distance: float = 3

@export_group("Timing")
## Interval entre les attaques (en secondes)
@export_range(0.1, 10, 0.1, "suffix: secondes") var attack_interval: float = 2
## Temps maximum de déplacement
@export_range(0.1, 10, 0.1, "suffix: secondes") var move_timeout_interval: float = 2
