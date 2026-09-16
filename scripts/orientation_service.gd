class_name BrambleOrientationService
extends Node

signal orientation_changed(mode: String)

enum Mode { LANDSCAPE, PORTRAIT }

var mode := Mode.LANDSCAPE

func _ready() -> void:
	add_to_group("orientation_service")
	get_viewport().size_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var size := get_viewport().get_visible_rect().size
	var next := Mode.PORTRAIT if size.y > size.x else Mode.LANDSCAPE
	if next != mode:
		mode = next
		orientation_changed.emit(mode_name())

func mode_name() -> String:
	return "portrait" if mode == Mode.PORTRAIT else "landscape"

func is_portrait() -> bool:
	return mode == Mode.PORTRAIT

func safe_margin() -> float:
	return 24.0 if is_portrait() else 18.0
