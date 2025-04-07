@tool
class_name Board
extends XRToolsPickable

var snap_zones: Array[XRToolsSnapZone]

func _ready() -> void:
	for c in get_children():
		if c is XRToolsSnapZone:
			snap_zones.append(c)

	picked_up.connect(_on_picked_up)

# drop wait a short period of time an then pick up the items again
func _on_picked_up(pickable):
	print(pickable)
	for sz in snap_zones:
		# var picked_up_object := sz.picked_up_object
		sz.drop_object()
		# await get_tree().create_timer(0.5).timeout
		# sz.pick_up_object(picked_up_object)
	pass
