extends Node3D

# signal focus_gained
# signal focus_lost
# signal recentered

@export var max_refresh_rate: int = 90

var xr_interface: OpenXRInterface
var xr_is_focused: bool = false


func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")

	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Vsync is handled by OpenXR
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		var vp := get_viewport()
		vp.use_xr = true

		var fov_lvl: int = int(ProjectSettings.get_setting("xr/openxr/foveation_level"))

		if RenderingServer.get_rendering_device():
			vp.vrs_mode = Viewport.VRS_XR
		elif fov_lvl == 0:
			push_warning("OpenXR: Recommend setting Foveation level to High in Project Settings")

		# Connect the OpenXR events
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)

	else:
		# We couldn't start OpenXR.
		print("OpenXR not instantiated!")
		get_tree().quit()


func _on_openxr_session_begun() -> void:
	pass


func _on_openxr_visible_state() -> void:
	pass


func _on_openxr_focused_state() -> void:
	pass


func _on_openxr_stopping() -> void:
	pass


func _on_openxr_pose_recentered() -> void:
	pass
