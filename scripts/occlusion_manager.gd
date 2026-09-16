class_name BrambleOcclusionManager
extends Node

@export var enabled := true

var _alpha_state: Dictionary = {}

func _process(delta: float) -> void:
	if not enabled:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	for node in get_tree().get_nodes_in_group("occluder"):
		if node is CanvasItem:
			_update_occluder(node as CanvasItem, player.global_position, delta)

func _update_occluder(item: CanvasItem, player_pos: Vector2, delta: float) -> void:
	if not item is Node2D:
		return
	var host := item as Node2D
	var foot_y := host.global_position.y
	if host.has_meta("occlusion_foot_y"):
		foot_y = float(host.get_meta("occlusion_foot_y"))
	elif host.has_meta("foot_y"):
		foot_y = float(host.get_meta("foot_y"))

	var half_w := float(host.get_meta("occlusion_half_w", 36.0))
	var canopy_h := float(host.get_meta("occlusion_height", 96.0))
	var canopy_top := foot_y - canopy_h

	var behind := player_pos.y < foot_y - BrambleWorldPresentationConfig.OCCLUSION_MIN_PLAYER_DEPTH
	var under_canopy := player_pos.y > canopy_top
	var within_x := absf(player_pos.x - host.global_position.x) <= half_w
	var covers := behind and under_canopy and within_x

	var target_alpha := BrambleWorldPresentationConfig.OCCLUSION_FADE if covers else 1.0
	var id := host.get_instance_id()
	var current := float(_alpha_state.get(id, 1.0))
	current = move_toward(current, target_alpha, delta * BrambleWorldPresentationConfig.OCCLUSION_FADE_SPEED)
	_alpha_state[id] = current

	var c := item.modulate
	c.a = current
	item.modulate = c
