@tool
class_name CurveRenderer extends Node2D 

@export var start_position: Vector2 = Vector2(0,0): set = _set_start
@export var end_position: Vector2 = Vector2(0, 0): set = _set_end
@export var curve_offset: Vector2 = Vector2(5, 0): set = _set_curve_offset
@export var middle_offset: Vector2 = Vector2(0, 0): set = _set_middle_offset
@export var in_: Vector2 = Vector2(-25, 0): set = _set_in_
@export var out: Vector2 = Vector2(25, 0): set = _set_out

@export var width: float = 1

var start_marker: Marker2D = null
var end_marker: Marker2D = null

var _line: Line2D
var _path : Path2D
var _curve: Curve2D

var _end_prev_pos: Vector2
var _start_prev_pos: Vector2

var _visible: bool = false: set = _set_visible

func _ready() -> void:
	var line := Line2D.new()
	add_child(line)
	_line = line

	var curve := Curve2D.new()
	var path := Path2D.new()
	path.curve = curve
	add_child(path)
	_path = path
	_curve = curve 

func _process(_delta:float):
	if start_marker and end_marker:
		if start_marker.global_position != _start_prev_pos or \
		to_local(end_marker.global_position) !=_end_prev_pos:
			queue_redraw()

func _draw() -> void:
	if _visible:
		draw_curve()

func toggle():
	_visible = not _visible
	_line.clear_points()
	_curve.clear_points()
	
func draw_curve():
	if start_marker:
		global_position = start_marker.global_position
		_start_prev_pos = start_marker.global_position

	if end_marker:
		end_position = to_local(end_marker.global_position)
		_end_prev_pos = to_local(end_marker.global_position)

	_line.clear_points()
	_curve.clear_points()

	_curve.add_point(start_position, Vector2.ZERO, Vector2.ZERO)
	_curve.add_point(start_position + curve_offset, in_, out)

	var middle := end_position / 2
	_curve.add_point(middle + middle_offset, Vector2.ZERO, Vector2.ZERO)

	_curve.add_point(end_position - curve_offset, in_, out)
	_curve.add_point(end_position, Vector2.ZERO, Vector2.ZERO)

	var points := _curve.get_baked_points()
	_line.width = width
	for p in points:
		_line.add_point(p)


func _set_start(value):
	start_position = value
	queue_redraw()
 
func _set_end(value):
	end_position = value
	queue_redraw()
 
func _set_curve_offset(value):
	curve_offset = value
	queue_redraw()
 
func _set_middle_offset(value):
	middle_offset = value
	queue_redraw()
 
func _set_in_(value):
	in_ = value
	queue_redraw()
 
func _set_out(value):
	out = value
	queue_redraw()

func _set_width(value):
	width = value
	queue_redraw()

func _set_visible(value):
	_visible = value
	_line.clear_points()
	_curve.clear_points()
