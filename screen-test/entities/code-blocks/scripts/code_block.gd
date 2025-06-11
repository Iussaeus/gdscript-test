@tool
class_name CodeBlock extends Node2D

@export var size: Vector2 = Vector2(256, 72): set = _set_size
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
@export var pin_padding: int = 4: set = _set_pin_padding
@export_category("Connections")
@export_range(1, 32) var in_connections: int = 1: set = _set_in_connections
@export_range(1, 32) var out_connections: int = 1: set = _set_out_connections

var in_pins: Array[Pin] = []
var out_pins: Array[Pin] = []
var in_pin_names: Array[String] = []
var out_pin_names: Array[String] = []
var draw_name: bool = true

var _area: Area2D
var _regex: RegEx

@onready var _font: Font = ThemeDB.fallback_font
@onready var _font_size: int = ThemeDB.fallback_font_size

func _ready() -> void:
	_regex = RegEx.new()
	_regex.compile("(?:(?!Block|\\d).)+")
	# _regex.compile(".*")

	var area := Area2D.new()
	var rect := RectangleShape2D.new()
	var collision := CollisionShape2D.new()

	rect.size = size
	collision.shape = rect
	area.add_child(collision)
	area.position = size / 2
	_area = area
	area.priority = 1

	add_child(_area)

	_add_pins()
	set_pin_names()

# TODO: render text like the current value and name
# TODO: set the size based on the pin names, if they fit ???
func _draw() -> void:
	var style_box := StyleBoxFlat.new()
	style_box.set_corner_radius_all(10)
	style_box.bg_color = color
	style_box.set_border_width_all(width)
	style_box.anti_aliasing = true
	var rect := Rect2(0, 0, size.x, size.y)
	draw_style_box(style_box, rect)
	for i in range(in_connections):
		var pos := in_pins[i].position + Vector2(in_pins[i].radius + pin_padding , in_pins[i].radius / 2)
		draw_string(_font, pos, in_pin_names[i],HORIZONTAL_ALIGNMENT_LEFT, -1 ,_font_size)

	for i in range(out_connections):
		var pin_name_size := _font.get_string_size(out_pin_names[i])
		var pos := out_pins[i].position + Vector2( - out_pins[i].radius - pin_name_size.x - pin_padding, out_pins[i].radius / 2)
		draw_string(_font, pos, out_pin_names[i],HORIZONTAL_ALIGNMENT_RIGHT, -1 ,_font_size)
	
	if draw_name:
		var name_stripped := _regex.search(name).get_string()
		var name_size := _font.get_string_size(name_stripped)
		var pos := Vector2((size.x/2) - (name_size.x/2), name_size.y - 4) 
		draw_string(_font, pos, name_stripped, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)

func _add_pins() -> void:
	if in_pins.size() > 0:
		_clear_in_pins()

	var interval := 0.0
	if in_connections > 0:
		interval = size.y / (in_connections + 1)
		for i in range(in_connections):
			var pin := Pin.new()
			add_child(pin)
			in_pins.append(pin)

			pin.color = pin_color
			pin.width = pin_width
			pin.filled = pin_filled
			pin.radius = pin_radius

			if in_connections == 1:
				pin.position = Vector2(0, size.y / 2)
				break
			else:
				pin.position = Vector2(0, interval * (i + 1))

	if out_pins.size() > 0:
		_clear_out_pins()

	if out_connections > 0:
		interval = size.y / (out_connections + 1)
		for i in range(out_connections):
			var pin := Pin.new()
			var curve := CurveRenderer.new()
			add_child(pin)
			out_pins.append(pin)

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

func _clear_in_pins() -> void:
	for p in in_pins:
		p.queue_free()

	in_pins.clear()

func _clear_out_pins() -> void:
	for p in out_pins:
		p.queue_free()

	out_pins.clear()

func _refresh_pin_positions() -> void:
	var interval := 0.0
	if in_connections >= 1:
		interval = size.y / (in_connections + 1)
		for i in range(in_connections):
			if in_connections == 1:
				in_pins[i].position = Vector2(0, size.y / 2)
				break
			else:
				in_pins[i].position = Vector2(0, interval * (i + 1))

	if out_connections >= 1:
		interval = size.y / (out_connections + 1)
		for i in range(out_connections):
			if out_connections == 1:
				out_pins[i].position = Vector2(size.x, size.y / 2)
				break
			else:
				out_pins[i].position = Vector2(size.x, interval * (i + 1 ))

func in_pin_idx(p: Pin) -> int:
	return in_pins.find(p)

func out_pin_idx(p: Pin) -> int:
	return out_pins.find(p)

func _set_size(value: Vector2) -> void:
	size = value
	if _area:
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
	for p in in_pins + out_pins:
		p.curve.width = curve_width

func _set_curve_offset(value: Vector2) -> void:
	curve_offset = value
	for p in in_pins + out_pins:
		p.curve.curve_offset = curve_offset

func _set_curve_middle_offset(value: Vector2) -> void:
	curve_middle_offset = value
	for p in in_pins + out_pins:
		p.curve.middle_offset = curve_middle_offset

func _set_curve_in(value: Vector2) -> void:
	curve_in = value
	for p in in_pins + out_pins:
		p.curve.in = curve_in

func _set_curve_out(value: Vector2) -> void:
	curve_out = value
	for p in in_pins + out_pins:
		p.curve.out= curve_out

func _set_pin_radius(value: float) -> void:
	pin_radius = value
	for p in in_pins + out_pins:
		p.radius = value

func _set_pin_width(value: float) -> void:
	pin_width = value
	for p in in_pins + out_pins:
		p.width = value

func _set_pin_filled(value: bool) -> void:
	pin_filled = value
	for p in in_pins + out_pins:
		p.filled = value

func _set_pin_padding(value: int) -> void:
	pin_padding = value
	queue_redraw()

func _set_pin_color(value: Color) -> void:
	pin_color = value
	for p in in_pins + out_pins:
		p.color = value

func _set_in_connections(value: int) -> void:
	in_connections = value
	in_pin_names.resize(in_connections)
	_add_pins()
	_resize()
	_refresh_pin_positions()
	
func _set_out_connections(value: int) -> void:
	out_connections = value
	in_pin_names.resize(in_connections)
	_add_pins()
	_resize()
	_refresh_pin_positions()

func _resize() -> void:
	if out_connections > in_connections:
		size = Vector2(size.x, (pin_radius * out_connections) + (16 * 2 * out_connections))
	else:
		size = Vector2(size.x, (pin_radius * in_connections) + (16 * 2 * in_connections))
	
func _execute(params: Array=[]) -> Variant:
	if _check_signature(params):
		var result := await _logic(params)
		return result
	else:
		return [] 

func set_pin_names(in_names: Array[String]=[], out_names: Array[String]=[]) -> void:
	in_pin_names.resize(in_connections)
	in_pin_names[0] = "entry"

	if in_names != []:
		var idx := 0
		for i in range(1, in_connections):
			# if pin_names[i] == "":
				in_pin_names[i] = in_names[idx] 
				idx += 1

	out_pin_names.resize(out_connections)
	out_pin_names[0] = "exit"

	if out_names != []:
		var idx := 0
		for i in range(1, out_connections):
			# if pin_names[i] == "":
				out_pin_names[i] = out_names[idx] 
				idx += 1

func set_block_name(new_name: String) -> void:
	name = "%s%d" % [new_name,GameState.code_block_count]

# virtual methods to override
func _logic(params: Array=[]) -> Variant:
	print("INFO: Executing %s base _logic with params %s" % [name, params])
	return []

func _check_signature(params: Array=[]) -> bool:
	print("INFO: base _check_signature called from %s with params %s" % [name, params])
	return true
