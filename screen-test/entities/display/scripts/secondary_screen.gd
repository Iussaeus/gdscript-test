extends Node2D

@export var jump_block: PackedScene
@export var var_block: PackedScene
@export var if_block: PackedScene
@export var laser_block: PackedScene
@export var rotate_block: PackedScene
@export var move_block: PackedScene

@onready var jump_button: Button = $GridContainer/JumpButton
@onready var var_button: Button = $GridContainer/VarButton
@onready var if_button: Button = $GridContainer/IfButton
@onready var laser_button: Button = $GridContainer/LaserButton
@onready var rotate_button: Button = $GridContainer/RotateButton
@onready var move_button: Button = $GridContainer/MoveButton

func _on_jump_button_pressed():
	print("jump")
	pass

func _on_var_button_pressed():
	print("var")
	pass

func _on_if_button_pressed():
	print("if")
	pass

func _on_laser_button_pressed():
	print("laser")
	pass

func _on_rotate_button_pressed():
	print("rotate")
	pass

func _on_move_button_pressed():
	print("move")
	pass

