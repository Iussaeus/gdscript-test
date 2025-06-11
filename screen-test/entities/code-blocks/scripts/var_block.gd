@tool
class_name VarBlock extends CodeBlock

var options: OptionButton
var value_field: LineEdit
var name_field: LineEdit

var var_value: Variant
var type_id: int

var _op_area: Area2D

func _ready() -> void:
	super._ready()
	in_connections = 0
	out_connections = 0
	set_block_name("VarBlock")

	var op := OptionButton.new()
	var tf := LineEdit.new()
	var nf := LineEdit.new()

	add_child(op)
	add_child(tf)
	add_child(nf)

	options = op
	value_field = tf
	name_field = nf

	size = Vector2(128, (32 * 3) + 12 + 32)

	op.size = Vector2(96, 32)
	tf.size = Vector2(96, 32)
	nf.size = Vector2(96, 32)

	nf.position = Vector2((size.x / 2 - nf.size.x / 2), size.y - (size.y * 0.80))
	op.position = Vector2((size.x / 2 - op.size.x / 2), size.y - (size.y * 0.45) - (op.size.y / 2))
	tf.position = Vector2((size.x / 2 - tf.size.x / 2), size.y - (size.y * 0.1 ) - tf.size.y) 

	tf.placeholder_text = "data"
	nf.placeholder_text = "name"
	_add_button_items(op)

	op.item_selected.connect(_item_selected)
	tf.text_changed.connect(_text_changed)
	nf.text_changed.connect(_name_changed)

	op.select(0)

	var op_area := Area2D.new()
	var rect := RectangleShape2D.new()
	var collision := CollisionShape2D.new()

	rect.size = op.size
	collision.shape = rect
	op_area.add_child(collision)
	op_area.position = Vector2(op.position.x + op.size.x / 2, size.y - (size.y * 0.45))
	op_area.name = "op_area"

	_op_area = op_area
	add_child(op_area)

func _update_positions() -> void:
	name_field.position = Vector2((size.x / 2 - name_field.size.x / 2), size.y - (size.y * 0.80))
	options.position = Vector2((size.x / 2 - options.size.x / 2), size.y - (size.y * 0.45) - (options.size.y / 2))
	value_field.position = Vector2((size.x / 2 - value_field.size.x / 2), size.y - (size.y * 0.1 ) - value_field.size.y) 

func _add_button_items(button: OptionButton) -> void:
	var items := ["int", "bool", "float", "String","Vector2"]

	for i: String in items:
		button.add_item(i)

	button.select(0)
	type_id = TYPE_INT
	var_value = 0
	value_field.text = "0" 

func _name_changed(new_name: String) -> void:
	GameState.add_var(new_name, self)
	GameState.added_var.emit()

# TODO: per type specific input line edit, like Vector2 should have two fields,
# one for x, one for y
# int and float should have a base value, like 0, and the user should be able to insert only numbers
# bool should be a binary choice
# etc.
func _item_selected(idx: int) -> void:
	match options.get_item_text(idx):
		"int": 
			type_id = TYPE_INT
			var_value = 0
			value_field.text = "0" 
		"bool": 
			type_id = TYPE_BOOL
			var_value = false
			value_field.text = "false" 
		"float": 
			type_id = TYPE_FLOAT
			var_value = 0.0
			value_field.text = "0.0" 
		"Vector2": 
			type_id = TYPE_VECTOR2
			var_value = Vector2(0, 0)
			value_field.text = "0, 0" 
		"String": 
			type_id = TYPE_STRING 
			var_value = ""
			value_field.text = "" 
		"nil": 
			type_id = TYPE_NIL
			var_value = null
			value_field.text = "nil" 

	print("INFO: VarBlock selected type_id %d - %s" % [type_id, type_string(type_id)])
	
func select_type(tp: String) -> void:
	match tp:
		"int": 
			type_id = TYPE_INT
			var_value = 0
			value_field.text = "0" 
		"bool": 
			type_id = TYPE_BOOL
			var_value = false
			value_field.text = "false" 
		"float": 
			type_id = TYPE_FLOAT
			var_value = 0.0
			value_field.text = "0.0" 
		"Vector2": 
			type_id = TYPE_VECTOR2
			var_value = Vector2(0, 0)
			value_field.text = "0, 0" 
		"String": 
			type_id = TYPE_STRING 
			var_value = ""
			value_field.text = "" 
		"nil": 
			type_id = TYPE_NIL
			var_value = null
			value_field.text = "nil" 
		_:
			print("INFO: RIP BOZO from %s" % name)

# TODO: check if the input is valid for the selected type_id
func _text_changed(new_text: String) -> void:
	var result: Variant
	var error: bool
	match type_id:
		TYPE_INT: 
			if new_text.is_valid_int():
				result = new_text.to_int()
			else:
				error = true
		TYPE_BOOL:
			if new_text == "true":
				result = true
			elif new_text =="false":
				result = false
			else:
				error = true
		TYPE_FLOAT: 
			if new_text.is_valid_int():
				result = new_text.to_int()
				error = true
			else:
				error = true
		TYPE_VECTOR2: 
			var split := new_text.split(",")
			if split.size() > 1:
				var x := split[0].to_float()
				var y := split[1].to_float()
				result = Vector2(x, y)
			else:
				error = true
		TYPE_STRING: 
			if new_text != null:
				result = new_text
			else:
				error = true
		TYPE_NIL: 
			result = null
			
	# if error:
		# var_value = null
		# return
	var_value = result

func _check_signature(_params: Variant=null) -> bool:
	return true

func _logic(_params: Array=[]) -> Variant:
	return null

func _set_size(value:Vector2) -> void:
	super._set_size(value)
	if options and name_field and value_field:
		_update_positions()
		
func get_state() -> Dictionary:
	return {
		type = VarBlock,
		count = GameState.cb_count_re.search(name).get_string(),
		position = var_to_str(position),
		var_value = var_to_str(var_value),
		name_field_text = name_field.text,
		type_string = options.get_item_text(options.get_selected_id()),
	}

func set_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
	name_field.text = state.name_field_text
	select_type(state.type_string)
	value_field.text = state.var_value	

	GameState.add_var(state.name_field_text, self)
	GameState.added_var.emit()
