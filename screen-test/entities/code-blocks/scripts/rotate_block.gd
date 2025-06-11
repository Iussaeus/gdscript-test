@tool
class_name RotateBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 2
	set_block_name("RotateBlock")
	set_pin_names(["direction"])

func _check_signature(params: Array=[]) -> bool:
	if params and params.size() > 0 :
		# TODO: move to CodeBlock class
		if typeof(params[0]) != TYPE_VECTOR3:
			print("INFO: %s _check_signature type mismatch got - %s expected - Vector3" % [name, type_string(typeof(params[0]))])
			return false

		print("INFO: %s _check_signature called with params - %s" % [name, params])
		return true
	else:
		print("INFO: %s _check_signature called with no params" % name)
	return true 

func _logic(params: Array=[]) -> Variant:
	if params and params.size() > 0:
		await GameState.board.rotate_(params[0])
	else:
		await GameState.board.rotate_(Vector3.LEFT)
	return null

func get_state() -> Dictionary:
	return {
		type = RotateBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
