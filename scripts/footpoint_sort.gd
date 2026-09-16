class_name BrambleFootpointSort
extends Node

@export var height_level := 0
@export var foot_offset := Vector2.ZERO
@export var auto_update := true

var _host: Node2D

func _ready() -> void:
	_host = get_parent() as Node2D
	_apply()

func _process(_delta: float) -> void:
	if auto_update and _host:
		_apply()

func foot_global_y() -> float:
	if _host == null:
		return 0.0
	return _host.global_position.y + foot_offset.y

func _apply() -> void:
	if _host == null:
		return
	var foot_y := _host.global_position.y + foot_offset.y
	_host.z_index = BrambleWorldPresentationConfig.sort_key(foot_y, height_level)
	_host.z_as_relative = false
