class_name BrambleWorldCameraController
extends Camera2D

func _ready() -> void:
	add_to_group("world_camera")
	position = BrambleWorldPresentationConfig.CAMERA_OFFSET
	position_smoothing_enabled = true
	position_smoothing_speed = BrambleWorldPresentationConfig.CAMERA_SMOOTH_SPEED
	limit_left = int(BrambleWorldPresentationConfig.CAMERA_LIMITS.position.x)
	limit_top = int(BrambleWorldPresentationConfig.CAMERA_LIMITS.position.y)
	limit_right = int(BrambleWorldPresentationConfig.CAMERA_LIMITS.position.x + BrambleWorldPresentationConfig.CAMERA_LIMITS.size.x)
	limit_bottom = int(BrambleWorldPresentationConfig.CAMERA_LIMITS.position.y + BrambleWorldPresentationConfig.CAMERA_LIMITS.size.y)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient.orientation_changed.connect(_apply_profile)
		_apply_profile(orient.mode_name())

func _apply_profile(_mode: String) -> void:
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient == null:
		zoom = Vector2.ONE * BrambleWorldPresentationConfig.CAMERA_ZOOM_LANDSCAPE
		return
	var target := BrambleWorldPresentationConfig.CAMERA_ZOOM_PORTRAIT if orient.is_portrait() else BrambleWorldPresentationConfig.CAMERA_ZOOM_LANDSCAPE
	zoom = Vector2.ONE * target
