@tool
class_name ConditionBlock extends CodeBlock

var options: OptionButton

var operation: String 
var _op_area: Area2D

func _ready() -> void:
	super._ready()
	in_connections = 2
	out_connections = 1
	set_pin_names(["rhs"])
	in_pin_names[0] = "lhs"
	out_pin_names[0] = "result"

	set_block_name("ConditionBlock")

	var op := OptionButton.new()
	op.size = Vector2(96, 31)
	op.position = Vector2((size.x / 2 - op.size.x / 2), size.y - (size.y * 0.5) - (op.size.y / 2))
	op.item_selected.connect(_item_selected)
	_add_button_items(op)

	options = op
	add_child(op)

	var op_area := Area2D.new()
	var rect := RectangleShape2D.new()
	var collision := CollisionShape2D.new()

	rect.size = op.size
	collision.shape = rect
	op_area.add_child(collision)
	op_area.position = Vector2(op.position.x + op.size.x / 2, op.position.y + op.size.y / 2)
	op_area.name = "op_area"

	_op_area = op_area
	add_child(op_area)

func _update_positions() -> void:
	options.position = Vector2((size.x / 2 - options.size.x / 2), size.y - (size.y * 0.95))
	_op_area.position = Vector2(options.position.x + options.size.x / 2, options.position.y + options.size.y / 2)

func _add_button_items(button: OptionButton) -> void:
	var items := [">", "<", ">=", "<=", "==", "!=", "and", "or"]

	for i: String in items:
		button.add_item(i)
	
	button.select(0)
	operation = ">"
	
func select_operation(op: String) -> void:
	match op:
		">":
			options.select(0)
			operation =">"
		"<":
			options.select(1)
			operation ="<"
		">=":
			options.select(2)
			operation =">="
		"<=":
			options.select(3)
			operation ="<="
		"==":
			options.select(4)
			operation ="=="
		"!=":
			options.select(5)
			operation ="!="
		"and":
			options.select(6)
			operation = "and"
		"or":
			options.select(7)
			operation = "or"
		_ :
			print("INFO: RIP BOZO from %s" % name)

func _item_selected(idx: int) -> void:
	operation = options.get_item_text(idx)
	print("INFO: ConditionBlock selected operation - %s" % operation)

func _check_signature(params: Array=[]) -> bool:
	print("INFO: _check_signature called from %s with params %s" % [name, params])
	return true

func _logic(params: Array=[]) -> Variant:
	var result: bool
	if params == [] or params.size() < 1:
		return result

	if typeof(params[0]) != typeof(params[1]):
		print("INFO: Type mismatch in %s _logic %s %s %s - returning - %s" % [name, params[0], operation, params[1], result])
		return result
		
	match operation:
		">": result = params[0] > params[1]
		">=": result = params[0] >= params[1]
		"<=": result = params[0] <= params[1]
		"==": result = params[0] == params[1]
		"!=": result = params[0] != params[1]
		"and": result = params[0] and params[1]
		"or": result = params[0] or params[1]

	print("INFO: Executing %s _logic %s %s %s - returning - %s" % [name, params[0], operation, params[1], result])
	return result

func get_state() -> Dictionary:
	return {
		type = ConditionBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
		operation = options.get_item_text(options.get_selected_id()),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
	select_operation(state.operation)
