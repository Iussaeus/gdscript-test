class_name Connection extends Node

var lhs: CodeBlock
var rhs: CodeBlock

var lhs_pin_idx: int
var rhs_pin_idx: int

func _init(lhs_: CodeBlock, rhs_: CodeBlock, lhs_pin_idx_: int, rhs_pin_idx_: int) -> void:
	lhs = lhs_
	rhs = rhs_
	lhs_pin_idx = lhs_pin_idx_
	rhs_pin_idx = rhs_pin_idx_

func lhs_pin() -> Pin:
	return lhs.pins[lhs_pin_idx]

func rhs_pin() -> Pin:
	return rhs.pins[rhs_pin_idx]
