extends Marker3D

func _ready() -> void:
	GameState.start_spawned.emit(self)
