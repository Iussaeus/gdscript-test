@tool
class_name Thruster extends Snapable

func _ready() -> void:
	GameState.thruster_spawned.emit(self)

func get_state() -> Dictionary:
	return {
		position = var_to_str(position),
	}

func load_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
