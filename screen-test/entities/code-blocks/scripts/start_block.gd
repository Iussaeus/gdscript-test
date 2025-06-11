@tool
class_name StartBlock extends CodeBlock

func _ready() -> void:
	super._ready()
	in_connections = 0
	out_connections = 1
	draw_name = false
	size = Vector2(size.x / 4, size.y)
	out_pin_names[0] = "start"
	set_block_name("StartBlock")

func _check_signature(_params: Variant=null) -> bool:
	return true

func _logic(_params: Array=[]) -> Variant:
	print("\nINFO: Started - %s" % name)
	return null

func get_state() -> Dictionary:
	return {
		type = StartBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
