class_name BrambleOrientationService
extends Node

signal orientation_changed(mode: String)

enum Mode { LANDSCAPE, PORTRAIT }

const LANDSCAPE_CANVAS := Vector2i(1280, 720)
const PORTRAIT_CANVAS := Vector2i(720, 1280)

var mode := Mode.LANDSCAPE

func _ready() -> void:
	add_to_group("orientation_service")
	get_viewport().size_changed.connect(_refresh)
	call_deferred("force_refresh")

func force_refresh() -> void:
	var size := _current_size()
	mode = Mode.PORTRAIT if size.y > size.x else Mode.LANDSCAPE
	_apply_logical_canvas()
	orientation_changed.emit(mode_name())

func _current_size() -> Vector2i:
	var win := get_window()
	if win and win.size.x > 0 and win.size.y > 0:
		return win.size
	return Vector2i(get_viewport().get_visible_rect().size)

func _refresh() -> void:
	var size := _current_size()
	var next := Mode.PORTRAIT if size.y > size.x else Mode.LANDSCAPE
	if next != mode:
		mode = next
		_apply_logical_canvas()
		orientation_changed.emit(mode_name())

func _apply_logical_canvas() -> void:
	var window := get_window()
	if window == null:
		return
	var wanted := PORTRAIT_CANVAS if mode == Mode.PORTRAIT else LANDSCAPE_CANVAS
	if window.content_scale_size != wanted:
		window.content_scale_size = wanted

func mode_name() -> String:
	return "portrait" if mode == Mode.PORTRAIT else "landscape"

func is_portrait() -> bool:
	return mode == Mode.PORTRAIT

func safe_margin() -> float:
	return 24.0 if is_portrait() else 18.0
