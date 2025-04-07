extends Node

var connections: Array[Connection]

# TODO: multiple connections per lhs_pin one per rhs_pin
func connect_pins(lhs: Pin, rhs: Pin) -> void:
	if lhs == rhs or not lhs.curve:
		return

	var a: CodeBlock = lhs.get_parent()
	var b: CodeBlock = rhs.get_parent()

	if a == b:
		return

	var idx_a := a.pin_idx(lhs)
	var idx_b := b.pin_idx(rhs)

	if idx_a == -1 or idx_b == -1:
		return 

	var connection := Connection.new(a, b, idx_a, idx_b)
	connections.append(connection)

	lhs.curve.end_marker = rhs
	lhs.curve._visible = true
	print("INFO: connected: %s to %s" % [lhs, rhs])

func disconnect_blocks(lhs: Pin, rhs: Pin) -> void:
	if lhs == rhs or not is_pin_connected(lhs) or not is_pin_connected(rhs):
		return

	var a: CodeBlock = lhs.get_parent()
	var b: CodeBlock = rhs.get_parent()

	var idx_a := a.pin_idx(lhs)
	var idx_b := b.pin_idx(rhs)

	var wanted_conn := Connection.new(a, b, idx_a, idx_b)

	var lambda := func(c:Connection) -> bool: 
			return (c.lhs == wanted_conn.lhs and 
			c.rhs == wanted_conn.rhs and 
			c.lhs_pin_idx == wanted_conn.lhs_pin_idx and
			c.rhs_pin_idx == wanted_conn.rhs_pin_idx)

	var wanted_idx := connections.find_custom(lambda)
	if wanted_idx == -1:
		return

	connections.remove_at(wanted_idx)

	lhs.curve.end_marker = null
	lhs.curve._visible =  false 

func remove_connection(conn: Connection) -> void:
	connections.erase(conn)

	conn.lhs.pins[conn.lhs_pin_idx].curve.end_marker = null
	conn.lhs.pins[conn.lhs_pin_idx].curve._visible = false 
	return

# NOTE: may have edge cases
func can_connect_pins(lhs_pin: Pin, rhs_pin: Pin) -> bool:
	if lhs_pin == rhs_pin:
		return false

	var lhs_conn := connection_with_lhs_pin(lhs_pin)
	if lhs_conn == null:
		return true 
	if lhs_conn.lhs.out_connections < 1:
		return false

	var rhs_conn := connection_with_rhs_pin(rhs_pin)
	if rhs_conn == null:
		return true 
	if rhs_conn.lhs.in_connections < 1:
		return false

	return true

func are_blocks_connected(lhs: CodeBlock, rhs: CodeBlock) -> bool:
	if lhs == rhs:
		return false

	for conn in connections:
		if conn.lhs == lhs and conn.rhs == rhs:
			return true

	return false

func connection_with_lhs_pin(pin: Pin) -> Connection:
	for conn in connections:
		if conn.lhs.pins[conn.lhs_pin_idx] == pin:
			return conn
	return null

func connection_with_rhs_pin(pin: Pin) -> Connection:
	for conn in connections:
		if conn.rhs.pins[conn.rhs_pin_idx] == pin:
			return conn

	return null

func is_pin_connected(pin: Pin) -> bool:
	for conn in connections:
		if conn.rhs.pins[conn.rhs_pin_idx] == pin or conn.lhs.pins[conn.lhs_pin_idx] == pin:
			return true

	return false

func is_pin_lhs(pin: Pin) -> bool:
	return pin.curve != null

func is_pin_rhs(pin: Pin) -> bool:
	return pin.curve == null

func make_callables() -> Array[Callable]:
	return []

func execute() -> void:
	var callables: Array[Callable]= make_callables()
	var result:Array
	for c in callables:
		var new_result:Array = c.call(result)
		result = new_result
