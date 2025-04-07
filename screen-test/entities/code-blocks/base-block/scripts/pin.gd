@tool
class_name Pin extends Marker2D

@export var radius: float = 15: set = _set_radius
@export var width: float = 5: set = _set_width
@export var filled: bool = true: set = _set_filled
@export var color: Color = Color.MISTY_ROSE: set = _set_color

var curve: CurveRenderer

var _area: Area2D

func _ready() -> void:
	var circle := CircleShape2D.new()
	var collision := CollisionShape2D.new()
	var area := Area2D.new()
	circle.radius = radius
	collision.shape = circle
	area.add_child(collision)
	area.priority = 5
	_area = area
	add_child(area)

func _draw() -> void:
	if filled:
		draw_circle(Vector2(0,0), radius, color, filled, -1, true)
	else:
		draw_circle(Vector2(0,0), radius, color, filled, width, true)

func _set_radius(value: float) -> void:
	radius = value
	_area.get_child(0).shape.radius = value
	queue_redraw()

func _set_width(value: float) -> void:
	width = value
	queue_redraw()

func _set_filled(value: bool) -> void:
	filled = value
	queue_redraw()

func _set_color(value: Color) -> void:
	color = value
	queue_redraw()
