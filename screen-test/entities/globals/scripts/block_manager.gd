extends Node

var connections: Array[Connection]
var visited: Array = []
var stop: bool = false

enum BranchType {
	NORMAl,
	THEN,
	ELSE,
}

func connect_pins(lhs: Pin, rhs: Pin) -> void:
	if lhs == rhs or not lhs.curve:
		return

	var a: CodeBlock = lhs.get_parent()
	var b: CodeBlock = rhs.get_parent()

	if a == b:
		return

	var idx_a := a.out_pin_idx(lhs)
	var idx_b := b.in_pin_idx(rhs)

	if idx_a == -1 or idx_b == -1:
		return 

	var connection := Connection.new(a, b, idx_a, idx_b)
	connections.append(connection)

	lhs.curve.end_marker = rhs
	lhs.curve._visible = true
	print("INFO: connected: %s" % connection)

func remove_conn(conn: Connection) -> void:
	connections.erase(conn)

	conn.lhs.out_pins[conn.lhs_pin_idx].curve.end_marker = null
	conn.lhs.out_pins[conn.lhs_pin_idx].curve._visible = false 
	print("INFO: removed conn: %s" % conn)

func are_pins_eq(a:Connection, b: Connection) -> bool: 
	return (a.lhs == b.lhs and 
					a.rhs == b.rhs and 
					a.lhs_pin_idx == b.lhs_pin_idx and
					a.rhs_pin_idx == b.rhs_pin_idx)

# NOTE: may have edge cases
func can_connect_pins(lhs_pin: Pin, rhs_pin: Pin) -> bool:
	if lhs_pin == rhs_pin:
		return false

	var lhs_conn := conn_with_lhs_pin(lhs_pin)
	if lhs_conn == null:
		return true 
	if lhs_conn.lhs.out_connections < 1:
		return false

	var rhs_conn := conn_with_rhs_pin(rhs_pin)
	if rhs_conn == null:
		return true 
	if rhs_conn.lhs.in_connections < 1:
		return false

	return true

func conn_with_lhs_pin(pin: Pin) -> Connection:
	for conn in connections:
		if conn.lhs.out_pins[conn.lhs_pin_idx] == pin:
			return conn
	return null

func conn_with_rhs_pin(pin: Pin) -> Connection:
	for conn in connections:
		if conn.rhs.in_pins[conn.rhs_pin_idx] == pin:
			return conn

	return null

func is_pin_connected(pin: Pin) -> bool:
	for conn in connections:
		if pin in conn.rhs.in_pins or pin in conn.lhs.out_pins:
			return true

	return false

func is_pin_lhs(pin: Pin) -> bool:
	return pin.curve != null

func is_pin_rhs(pin: Pin) -> bool:
	return pin.curve == null

func conn_with_lhs_block(lhs: CodeBlock, idx: int) -> Connection:
	for c in connections:
		if c.lhs == lhs and c.lhs_pin_idx == idx:
			return c

	return null

func conn_with_rhs_block(rhs: CodeBlock, idx: int) -> Connection:
	for c in connections:
		if c.rhs == rhs and c.rhs_pin_idx == idx:
			return c

	return null

func delete_block(block: CodeBlock) -> void:
	if block is StartBlock or block is EndBlock:
		return

	@warning_ignore("untyped_declaration")
	var conns := connections.filter(func(c): return c.lhs == block or c.rhs == block)

	@warning_ignore("untyped_declaration")
	for c in conns:
		remove_conn(c)
	
	block.queue_free()

func execute() -> void:
	var branches := _make_branches()

	print("INFO: executing %s branches" % branches.size())

	for b in branches:
		print("INFO: %s" % b)

	for b in branches:
		await b._execute()

func execute_loop() -> void:
	BlockManager.stop = false
	var branches := _make_branches()

	print("INFO: executing %s branches" % branches.size())

	for b in branches:
		print("INFO: %s" % b)

	while not stop:
		for b in branches:
			await b._execute()

func _make_branches() -> Array[IBranch]:
	@warning_ignore_start("untyped_declaration")
	var start_idx := connections.find_custom(func(c): return c.lhs is StartBlock)
	var end_idx := connections.find_custom(func(c): return c.rhs is EndBlock)

	if start_idx == -1:
		print_rich("[color=red]ERROR: StartBlock not connected")
	if end_idx == -1:
		print_rich("[color=red]ERROR: EndBlock not connected")

	if start_idx == -1 or end_idx == -1:
		return []

	var result: Array[IBranch] = []
	var start_conn := connections[start_idx]

	visited = []
	_traverse_conn_rec(start_conn, result)

	@warning_ignore_restore("untyped_declaration")
	return result

func _traverse_conn_rec(current: Connection, branches: Array[IBranch],
	type: BranchType = BranchType.NORMAl, depth: int = 0) -> Array:
	if not current or current in visited:
		return branches
	visited.append(current)

	if current.lhs is StartBlock: 
		branches.append(Branch.new())
		branches[0].add_func(FuncPair.new(current))
		print("INFO: %sstart %s, %s" % ["\t".repeat(depth), current, branches[0]])
	elif current.rhs is EndBlock:
		if current.lhs is not IfBlock:
			var fp := FuncPair.new(current, _make_args(current.lhs))
			branches[branches.size() - 1].add_func(fp)
		var end := FuncPair.new(current, [], FuncPair.RIGHT)
		branches[branches.size() - 1].add_func(end)
		print("INFO: %send %s, %s" % ["\t".repeat(depth), current, branches[branches.size() - 1]])

	elif current.lhs_pin_idx == 1:
		print("INFO: %sthen %s" % ["\t".repeat(depth), current])
		# TODO: test this Scheisse
		var end := FuncPair.new(current, _make_args(current.rhs), FuncPair.RIGHT)
		branches[depth].then_branch.add_func(end)

	elif current.lhs_pin_idx == 2:
		print("INFO: %selse %s" % ["\t".repeat(depth), current])
		var end := FuncPair.new(current, _make_args(current.rhs), FuncPair.RIGHT)
		branches[depth].else_branch.add_func(end)

	elif current.rhs_pin_idx == 0 and current.lhs_pin_idx != 0:
		var end := FuncPair.new(current, _make_args(current.rhs), FuncPair.RIGHT)
		branches[depth+2].add_func(end)
		print("INFO: %sif %s, %s" % ["\t".repeat(depth), current, type])

	elif current.lhs_pin_idx == 0 and current.rhs_pin_idx == 0:
		if branches[depth] is Branch:
			var fp := FuncPair.new(current, _make_args(current.lhs))
			branches[depth].add_func(fp)

		if branches[depth] is IfFork and type == BranchType.THEN:
			var fp := FuncPair.new(current, _make_args(current.rhs), FuncPair.RIGHT)
			branches[depth].then_branch.add_func(fp)

		if branches[depth] is IfFork and type == BranchType.ELSE:
			var fp := FuncPair.new(current, _make_args(current.rhs), FuncPair.RIGHT)
			branches[depth].else_branch.add_func(fp)

		print("INFO: %sconn %s, %s, %s" % ["\t".repeat(depth), current, branches[depth], type])

	if current.rhs is IfBlock:
		var fork := IfFork.new()
		@warning_ignore("inference_on_variant")
		var condition := _make_condition(current.rhs)
		@warning_ignore("inference_on_variant")
		var cond_args := _make_args(conn_with_rhs_pin(current.rhs.in_pins[1]).lhs)
		var fp := FuncPair.new(current)
		fp.group.append_array(cond_args)
		fp.callable = condition
		if condition:
			fork.condition = fp
		fork.then_branch = Branch.new()
		fork.else_branch = Branch.new()
		branches.append(fork)
		_traverse_conn_rec(_then_conn(current.rhs), branches, BranchType.THEN, depth + 1)
		_traverse_conn_rec(_else_conn(current.rhs), branches, BranchType.ELSE, depth + 1)
		branches.append(Branch.new())

	# NOTE: this line may do damage in the future
	if current.lhs is IfBlock and current.rhs is EndBlock:
		depth += 1

	_traverse_conn_rec(_next_conn_c(current), branches, type, depth)

	return branches

func _make_callable(conn: Connection) -> Callable:
	return Callable.create(conn.lhs, conn.lhs._execute.get_method())

# TODO: traverse all the blocks connencted to "block" in reverse order, and add their funcs
func _make_args(block: CodeBlock) -> Variant:
	print("INFO: making args for %s" % block)
	if block.in_pins.size() >= 2:
		@warning_ignore("untyped_declaration")
		var conns: Array[Connection] = connections.filter(func(c): return c.rhs == block and c.rhs.in_pin_names[c.rhs_pin_idx] != "entry")
		# var conns: Array[Connection] = connections.filter(func(c): return c.rhs == block)
		print("INFO: all conns")
		for c in connections:
			print("INFO: %s in_pin_names[0] - %s" % [c,c.rhs.in_pin_names[c.rhs_pin_idx]])
		conns.reverse()
		print("INFO: got %s conns: %s" % [conns.size(), conns])
		var funcs: Array = []
		for conn in conns:
			funcs.append(_make_callable(conn))

		if funcs:
			return funcs

	return []

func _make_condition(block: CodeBlock) -> Variant:
	var conn: Connection
	if block.in_pins.size() > 1:
		conn = conn_with_rhs_pin(block.in_pins[1])

	if conn:
		return Callable.create(conn.lhs, conn.lhs._execute.get_method())
	return null

func _make_callable_rhs(conn: Connection) -> Callable:
	return Callable.create(conn.rhs, conn.rhs._execute.get_method())

func _then_conn(if_block: IfBlock) -> Connection:
	return conn_with_lhs_block(if_block, 1)

func _else_conn(if_block: IfBlock) -> Connection:
	return conn_with_lhs_block(if_block, 2)

func _next_conn_c(conn: Connection) -> Connection:
	var cb := conn.rhs
	for c in connections:
		if c.lhs == cb and c.lhs_pin_idx == 0:
			return c

	return null

func _next_conn_b(cb: CodeBlock) -> Connection:
	for c in connections:
		if c.lhs == cb and c.lhs_pin_idx == 0:
			return c

	return null

# save the connections, but how ?
func state() -> Array:
	var arr: Array[Dictionary] = [] 
	for c in connections: 
		arr.append(c.state())
	return arr

func set_state(state_arr: Array, cb_arr: Array) -> void:
	for state in state_arr:
		var from_idx: int = cb_arr.find_custom(func(c):return GameState.cb_count_re.search(c.name).get_string() == state.from_count)
		var from: CodeBlock = cb_arr[from_idx]
		var from_pin_idx: int = str_to_var(state.from_pin_idx)
		var to_idx: int = cb_arr.find_custom(func(c):return GameState.cb_count_re.search(c.name).get_string() == state.to_count)
		var to: CodeBlock = cb_arr[to_idx]
		var to_pin_idx: int = str_to_var(state.to_pin_idx)
		print("INFO: connecting %s.op%s to %s.ip%s" % [from, from_pin_idx, to, to_pin_idx])
		connect_pins(from.out_pins[from_pin_idx], to.in_pins[to_pin_idx])
