@tool
class_name DirectionBlock extends CodeBlock

var options: OptionButton
var selected: Vector3

func _ready() -> void:
	super._ready()
	in_connections = 0
	out_connections = 1
	out_pin_names[0] = "value"
	size = Vector2(size.x * 0.8, size.y * 1.6)
	set_block_name("DirectionBlock")

	var op := OptionButton.new()
	options = op
	add_child(op)

	_add_button_items()

	op.size = Vector2(128, 32)
	op.position = Vector2(8, size.y - (size.y * 0.65))

	op.item_selected.connect(_item_selected)
	op.select(-1)

func _update_positions() -> void:
	options.position = Vector2(8, size.y - (size.y * 0.65))

func _add_button_items() -> void:
	options.clear()
	var items: Array = ["Forward", "Backward", "Left", "Right"]
	for i:String in items:
		options.add_item(i)

	if not selected:
		options.select(-1)

func _item_selected(idx: int) -> void:
	match options.get_item_text(idx):
		"Forward": selected = Vector3.FORWARD
		"Backward": selected = Vector3.BACK
		"Left": selected = Vector3.LEFT
		"Right": selected = Vector3.RIGHT

	print("INFO: %s selected_dir - %s" % [name ,selected])

func select_operation(op: String) -> void:
	match op:
		"Forward":
			options.select(0)
			selected = Vector3.FORWARD
		"Backward":
			options.select(1)
			selected = Vector3.BACK
		"Left":
			options.select(2)
			selected = Vector3.LEFT
		"Right":
			options.select(3)
			selected = Vector3.RIGHT
		_:
			print("INFO: RIP BOZO from %s" % name)

func _check_signature(_params: Variant=null) -> bool:
	# print("INFO: _check_signature called from %s with params %s" % [name, params])
	return true

func _logic(_params: Array=[]) -> Variant:
	# print("INFO: %s returning - %s" % [name, selected_var.var_value])
	if selected:
		return selected
	return null

func _set_size(value:Vector2) -> void:
	super._set_size(value)
	if options:
		_update_positions()

func get_state() -> Dictionary:
	return {
		type = DirectionBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
		operation = options.get_item_text(options.get_selected_id()),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
	select_operation(state.operation)
