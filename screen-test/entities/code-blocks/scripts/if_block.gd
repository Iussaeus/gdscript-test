@tool
class_name IfBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 2
	out_connections = 3
	size = Vector2(size.x * 0.60, size.y * 0.9)
	set_pin_names(["condition"], ["then", "else"])

	set_block_name("IfBlock")

func _check_signature(params: Array=[]) -> bool:
	if params == []:
		# print("INFO: _check_signature called from %s with params %s" % [name, params])
		return true
	# else:
		# print("INFO: _check_signature called from %s with params %s" % [name, params])

	if typeof(params[0]) != TYPE_BOOL:
		# print("INFO: Type mismatch in %s _logic expecting bool got %s" % [name, type_string(typeof(params[0]))])
		return false

	return true

func _logic(_params: Array=[]) -> Variant:
	return null

func get_state() -> Dictionary:
	return {
		type = IfBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
