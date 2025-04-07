extends Area2D

var current_block: CodeBlock 
var current_pin: Pin 

@onready var marker: Marker2D = $Marker2D

# TODO: make it use the pins
func _on_area_entered(area:Area2D) -> void:
	if area.get_parent() is CodeBlock:
		current_block = area.get_parent()

	if area.get_parent() is Pin:
		current_pin = area.get_parent()

func _on_area_exited(area:Area2D) -> void:
	if area.get_parent() is CodeBlock:
		current_block = null

	if area.get_parent() is Pin:
		current_pin = null
