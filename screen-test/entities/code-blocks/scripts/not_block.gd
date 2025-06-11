@tool
class_name NotBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 1
	out_connections = 1
	in_pin_names[0] = "value" 
	out_pin_names[0] = "result"

	set_block_name("NotBlock")

func _check_signature(params: Array=[]) -> bool:
	if params == []:
		print("INFO: _check_signature called from %s with params %s" % [name, params])
		return true
	else:
		print("INFO: _check_signature called from %s with params %s" % [name, params])

	if typeof(params[0]) != TYPE_BOOL:
		print("INFO: Type mismatch in %s _logic expecting bool got %s" % [name, type_string(typeof(params[0]))])
		return false

	return true

func _logic(params: Array=[]) -> Variant:
	var result: bool
	if params and params.size():
		result  = not params[0]

	print("INFO: Executing %s _logic with params - %s, returning - %s" % [name, params, result])

	return result

func get_state() -> Dictionary:
	return {
		type = NotBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
