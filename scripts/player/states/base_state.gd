class_name BaseState

var player: Player3DVersion

func _init(player_: Player3DVersion) -> void:
	self.player = player_

func on_enter(_previous_state: BaseState):
	pass

func on_exit():
	pass

func process(_delta: float):
	pass

func physics_process(_delta: float):
	pass
