@tool
class_name CodeBlock extends Node2D

@export var size: Vector2 = Vector2(128, 72): set = _set_size
@export var color: Color = Color.NAVY_BLUE: set = _set_color
@export var width: int = 1: set = _set_width
@export var filled: bool = true: set = _set_filled
@export_category("Line")
@export var curve_width: float = 3: set = _set_curve_width
@export var curve_offset: Vector2 = Vector2(15, 0): set = _set_curve_offset
@export var curve_middle_offset: Vector2 = Vector2(0, 0): set = _set_curve_middle_offset
@export var curve_in: Vector2 = Vector2(-25, 0): set = _set_curve_in
@export var curve_out: Vector2 = Vector2(25, 0): set = _set_curve_out
@export_category("Pins")
@export var pin_radius: float = 10: set = _set_pin_radius
@export var pin_width: float = 5: set = _set_pin_width
@export var pin_filled: bool = true: set = _set_pin_filled
@export var pin_color: Color = Color.DARK_CYAN: set = _set_pin_color
@export_category("Connections")
@export_range(1, 32) var in_connections: int = 1: set = _set_in_connections
@export_range(1, 32) var out_connections: int = 1: set = _set_out_connections

var pins: Array[Pin]
var _area: Area2D

func _ready() -> void:
	var area := Area2D.new()
	var rect := RectangleShape2D.new()
	var collision := CollisionShape2D.new()

	rect.size = size
	collision.shape = rect
	area.add_child(collision)
	area.position = size / 2
	_area = area
	area.priority = 1
	add_child(area)

	_add_pins()

# TODO: render text like the current value and name
func _draw() -> void:
	var style_box := StyleBoxFlat.new()
	style_box.set_corner_radius_all(10)
	style_box.bg_color = color
	style_box.set_border_width_all(width)
	style_box.anti_aliasing = true
	var rect := Rect2(0, 0, size.x, size.y)
	draw_style_box(style_box, rect)

func _add_pins() -> void:
	if pins.size() > 0:
		_clear_pins()

	var interval := size.y / (in_connections + 1)
	for i in range(in_connections):
		var pin := Pin.new()
		add_child(pin)
		pins.append(pin)

		pin.color = pin_color
		pin.width = pin_width
		pin.filled = pin_filled
		pin.radius = pin_radius

		if in_connections == 1:
			pin.position = Vector2(0, size.y / 2)
			break
		else:
			pin.position = Vector2(0, interval * (i + 1))

	interval = size.y / (out_connections + 1)
	for i in range(out_connections):
		var pin := Pin.new()
		var curve := CurveRenderer.new()
		add_child(pin)
		pins.append(pin)

		pin.color = pin_color
		pin.width = pin_width
		pin.filled = pin_filled
		pin.radius = pin_radius
		pin.curve = curve
		pin.curve.width = curve_width  
		pin.curve.start_marker = pin
		pin.add_child(curve)

		if out_connections == 1:
			pin.position = Vector2(size.x, size.y / 2)
			break
		else:
			pin.position = Vector2(size.x, interval * (i + 1))

func _clear_pins() -> void:
	for p in pins:
		p.queue_free()

	pins.clear()

func _refresh_pin_positions() -> void:
	var interval := size.y / (in_connections + 1)
	for i in range(in_connections):
		if in_connections == 1:
			pins[i].position = Vector2(0, size.y / 2)
			break
		else:
			pins[i].position = Vector2(0, interval * (i + 1))

	interval = size.y / (out_connections + 1)
	for i in range(in_connections, in_connections + out_connections):
		if out_connections == 1:
			pins[i].position = Vector2(size.x, size.y / 2)
			break
		else:
			pins[i].position = Vector2(size.x, interval * (i - in_connections + 1 ))

func pin_idx(p: Pin) -> int:
	for i in range(in_connections + out_connections):
		if p == pins[i]:
			return i

	return -1

func _set_size(value: Vector2) -> void:
	size = value
	_area.get_child(0).shape.size = size
	_area.position = size / 2
	_refresh_pin_positions()
	queue_redraw()


func _set_color(value: Color) -> void:
	color = value
	queue_redraw()


func _set_width(value: int) -> void:
	width = value
	queue_redraw()


func _set_filled(value: bool) -> void:
	filled = value
	queue_redraw()

# TODO: set the radius of the pins
func _set_radius(value: float) -> void:
	pin_radius = value
	queue_redraw()

func _set_curve_width(value: float) -> void:
	curve_width = value
	for i in range(in_connections, in_connections + out_connections):
		pins[i].curve.width = curve_width


func _set_curve_offset(value: Vector2) -> void:
	curve_offset = value
	for i in range(in_connections, in_connections + out_connections):
		pins[i].curve.curve_offset = curve_offset 

func _set_curve_middle_offset(value: Vector2) -> void:
	curve_middle_offset = value
	for i in range(in_connections, in_connections + out_connections):
		pins[i].curve.middle_offset = curve_middle_offset

func _set_curve_in(value: Vector2) -> void:
	curve_in = value
	for i in range(in_connections, in_connections + out_connections):
		pins[i].curve.in_ = curve_in

func _set_curve_out(value: Vector2) -> void:
	curve_out = value
	for i in range(in_connections, in_connections + out_connections):
		pins[i].curve.out = curve_out 

func _set_pin_radius(value: float) -> void:
	pin_radius = value
	for p in pins:
		p.radius = value

func _set_pin_width(value: float) -> void:
	pin_width = value
	for p in pins:
		p.width = value

func _set_pin_filled(value: bool) -> void:
	pin_filled = value
	for p in pins:
		p.filled = value

func _set_pin_color(value: Color) -> void:
	pin_color = value
	for p in pins:
		p.color = value

func _set_in_connections(value: int) -> void:
	in_connections = value
	_add_pins()
	_refresh_pin_positions()
	
func _set_out_connections(value: int) -> void:
	out_connections = value
	_add_pins()
	_refresh_pin_positions()
	
func _check_signature(params:Array[Variant]) -> bool:
	var logic := Callable.create(self, "_logic")
	var sig := logic.get_argument_count()
	# var sig2 := logic.get_bound_arguments()

	if sig != params.size():
		return false

	return true

func _execute(params:Array[Variant]) -> Variant:
	if _check_signature(params):
		return _logic(params)
	else:
		return null 

# virtual methods to override
func _logic(_params:Array) -> Array:
	return []
