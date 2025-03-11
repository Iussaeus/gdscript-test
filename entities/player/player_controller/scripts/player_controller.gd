class_name PlayerController

extends CharacterBody3D

@export var movement_speed: float = 1.0
## IN RADIANS
@export var rotation_speed: float = 0.1
@export var h_acceleration: float = 0.1

@onready var origin: XROrigin3D = $XROrigin3D
@onready var camera: Camera3D = $XROrigin3D/XRCamera3D
@onready var neck: Node3D = $XROrigin3D/XRCamera3D/Neck

# var _h_velocity: Vector3


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
