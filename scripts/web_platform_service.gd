class_name BrambleWebPlatformService
extends Node

signal viewport_metrics_changed(logical_size: Vector2, safe_insets: Vector4)
signal fullscreen_changed(active: bool)

const RESIZE_SETTLE_FRAMES := 2

var _refresh_generation := 0
var _last_fullscreen := false

func _ready() -> void:
	add_to_group("web_platform_service")
	get_viewport().size_changed.connect(_queue_metrics_refresh)
	_last_fullscreen = is_fullscreen()
	set_process(true)
	call_deferred("_queue_metrics_refresh")

func _process(_delta: float) -> void:
	var active := is_fullscreen()
	if active == _last_fullscreen:
		return
	_last_fullscreen = active
	fullscreen_changed.emit(active)
	_queue_metrics_refresh()

func toggle_fullscreen() -> void:
	# Browser fullscreen must be requested directly from a user gesture. The HUD
	# therefore calls this method from its button's pressed callback.
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_queue_metrics_refresh()

func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func safe_insets() -> Vector4:
	var viewport_size := get_viewport().get_visible_rect().size
	var physical_size := Vector2(get_window().size)
	var safe_rect := DisplayServer.get_display_safe_area()
	return calculate_logical_safe_insets(viewport_size, physical_size, safe_rect)

func _queue_metrics_refresh() -> void:
	_refresh_generation += 1
	_settle_and_emit(_refresh_generation)

func _settle_and_emit(generation: int) -> void:
	for _frame in range(RESIZE_SETTLE_FRAMES):
		await get_tree().process_frame
	if generation != _refresh_generation:
		return
	viewport_metrics_changed.emit(get_viewport().get_visible_rect().size, safe_insets())

static func calculate_logical_safe_insets(logical_size: Vector2, physical_size: Vector2, safe_rect: Rect2i) -> Vector4:
	if logical_size.x <= 0.0 or logical_size.y <= 0.0 or physical_size.x <= 0.0 or physical_size.y <= 0.0:
		return Vector4.ZERO
	if safe_rect.size.x <= 0 or safe_rect.size.y <= 0:
		return Vector4.ZERO
	var scale := Vector2(logical_size.x / physical_size.x, logical_size.y / physical_size.y)
	var left := maxf(0.0, float(safe_rect.position.x) * scale.x)
	var top := maxf(0.0, float(safe_rect.position.y) * scale.y)
	var safe_right := float(safe_rect.position.x + safe_rect.size.x)
	var safe_bottom := float(safe_rect.position.y + safe_rect.size.y)
	var right := maxf(0.0, (physical_size.x - safe_right) * scale.x)
	var bottom := maxf(0.0, (physical_size.y - safe_bottom) * scale.y)
	return Vector4(left, top, right, bottom)
