class_name FuncPair extends RefCounted

var group: Array
var callable: Callable

enum {
	RIGHT,
	LEFT
}

func _init(conn: Connection=null, g: Array=[], side: int = FuncPair.LEFT) -> void:
	if conn:
		if g:
			group = g

		if side == FuncPair.LEFT:
			callable = BlockManager._make_callable(conn)
		else:
			callable = BlockManager._make_callable_rhs(conn)

func _execute(params: Array=[]) -> Array:
	# if we have a group execute them in order put the results in an array pass the array callable return callable result
	print("INFO: executing FuncPair with callable - %s and group_size - %s, items - %s" % [callable, group.size(), group])
	if group:
		var result: Variant = []
		for c: Callable in group:
			var res := await c.call()
			if res != null:
				result.append(res)
		print("INFO: awaiting %s with params: %s" % [callable, result])
		var new_result = await callable.call(result)
		print("INFO: returning from FuncPair - %s" % new_result)
		if new_result != null:
			return [new_result]
		return []

	# if no lhs or group execute the callable with no params
	var res := await callable.call(params)

	if res != null:
		return [res]

	return []

func _to_string() -> String:
	var g_str := ""
	if group:
		g_str = "group: "
		for c in group:
			g_str = g_str + c.get_object().name 
			if group.size() > 0:
				g_str = g_str + " "


	var call_str := ""
	if callable:
		call_str = "" + callable.get_object().name

	return g_str + "c: " + call_str
