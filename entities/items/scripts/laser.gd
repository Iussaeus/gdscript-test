@tool
class_name Laser extends Snapable

## Current target node
var target: Node3D = null

@export var distance: float = 5

## Last target node
var last_target: Node3D = null
var last_collided_at: Vector3

var collide_len: float

var laser_material: StandardMaterial3D = null
var laser_hit_material: StandardMaterial3D = null


func _ready() -> void:
	GameState.laser_spawned.emit(self)
	_update_pointer()


func _update_pointer() -> void:
	if enabled and last_target:
		_visible_hit(last_collided_at)
	else:
		_visible_miss()


# Called on each frame to update the pickup
func _process(_delta: float) -> void:
	# Do not process if in the editor
	if Engine.is_editor_hint() or !is_inside_tree():
		return

	# Find the new pointer target
	var new_target: Node3D
	var new_at: Vector3

	if $RayCast.is_colliding():
		new_at = $RayCast.get_collision_point()
		if target:
			# Locked to 'target' even if we're colliding with something else
			new_target = target
		else:
			# Target is whatever the raycast is colliding with
			new_target = $RayCast.get_collider()

	# If no current or previous collisions then skip
	if not new_target and not last_target:
		return

	# Handle pointer changes
	if new_target and not last_target:
		_visible_hit(new_at)
		# print("INFO: laser colliding at %s with %s"% [new_at, new_target.name])
	elif not new_target and last_target:
		_visible_miss()
		# print("INFO: laser not colliding")
	elif new_target != last_target:
		_visible_move(new_at)
		# print("INFO: laser moved at %s on %s" % [new_at, new_target.name])
	elif new_target == last_target:
		_visible_move(new_at)
		# print("INFO: laser moved at %s on same %s" % [new_at, new_target.name])
	elif new_at == last_collided_at:
		_visible_move(new_at)
		# print("INFO: laser moved at %s on %s" % [new_at, new_target.name])

	# Update last values
	last_target = new_target
	last_collided_at = new_at


func _visible_hit(at: Vector3) -> void:
	$Target.global_transform.origin = at
	$Target.visible = false

	# Ensure the correct laser material is set
	_update_laser_active_material(true)

	# Adjust laser length
	collide_len = at.distance_to(global_transform.origin)
	$Laser.mesh.size.z = collide_len
	$Laser.position.z = collide_len * -0.5

	# Show laser
	$Laser.visible = true


# Update the visible artifacts to show a miss
func _visible_miss() -> void:
	# Ensure target is hidden
	$Target.visible = false

	# Ensure the correct laser material is set
	_update_laser_active_material(false)

	# Restore laser length if set to collide-length
	$Laser.mesh.size.z = distance
	$Laser.position.z = distance * -0.5


func _visible_move(at: Vector3) -> void:
	var collide_len: float = at.distance_to(global_transform.origin)
	$Laser.mesh.size.z = collide_len
	$Laser.position.z = collide_len * -0.5


# Update the laser active material
func _update_laser_active_material(hit: bool) -> void:
	if hit and laser_hit_material:
		$Laser.set_surface_override_material(0, laser_hit_material)
	else:
		$Laser.set_surface_override_material(0, laser_material)

func is_colliding() -> bool:
	return $RayCast.get_collider() != null

func distance_to_target() -> float:
	if $RayCast.get_collider():
		return collide_len

	return 0

func get_state() -> Dictionary:
	return {
		position = var_to_str(position),
	}

func load_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
