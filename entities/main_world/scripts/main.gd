extends Node3D

@export var main_display: Node2D
static var player: XROrigin3D
@export var robot: Node3D
@export var laser: Node3D
@export var thruster: Node3D

func _ready() -> void:
	await get_tree().create_timer(.5).timeout
	for c in get_children(true):
		if c is XROrigin3D:
			player = c

		if c is XRToolsViewport2DIn3D:
			main_display = c

		if c is Board:
			robot = c

	print("main")
	if main_display:
		print(main_display.name)

	if player:
		print(player.name)

	if robot:
		print(robot.name)
