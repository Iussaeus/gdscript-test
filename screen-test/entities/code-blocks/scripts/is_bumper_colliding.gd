@tool
class_name BumperCollidingBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 0
	out_connections = 1
	out_pin_names[0] = "value"
	set_block_name("IsBumperCollidingBlock")

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
	@warning_ignore("redundant_await")
	var result := await GameState.bumper.is_colliding()
	print("INFO: %s _logic called returning- %s" % [name, result])
	return result

func get_state() -> Dictionary:
	return {
		type = BumperCollidingBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
