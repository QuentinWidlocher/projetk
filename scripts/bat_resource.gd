class_name BatResource
extends EnemyResource

@export_group("Vision")
## Distance de sécurité (en case)
@export_range(0.5, 10, 0.5, "suffix: cases") var safe_distance: float = 3

@export_group("Timing")
## Interval entre les attaques (en secondes)
@export_range(0.1, 10, 0.1, "suffix: secondes") var attack_interval: float = 2
## Interval entre les mouvements (en secondes)
@export_range(0.1, 10, 0.1, "suffix: secondes") var move_interval: float = 2
## Temps maximum de déplacement
@export_range(0.1, 10, 0.1, "suffix: secondes") var move_timeout_interval: float = 2
