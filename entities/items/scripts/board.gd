@tool
class_name Board extends XRToolsPickable

enum {
	THRUSTER,
	BUMPER,
	LASER
}

var snap_zones: Array[XRToolsSnapZone]
@onready var snap_zone_one: XRToolsSnapZone = $SnapZone

func _ready() -> void:
	GameState.board_spawned.emit(self) 
	for c in get_children():
		if c is XRToolsSnapZone:
			snap_zones.append(c)

	picked_up.connect(_on_picked_up)
	pointer_event.connect(_on_pointer_event)

func _process(_delta: float) -> void:
	for sz in snap_zones:
		# print("Info: snappble - %s" % sz.picked_up_object)
		if sz.picked_up_object:
			# Assuming 'self' is a Node with a position
			# var vector_to_origin := sz.global_position.direction_to(global_position).normalized()
			# var normalized_vector := Vector3(vector_to_origin.x, 0 ,vector_to_origin.z)
			# var inverted_vector := -normalized_vector
			#
			# # Set the rotation of the picked up object
			# sz.picked_up_object.look_at(sz.picked_up_object.position + inverted_vector)
			sz.set_collision_mask_value(1, false)

func move(direction: Vector3) -> void:
	var dir_local: Vector3
	match direction:
		Vector3.FORWARD: dir_local = Helpers.forward_vector(self)
		Vector3.BACK: dir_local = Helpers.back_vector(self)
		Vector3.LEFT: dir_local = Helpers.left_vector(self)
		Vector3.RIGHT: dir_local = Helpers.right_vector(self)

	var target_position: Vector3 = global_position + (Vector3.ONE * dir_local.normalized() * 0.5)

	var duration := 1
	var elapsed_time := 0.0

	var fps := 30
	var delay := duration / fps
	
	while elapsed_time <= duration:
		elapsed_time += get_process_delta_time()
		var t := elapsed_time / duration
		var new_position := global_position.lerp(target_position, t)

		if is_colliding():
			global_position -= new_position
			break

		global_position = new_position
		# print("INFO: elapsed - %s, t - %s, delay - %s new_pos - %s, gl_pos - %s" % [elapsed_time, t, delay, new_position, global_position])

		if new_position == target_position:
			break
		
		await get_tree().create_timer(delay).timeout

func rotate_(direction: Vector3) -> void:
	var target_rotation := 0.0
	match direction:
		Vector3.RIGHT: target_rotation = 90.0
		Vector3.LEFT: target_rotation = -90.0
		_ : return

	var duration := 1
	var fps := 30.0

	var delay := duration / fps
	var elapsed_time := 0.0

	var rotated := 0.0

	while elapsed_time <= duration:
		elapsed_time += get_process_delta_time()

		var current_rotation := target_rotation / fps
		rotate_y(deg_to_rad(current_rotation))

		rotated += current_rotation

		# print("INFO: elapsed - %s, t - %s, current_rotation - %s(%s)" % [elapsed_time, t, current_rotation, rotated])

		if (direction == Vector3.LEFT and rotated == target_rotation) or \
		   (direction == Vector3.RIGHT and rotated == target_rotation):	
			break
		await get_tree().create_timer(delay).timeout

func jump() -> void:
	if not can_jump():
		return
	var force := 10
	apply_central_impulse(Vector3(0, 10,0) + Helpers.forward_vector(self) * force)
	await get_tree().create_timer(1).timeout

func is_colliding() -> bool:
	for b in get_colliding_bodies():
		if b is StaticBody3D and not b.get_collision_layer() != 1:
			return true
	
	return false

func can_jump() -> bool:
	for sz in snap_zones:
		if sz.picked_up_object is Thruster:
			return true
	
	return false

@warning_ignore("untyped_declaration")
func _on_picked_up(_pickable) -> void:
	for sz in snap_zones:
		# print("Info: snappble - %s" % sz.picked_up_object)
		if sz.picked_up_object:
			var vector_to_origin := Vector3(0, 0, 0) - self.global_position
			var normalized_vector := vector_to_origin.normalized()
			var inverted_vector := -normalized_vector

			sz.picked_up_object.look_at(sz.picked_up_object.position + inverted_vector)
			sz.drop_object()

func get_state() -> Dictionary:
	var picked_up_objects: Array = []
	var idx := 0

	for sz in snap_zones:
		if sz.picked_up_object is Thruster:
			picked_up_objects.append({idx = idx, item = THRUSTER})
		if sz.picked_up_object is Laser:
			picked_up_objects.append({idx = idx, item = LASER})
		if sz.picked_up_object is Bumper:
			picked_up_objects.append({idx = idx, item = BUMPER})

		idx += 1

	return {
		position = var_to_str(position),
		picked_up_objects = picked_up_objects
	}

func load_state(state: Dictionary) -> void:
	# print("INFO: loading %s" % state)
	position = str_to_var(state.position)
	for obj: Dictionary in state.picked_up_objects:
		if obj.item == THRUSTER:
				snap_zones[obj.idx].pick_up_object(GameState.thruster)
		if obj.item == LASER:
				snap_zones[obj.idx].pick_up_object(GameState.laser)
		if obj.item == BUMPER:
				snap_zones[obj.idx].pick_up_object(GameState.bumper)
