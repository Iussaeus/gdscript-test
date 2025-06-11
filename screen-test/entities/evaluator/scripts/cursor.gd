extends Area2D

var current_block: CodeBlock 
var current_pin: Pin 
var gui: bool = false

@onready var marker: Marker2D = $Marker2D

func _on_area_entered(area:Area2D) -> void:
	if area.name == "op_area" :
		# print("Info: Interacting with gui")
		gui = true

	if area.get_parent() is Pin:
		current_pin = area.get_parent()

	if area.get_parent() is CodeBlock:
		current_block = area.get_parent()

	if get_overlapping_areas().size() > 1:
		for a in get_overlapping_areas():
			if a.get_parent() is CodeBlock:
				if a.z_index == 1 or a.get_parent().name.contains(str(GameState._code_block_count)):
					current_block = a.get_parent()
		
func _on_area_exited(area:Area2D) -> void:
	if area.get_parent() is CodeBlock:
		current_block = null

	if area.get_parent() is Pin:
		current_pin = null

	if area.name == "op_area" :
		# print("Info: DONE Interacting with gui")
		gui = false
