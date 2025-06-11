extends Node2D

@onready var cursor := $Cursor
@onready var start_button := $Button
@onready var start_loop_button := $Button2
@onready var next_level := $NextLvl

var mouse_down: bool = false
var dragging: bool = false

var selected_block: CodeBlock = null
var previous_block: CodeBlock = null

var selected_pin: Pin = null
var previous_pin: Pin = null

var diff: Vector2

func _ready() -> void:
	GameState.main_display_spawned.emit(self)
	start_button.pressed.connect(_start_pressed)
	var sb := StartBlock.new()
	var eb := EndBlock.new()

	var screen: Vector2 = get_viewport().get_size()
	sb.position = Vector2(0, screen.y/2)
	eb.position = Vector2(screen.x - eb.size.x, screen.y/2)

	add_child(sb)
	add_child(eb)

	start_button.position = Vector2(screen.x - start_loop_button.size.x - start_button.size.x - 20, screen.y - start_button.size.y - 20)
	start_loop_button.position = Vector2(screen.x - start_loop_button.size.x, screen.y - start_loop_button.size.y - 20)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		GameState.next_level()

	if event.is_action_pressed("save"):
		GameState.save_game()

	if event.is_action_pressed("load"):
		GameState.load_game()

	if cursor.gui:
		_deselect_block()

	if event is InputEventMouseMotion:
		var mouse_position := get_global_mouse_position()
		cursor.global_position = mouse_position

	if event.is_action_pressed("left_click"):
		_click()
	elif event is InputEventMouseMotion and mouse_down and not cursor.gui:
		_drag()

	if event.is_action_released("left_click"):
		_unclick()
	
	if event.is_action_pressed("right_click"):
		$SecondaryScreen.visible = true if not $SecondaryScreen.visible else false 

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
		_handle_pin(pin)

	if block:
		_deselect_block()
		_select_block(block)
	else:
		_deselect_block()

func _select_pin(pin: Pin) -> void:
	if previous_pin != selected_pin:
		previous_pin = selected_pin

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

	selected_block = block

	if block != previous_block:
		selected_block.z_index = 1
		# print("INFO: selected %s->z_index - %s" % [selected_block.name, selected_block.z_index])

		if previous_block:
			previous_block.z_index = 0
			# print("INFO: UNselected %s->z_index - %s" % [previous_block.name, previous_block.z_index])

func _deselect_block() -> void:
	if selected_block:
		previous_block = selected_block
		selected_block = null

func _unclick() -> void:
	cursor.gui = false
	mouse_down = false
	_undrag()

func _handle_pin(pin: Pin) -> void:
	if BlockManager.is_pin_rhs(pin):
		var conn := BlockManager.conn_with_rhs_pin(pin)

		# NOTE: 1. rhs pin with no connection, no pin selected -> ignore
		if not selected_pin and not conn:
			# print("1. rhs pin with no connection, no pin selected")
			return

		# NOTE: 2. rhs pin with no connection, pin selected -> connecte the old lhs pin, to the newly selected rhs pin
		elif selected_pin and not conn and BlockManager.can_connect_pins(selected_pin, pin):
			BlockManager.connect_pins(selected_pin, pin)
			_deselect_pin()
			# print("2. rhs pin with no connection, pin selected")

		# NOTE: 3. rhs pin with connection, no pin selected -> remove the connection, attach lhs to cursor
		elif not selected_pin and conn:
			BlockManager.remove_conn(conn)
			_select_pin(conn.lhs_pin)
			# print("3. rhs pin with connection, no pin selected")

		# NOTE: 4. rhs pin with connection, pin selected -> swap connection or remove old connection, attach selected lhs to selected rhs
		elif selected_pin and conn:
			BlockManager.remove_conn(conn)
			BlockManager.connect_pins(selected_pin, pin)
			_deselect_pin()
			# print("4. rhs pin with connection, pin selected")

	if BlockManager.is_pin_lhs(pin):
		var conn := BlockManager.conn_with_lhs_pin(pin)

		# NOTE: 5. lhs pin with no connection, no pin selected -> attach pin to cursor
		if not selected_pin and not conn:
			# print("5. lhs pin with no connection, no pin selected")
			# TODO: if pin.connected() -> disconnect
			_select_pin(pin)

		# NOTE: 6. lhs pin with no connection, pin selected -> disconnect old selected from cursor, attach newly selected pin to cursor
		elif selected_pin and not conn:
			# print("6. lhs pin with no connection, pin selected")
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
			BlockManager.remove_conn(conn)
			_select_pin(pin)
			# print("7. lhs pin with connection, no pin selected")

		# NOTE: 8. lhs pin with connection, pin selected -> disconnect old connection from cursor,attach newly selected pin to cursor
		elif selected_pin and conn:
			BlockManager.remove_conn(conn)
			_hide_curve()
			_deselect_pin()
			_select_pin(pin)
			# print("8. lhs pin with connection, pin selected")

func _start_pressed() -> void:
	GameState.board.global_position = GameState.start.global_position
	GameState.board.rotation_degrees = Vector3(0, 180, 0)
	await get_tree().create_timer(0.5).timeout
	BlockManager.execute()

func _on_button_2_pressed() -> void:
	GameState.board.global_position = GameState.start.global_position
	GameState.board.rotation_degrees = Vector3(0, 180, 0)
	await get_tree().create_timer(0.5).timeout
	if BlockManager.stop == true:
		await BlockManager.execute_loop()
	else:
		BlockManager.stop = true

func _on_next_lvl_button_pressed() -> void:
	GameState.next_level()

		
func get_state() -> Dictionary:
	# print("INFO: saving evaluator_screen state")
	@warning_ignore("untyped_declaration")
	var code_blocks: Array = get_children().filter(func(c): return c is CodeBlock)
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")

	var cb_arr: Array = []
	for cb:CodeBlock in code_blocks:
		# print("INFO: saved %s" % cb.get_state())
		cb_arr.append(cb.get_state())
	
	return {
		code_blocks = cb_arr,
		connections = BlockManager.state()
	}

func hide_blocks() -> void:
	for c in get_children(true):
		if c.has_method("hide"):
			c.hide()

func load_state(block_state: Array, conn_state: Array) -> void:
	@warning_ignore("untyped_declaration")
	var code_blocks: Array = get_children().filter(func(c): return c is CodeBlock)

	for state:Dictionary in block_state:
		if state:
			# print("INFO: loaded state %s" % state)
			var block: CodeBlock = instance_from_id(state.type.object_id).new()
			@warning_ignore("untyped_declaration")
			var cb_idx = code_blocks.find_custom(func(c):return GameState.cb_count_re.search(c.name).get_string() == state.count)
			
			if cb_idx != -1:
				code_blocks[cb_idx].set_state(state)
			else:
				add_child(block)
				block.set_state(state)

	@warning_ignore("untyped_declaration")
	code_blocks = get_children().filter(func(c): return c is CodeBlock)
	BlockManager.set_state(conn_state, code_blocks) 
