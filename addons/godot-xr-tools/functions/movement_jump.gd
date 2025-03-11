@tool
class_name XRToolsMovementJump
extends XRToolsMovementProvider


## XR Tools Movement Provider for Jumping
##
## This script provides jumping mechanics for the player. This script works
## with the [XRToolsPlayerBody] attached to the players [XROrigin3D].
##
## The player enables jumping by attaching an [XRToolsMovementJump] as a
## child of the appropriate [XRController3D], then configuring the jump button
## and jump velocity.


## Movement provider order
@export var order : int = 20

## Button to trigger jump
@export var jump_button_action : String = "trigger_click"

@export_range(0, 1, 0.1) var x_max: float = 0.5
@export_range(-1, 0, 0.1) var x_min: float = -0.5
@export_range(0, 1, 0.1) var y_min: float = 0.1
@export_range(0, 1, 0.1) var y_max: float = 0.1


# Node references
@onready var _controller := XRHelpers.get_xr_controller(self)


# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementJump" or super(name)


# Perform jump movement
func physics_movement(_delta: float, player_body: XRToolsPlayerBody, _disabled: bool):
	# Skip if the jump controller isn't active
	if !_controller.get_is_active():
		return

	# Request jump if the button is pressed
	if is_input_valid():
		player_body.request_jump()


func is_input_valid():
	var input_type := typeof(_controller.get_input(jump_button_action))
	var actual_input := _controller.get_input(jump_button_action)
	match input_type:
		# x < 0.3 and x > -0.3
		# y < - 0.2
		TYPE_VECTOR2:
			var vec_input := actual_input as Vector2
			if vec_input.x < x_max and vec_input.x > x_min and vec_input.y > y_min and vec_input.y < y_max:
				return true
			return false
		TYPE_BOOL:
			return actual_input as bool

# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Check the controller node
	if !XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")

	# Return warnings
	return warnings
