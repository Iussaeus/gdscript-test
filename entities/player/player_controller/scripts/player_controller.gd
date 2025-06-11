class_name PlayerController

extends XROrigin3D

@export var primary_action_button_action : String = "primary_click"
@onready var _controller := XRHelpers.get_xr_controller($RightHand)

func _ready() -> void:
	GameState.player_spawned.emit(self)

func _process(_delta: float) -> void:
	if _controller.get_input(primary_action_button_action):
		if not GameState.in_main_menu:
			GameState.open_menu()
			print("INFO: Opened main menu")
		elif GameState.in_main_menu:
			GameState.close_menu()
			print("INFO: Closed main menu")
		await get_tree().create_timer(1).timeout

func get_state() -> Dictionary:
	return {
		position = var_to_str(position),
	}

func load_state(state: Dictionary) -> void:
	position = str_to_var(state.position)
