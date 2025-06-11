@tool
class_name EndBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	draw_name = false
	in_connections = 1
	out_connections = 0
	size = Vector2(size.x / 4, size.y)
	in_pin_names[0] = "end"
	set_block_name("EndBlock")

func _check_signature(_params: Array=[]) -> bool:
	return true

func _logic(_params: Array=[]) -> Variant:
	print("INFO: Ended - %s\n" % name)
	return null

func get_state() -> Dictionary:
	return {
		type = EndBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
