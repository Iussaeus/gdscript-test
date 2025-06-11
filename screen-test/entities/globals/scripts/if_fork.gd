class_name IfFork extends IBranch

var condition: FuncPair
var then_branch: Branch
var else_branch: Branch

func _ready() -> void:
	name = "IfFork"

func _execute() -> void:
	var cond := await condition._execute()
	# var _check: Variant = _check_signature([cond])
	# if _check != null:
	print("INFO: condition returned - %s" % cond)
	if cond and cond[0]:
		print("INFO: executing then branch")
		await then_branch._execute()
	else:
		print("INFO: executing else branch")
		await else_branch._execute()

func _check_signature(params: Array=[]) -> Variant:
	if params == []:
		print("INFO: _check_signature called from %s with not - params %s" % [name, params])
		return false

	if typeof(params[0]) != TYPE_BOOL:
		print("INFO: Type mismatch in %s _logic expecting bool got %s" % [name, type_string(typeof(params[0]))])
		return null

	print("INFO: _check_signature called from %s with params %s" % [name, params])

	return true

func _to_string() -> String:
	var cond_str := ""
	if condition:
		cond_str = condition.callable.get_object().to_string()

	var then_ := ""
	if then_branch:
		then_ = "then: "
		for fp in then_branch.funcs: 
			then_ = then_ + fp.to_string()
			if then_branch.funcs.size() > 0:	
				then_ = then_ + " "

	var else_ := ""
	if else_branch:
		else_ = "else: "
		for fp in else_branch.funcs: 
			else_ = else_ + fp.to_string()
			if else_branch.funcs.size() > 0:	
				else_ = else_ + " "

	return "IfFork: " + cond_str + then_ + else_
