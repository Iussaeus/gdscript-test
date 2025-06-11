@tool
class_name PrintBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 2
	out_connections = 1
	size = Vector2(size.x * 0.5, size.y)
	set_pin_names(["string"])

	set_block_name("PrintBlock")

func _check_signature(_params: Array=[]) -> bool:
	# print("INFO: _check_signature called from %s with params %s" % [name, params])
	return true

func _logic(params: Array=[]) -> Variant:
	await get_tree().create_timer(0.1).timeout
	if params == []:
		print("INFO: Executing %s _logic - nothing to print" % name)
		return null

	print("INFO: Executing %s _logic, printing - %s" % [name, params])

	return null

func get_state() -> Dictionary:
	return {
		type = PrintBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
