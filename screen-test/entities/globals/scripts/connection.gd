class_name Connection extends RefCounted

var lhs: CodeBlock
var rhs: CodeBlock

var lhs_pin_idx: int = -1
var rhs_pin_idx: int = -1

var rhs_pin: Pin: 
	get: 
		if rhs_pin_idx == -1:
			return null
		else:
			return rhs.in_pins[rhs_pin_idx]

var lhs_pin: Pin: 
	get:
		if lhs_pin_idx == -1:
			return null
		else:
			return lhs.out_pins[lhs_pin_idx]

func _init(lhs_: CodeBlock, rhs_: CodeBlock, lhs_pin_idx_: int, rhs_pin_idx_: int) -> void:
	lhs = lhs_
	rhs = rhs_
	lhs_pin_idx = lhs_pin_idx_
	rhs_pin_idx = rhs_pin_idx_

func _to_string() -> String:
	return "%s->%s" % [lhs.name, rhs.name]

func state() -> Dictionary:
	return {
		from_count = GameState.cb_count_re.search(lhs.name).get_string(),
		from_pin_idx = var_to_str(lhs_pin_idx),
		to_count = GameState.cb_count_re.search(rhs.name).get_string(),
		to_pin_idx = var_to_str(rhs_pin_idx),
	}
