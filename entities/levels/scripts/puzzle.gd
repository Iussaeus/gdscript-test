class_name Puzzle extends Node

@onready var start: Marker3D = $Start
@onready var end: Area3D = $End

func _ready() -> void:
	GameState.puzzle_spawned.emit(self)

	end.body_entered.connect(_on_board_entered)
	
func _on_board_entered(body: Node3D) -> void:
	BlockManager.stop = true
	GameState.main_display.hide_blocks()
	GameState.main_display.next_level.visible = true
	print("INFO: end reached by %s" % body)
