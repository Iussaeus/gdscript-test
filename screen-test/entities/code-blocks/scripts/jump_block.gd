@tool
class_name JumpBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	set_block_name("JumpBlock")

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

func _logic(_params: Array=[]) -> Variant:
	await GameState.board.jump()
	return null

func get_state() -> Dictionary:
	return {
		type = JumpBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
