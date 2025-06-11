@tool	
class_name GetVarBlock extends CodeBlock

var options: OptionButton
var selected_var: VarBlock

var items: Dictionary[String, VarBlock]

var _op_area: Area2D

func _ready() -> void:
	super._ready()
	in_connections = 0
	out_connections = 1
	out_pin_names[0] = "value"
	size = Vector2(size.x * 0.8, size.y * 1.6)
	set_block_name("GetVarBlock")

	var op := OptionButton.new()
	options = op
	add_child(op)

	op.size = Vector2(128, 32)

	op.position = Vector2(8, size.y - (size.y * 0.65))

	op.item_selected.connect(_item_selected)
	GameState.added_var.connect(_add_button_items)

	op.select(-1)

	var op_area := Area2D.new()
	var rect := RectangleShape2D.new()
	var collision := CollisionShape2D.new()

	rect.size = op.size
	collision.shape = rect
	op_area.add_child(collision)
	op_area.position = Vector2(op.position.x + op.size.x / 2, op.position.y + op.size.y / 2)
	op_area.name = "op_area"

	_add_button_items()
	_op_area = op_area
	add_child(op_area)

func _update_positions() -> void:
	options.position = Vector2(8, size.y - (size.y * 0.65))
	_op_area.position = Vector2(options.position.x + options.size.x / 2, options.position.y + options.size.y / 2)

func _add_button_items() -> void:
	options.clear()
	for key: String in GameState.vars.keys():
		options.add_item(key)

	if not selected_var:
		options.select(-1)

func _item_selected(idx: int) -> void:
	selected_var = GameState.vars[options.get_item_text(idx)]
	print("INFO: %s selected_var - %s - value - %s type - %s" % 
		[name ,selected_var, selected_var.var_value, type_string(selected_var.type_id)])

func _check_signature(_params: Variant=null) -> bool:
	# print("INFO: _check_signature called from %s with paams %s" % [name, params])
	return true

func _logic(_params: Array=[]) -> Variant:
	print("INFO: %s returning - %s" % [name, selected_var.var_value])
	await get_tree().create_timer(0.1).timeout
	if selected_var:
		return selected_var.var_value
	return null

func _set_size(value:Vector2) -> void:
	super._set_size(value)
	if options:
		_update_positions()

func get_state() -> Dictionary:
	return {
		type = GetVarBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
		selected_var_state = selected_var.state() if selected_var else {}
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
	if state.selected_var_state:
		if not GameState.vars.has(state.selected_var_state.name_field_text):
			while true:
				await GameState.added_var
				for i in options.item_count:
					if options.get_item_text(i) == state.selected_var_state.name_field_text:
						options.select(i)
						_item_selected(i)
						break
		else:
			for i in options.item_count:
				if options.get_item_text(i) == state.selected_var_state.name_field_text:
					options.select(i)
					_item_selected(i)
