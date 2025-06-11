@tool
class_name Bumper extends Snapable

var _colliding: Area3D = null

@onready var _area: Area3D = $Area3D

func _ready() -> void:
	GameState.bumper_spawned.emit(self)
	_area.area_entered.connect(_on_body_entered)
	_area.area_exited.connect(_on_body_exited)

func _on_body_entered(area: Area3D) -> void:
	if area != self:
		_colliding = area 
		print("INFO: bumper colliding %s" % _colliding)

func _on_body_exited(area: Area3D) -> void:
	if area != self:
		_colliding = null
		print("INFO: NOT bumper colliding %s", % _colliding)

func is_colliding() -> bool:
	return _colliding != null

func get_state() -> Dictionary:
	return {
		position = var_to_str(position),
	}

func load_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
