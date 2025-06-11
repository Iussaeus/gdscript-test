class_name Helpers extends Node


static func forward_vector(node: Node3D) -> Vector3:
	return -node.transform.basis.z

static func back_vector(node: Node3D) -> Vector3:
	return node.transform.basis.z

static func left_vector(node: Node3D) -> Vector3:
	return -node.transform.basis.x

static func right_vector(node: Node3D) -> Vector3:
	return node.transform.basis.x

### No real type safety, be sure the func takes one float and returns one
static func map_vector3(v: Vector3, fun: Callable) -> Vector3:
	if fun.get_argument_count() != 1:
		push_error("function should take only one argument")
		return Vector3()
	match typeof(fun.call(0)):
		TYPE_FLOAT:
			var x: float = fun.call(v.x)
			var y: float = fun.call(v.y)
			var z: float = fun.call(v.z)
			return Vector3(x, y, z)
		_:
			return Vector3()


### No real type safety, be sure the func takes one int and returns one
static func map_vector3i(v: Vector3i, fun: Callable) -> Vector3i:
	if fun.get_argument_count() != 1:
		push_error("function should take only one argument")
		return Vector3i()
	match typeof(fun.call(0)):
		TYPE_INT:
			var x: int = fun.call(v.x)
			var y: int = fun.call(v.y)
			var z: int = fun.call(v.z)
			return Vector3i(x, y, z)
		_:
			return Vector3i()


static func initialze_array(a: Array, v: Variant) -> void:
	if a.is_typed():
		var array_type := a.get_typed_builtin()
		var v_typed: Variant = type_convert(v, array_type)

		for i: int in a.size():
			a[i] = v_typed
	else:
		for i: int in a.size():
			a[i] = v


static func print_array(a: Array) -> void:
	var print_str := String()
	for i: int in a.size():
		print_str += str(a[i]) + " "

	print(print_str)


static func print_dict(d: Dictionary) -> void:
	var print_str := String()
	for i: Variant in d.keys():
		if d[i] == d.values()[d.values().size() - 1]:
			print_str += "%s: %s " % [i, d[i]]
		else:
			print_str += "%s: %s, " % [i, d[i]]

	print(print_str)
