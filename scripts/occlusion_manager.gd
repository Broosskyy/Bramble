class_name BrambleOcclusionManager
extends Node

@export var enabled := true:
	set(value):
		enabled = value
		if not value and is_inside_tree():
			_restore_occluders()

var _alpha_state: Dictionary = {}

func _restore_occluders() -> void:
	for node in get_tree().get_nodes_in_group("occluder"):
		if node is CanvasItem:
			var item := node as CanvasItem
			var color := item.modulate
			color.a = 1.0
			item.modulate = color
	_alpha_state.clear()

func _process(delta: float) -> void:
	if not enabled:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var focus_points: Array[Vector2] = [player.global_position]
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	if targeting and targeting.has_method("get_target_position"):
		var target_pos: Variant = targeting.get_target_position()
		if target_pos is Vector2 and target_pos != Vector2.ZERO:
			focus_points.append(target_pos)
	for node in get_tree().get_nodes_in_group("occluder"):
		if node is CanvasItem:
			_update_occluder(node as CanvasItem, focus_points, delta)

func _update_occluder(item: CanvasItem, focus_points: Array[Vector2], delta: float) -> void:
	if not item is Node2D:
		return
	var host := item as Node2D
	var foot_y := host.global_position.y
	if host.has_meta("occlusion_foot_y"):
		foot_y = float(host.get_meta("occlusion_foot_y"))
	elif host.has_meta("foot_y"):
		foot_y = float(host.get_meta("foot_y"))

	var half_w := float(host.get_meta("occlusion_half_w", 48.0))
	var canopy_h := float(host.get_meta("occlusion_height", 120.0))
	var canopy_top := foot_y - canopy_h
	var min_depth := float(host.get_meta("occlusion_min_depth", BrambleWorldPresentationConfig.OCCLUSION_MIN_PLAYER_DEPTH))
	var fade_radius := float(host.get_meta("occlusion_fade_radius", half_w * 2.8))

	var covers := false
	for focus_pos in focus_points:
		var behind := focus_pos.y < foot_y - min_depth
		var under_canopy := focus_pos.y > canopy_top - 24.0 and focus_pos.y < foot_y + 12.0
		var within_x := absf(focus_pos.x - host.global_position.x) <= half_w + 18.0
		var within_radius := focus_pos.distance_to(host.global_position) <= fade_radius
		if behind and ((within_x and under_canopy) or within_radius):
			covers = true
			break

	var target_alpha := BrambleWorldPresentationConfig.OCCLUSION_FADE if covers else 1.0
	var id := host.get_instance_id()
	var current := float(_alpha_state.get(id, 1.0))
	current = move_toward(current, target_alpha, delta * BrambleWorldPresentationConfig.OCCLUSION_FADE_SPEED)
	_alpha_state[id] = current

	var c := item.modulate
	c.a = current
	item.modulate = c
