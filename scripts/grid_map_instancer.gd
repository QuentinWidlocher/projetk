extends GridMap

const TILES = [
	preload("res://scenes/BuildingBlocks/block.tscn"),
	preload("res://scenes/BuildingBlocks/floor.tscn"),
	preload("res://scenes/BuildingBlocks/wall_s.tscn"),
	preload("res://scenes/BuildingBlocks/wall_n.tscn"),
	preload("res://scenes/BuildingBlocks/wall_e.tscn"),
	preload("res://scenes/BuildingBlocks/wall_w.tscn"),
]

func _ready():
	# rotation_degrees.y = -45

	for i in range(TILES.size()):
		instanciate_cells_by_id(i, TILES[i])

func instanciate_cells_by_id(id: int, instance: PackedScene):
	for cell in get_used_cells_by_item(id):
		var new_instance: Node3D = instance.instantiate()
		var cell_pos: Vector3 = map_to_local(cell)
		new_instance.position = cell_pos
		set_cell_item(cell, INVALID_CELL_ITEM)
		add_child(new_instance)
