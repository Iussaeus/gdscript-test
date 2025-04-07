extends Node2D

@onready var cursor := $Cursor

var mouse_down: bool = false
var dragging: bool = false

var selected_block: CodeBlock = null
var previous_block: CodeBlock = null

var selected_pin: Pin = null
var previous_pin: Pin = null

var diff: Vector2

func _ready() -> void:
	var cb1 := CodeBlock.new()
	var cb2 := CodeBlock.new()
	var cb3 := CodeBlock.new()

	add_child(cb1)
	add_child(cb2)
	add_child(cb3)

	cb1.out_connections = 2
	cb2.in_connections = 2
	cb1.global_position = Vector2(0, 0)
	cb2.global_position = cb1.global_position + Vector2(cb1.size.x * 2, cb1.size.y * 2) / 2 + Vector2(100, 100)
	cb3.global_position = Vector2(800, 600)

	BlockManager.connect_pins(cb1.pins[1], cb2.pins[0])
	# BlockManager.connect_pins(cb1.pins[2], cb2.pins[1])
	# BlockManager.connect_pins(cb2.pins[cb2.pins.size() - 1], cb3.pins[0])

	# await get_tree().create_timer(2).timeout
	# BlockManager.disconnect_blocks(cb2, cb3)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		_click()

	if event.is_action_released("left_click"):
		_unclick()

	if event is InputEventMouseMotion:
		var mouse_position := get_global_mouse_position()
		cursor.global_position = mouse_position

	if event is InputEventMouseMotion and mouse_down:
		_drag()
	else:
		_undrag()

func _drag() -> void:
	dragging = true

	if selected_block:
		selected_block.global_position = get_global_mouse_position() - diff

func _undrag() -> void:
	dragging = false


func _click() -> void:
	mouse_down = true
	var pin:Pin = cursor.current_pin
	var block:CodeBlock = cursor.current_block

	if pin:
	# TODO: ACTUALLY MANAGE THE CONNECTIONS
		if BlockManager.is_pin_rhs(pin):
			var conn := BlockManager.connection_with_rhs_pin(pin)

			# NOTE: 1. rhs pin with no connection, no pin selected -> ignore
			if not selected_pin and not conn:
				print("1. rhs pin with no connection, no pin selected")
				return

			# NOTE: 2. rhs pin with no connection, pin selected -> connecte the old lhs pin, to the newly selected rhs pin
			elif selected_pin and not conn and BlockManager.can_connect_pins(selected_pin, pin):
				BlockManager.connect_pins(selected_pin, pin)
				_deselect_pin()
				print("2. rhs pin with no connection, pin selected")

			# NOTE: 3. rhs pin with connection, no pin selected -> remove the connection, attach lhs to cursor
			elif not selected_pin and conn:
				BlockManager.remove_connection(conn)
				_select_pin(conn.lhs_pin())
				print("3. rhs pin with connection, no pin selected")

			# NOTE: 4. rhs pin with connection, pin selected -> swap connection or remove old connection, attach selected lhs to selected rhs
			elif selected_pin and conn:
				BlockManager.remove_connection(conn)
				BlockManager.connect_pins(selected_pin, pin)
				print("4. rhs pin with connection, pin selected")

		if BlockManager.is_pin_lhs(pin):
			var conn := BlockManager.connection_with_lhs_pin(pin)

			# NOTE: 5. lhs pin with no connection, no pin selected -> attach pin to cursor
			if not selected_pin and not conn:
				print("5. lhs pin with no connection, no pin selected")
				# TODO: if pin.connected() -> disconnect
				_select_pin(pin)

			# NOTE: 6. lhs pin with no connection, pin selected -> disconnect old selected from cursor, attach newly selected pin to cursor
			elif selected_pin and not conn:
				print("6. lhs pin with no connection, pin selected")
				if selected_pin == pin:
					_hide_curve()
					_deselect_pin()
				else:
					_hide_curve()
					_deselect_pin()
					_select_pin(pin)

			# NOTE: 7. lhs pin with connection, no pin selected ->  remove old connection, attach pin to cursor
			# TODO: Multiple connections ?
			elif not selected_pin and conn:
				BlockManager.remove_connection(conn)
				_select_pin(pin)
				print("7. lhs pin with connection, no pin selected")

			# NOTE: 8. lhs pin with connection, pin selected -> disconnect old connection from cursor,attach newly selected pin to cursor
			elif selected_pin and conn:
				BlockManager.remove_connection(conn)
				_hide_curve()
				_deselect_pin()
				_select_pin(pin)
				print("8. lhs pin with connection, pin selected")

	if block:
		_select_block(block)

func _select_pin(pin: Pin) -> void:
	if previous_pin != selected_pin:
		previous_pin = selected_pin

	# cursor.set_collision_value()
	selected_pin = pin
	selected_pin.curve.end_marker = cursor.marker
	selected_pin.curve._visible = true

func _deselect_pin() -> void:
	selected_pin = null

func _hide_curve() -> void:
	selected_pin.curve.end_marker = null
	selected_pin.curve._visible = false

func _select_block(block: CodeBlock) -> void:
	var mouse_position := get_global_mouse_position()
	diff = mouse_position - block.global_position

	if previous_block != selected_block:
		previous_block = selected_block

	selected_block = block

func _deselect_block() -> void:
	selected_block = null

func _unclick() -> void:
	mouse_down = false
	_deselect_block()
