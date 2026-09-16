class_name BrambleElevationService
extends Node

var _levels: Dictionary = {}

func _ready() -> void:
	add_to_group("elevation_service")

func set_player_height(body: Node, level: int, zone_name: String) -> void:
	var id := body.get_instance_id()
	if not _levels.has(id):
		_levels[id] = {}
	_levels[id][zone_name] = level
	_apply(body)

func clear_player_height(body: Node, level: int, zone_name: String) -> void:
	var id := body.get_instance_id()
	if not _levels.has(id):
		return
	_levels[id].erase(zone_name)
	_apply(body)

func current_level(body: Node) -> int:
	var id := body.get_instance_id()
	if not _levels.has(id) or _levels[id].is_empty():
		return 0
	var best := 0
	for zone in _levels[id]:
		best = maxi(best, int(_levels[id][zone]))
	return best

func height_offset(level: int) -> float:
	match level:
		1: return -BrambleWorldPresentationConfig.HEIGHT_H1_OFFSET
		2: return -BrambleWorldPresentationConfig.HEIGHT_H2_OFFSET
		_: return 0.0

func _apply(body: Node) -> void:
	if not body is Node2D:
		return
	var level := current_level(body)
	body.set_meta("height_level", level)
	var foot := body.get_node_or_null("FootpointSort") as BrambleFootpointSort
	if foot:
		foot.height_level = level
	var visual := body.get_node_or_null("Visual")
	if visual:
		visual.position.y = -58.0 + height_offset(level) * 0.15
