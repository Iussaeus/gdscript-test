class_name Branch extends IBranch

var funcs: Array[FuncPair] = []

func _ready() -> void:
	name = "Branch"

func _execute() -> void:
	var result: Array = []
	for fp in funcs:
		result = await fp._execute()	
		done.emit()

func _to_string() -> String:
	var res := ""
	if funcs:
		for fp in funcs: 
			res = res + fp.to_string()
			if funcs.size() > 1:	
				res = res + " "

	return "Branch: " +  res

func add_func(func_: FuncPair) -> void:
	funcs.append(func_)
