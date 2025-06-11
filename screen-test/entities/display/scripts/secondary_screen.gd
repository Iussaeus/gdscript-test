extends Node2D

var cursor: Area2D

func _ready() -> void:
	await get_parent().ready
	cursor = get_parent().cursor if not has_node("Cursor") else get_node("Cursor")

	GameState.secondary_display_spawned.emit(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and cursor:
		var mouse_position := get_global_mouse_position()
		cursor.global_position = mouse_position

func _on_var_button_pressed() -> void:
	var vb := VarBlock.new()
	GameState.main_display.add_child(vb)
	vb.position = Vector2(200, 200)

func _on_if_button_pressed() -> void:
	var ib := IfBlock.new()
	GameState.main_display.add_child(ib)
	ib.position = Vector2(200, 200)

func _on_arithmetic_button_pressed() -> void:
	var ab := ArithmeticBlock.new()
	GameState.main_display.add_child(ab)
	ab.position = Vector2(200, 200)

func _on_get_var_button_pressed() -> void:
	var b := GetVarBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_set_var_button_pressed() -> void:
	var b := SetVarBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_negation_button_pressed() -> void:
	var b := NotBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_condition_button_pressed() -> void:
	var b := ConditionBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_direction_button_pressed() -> void:
	var b := DirectionBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_rotate_button_pressed() -> void:
	var b := RotateBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_move_button_pressed() -> void:
	var b := MoveBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)
	
func _on_jump_button_pressed() -> void:
	var b := JumpBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_bumper_button_pressed() -> void:
	var b := BumperCollidingBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_laser_button_pressed() -> void:
	var b := DistanceToLaserTargetBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_laser_colliding_button_pressed() -> void:
	var b := IsLaserCollidingBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)

func _on_delete_button_pressed() -> void:
	if is_instance_valid(GameState.main_display.previous_block):
		BlockManager.delete_block(GameState.main_display.previous_block)


func _on_print_button_pressed() -> void:
	var b := PrintBlock.new()
	GameState.main_display.add_child(b)
	b.position = Vector2(200, 200)
