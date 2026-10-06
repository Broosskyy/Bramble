class_name BrambleCombatTargetingService
extends Node

signal target_changed(state: Dictionary)

const TARGET_RANGE := 900.0
const CYCLE_RANGE := 520.0
const TAP_FALLBACK_RADIUS := 72.0
const PICKUP_RANGE := 72.0

var _target: Node2D = null
var _indicator: Node2D
var _state_refresh := 0.0

func _ready() -> void:
	add_to_group("combat_targeting_service")
	set_process_unhandled_input(true)
	call_deferred("_build_indicator")

func _build_indicator() -> void:
	_indicator = Node2D.new()
	_indicator.name = "TargetIndicator"
	_indicator.visible = false
	_indicator.z_index = 900
	var ring := Line2D.new()
	ring.width = 2.5
	ring.default_color = Color("#ffd35a")
	ring.closed = true
	var pts: PackedVector2Array = []
	for i in range(16):
		var a := TAU * float(i) / 16.0
		pts.append(Vector2(cos(a), sin(a)) * 34.0)
	ring.points = pts
	_indicator.add_child(ring)
	get_tree().current_scene.add_child(_indicator)

func _process(delta: float) -> void:
	_state_refresh = maxf(0.0, _state_refresh - delta)
	if _target == null or not is_instance_valid(_target):
		if _target != null:
			clear_target()
		return
	if _target.has_method("is_combat_alive") and not _target.is_combat_alive():
		clear_target()
		return
	if _indicator:
		_indicator.global_position = _target.global_position + Vector2(0, -72)
		_indicator.visible = true
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player and player.global_position.distance_to(_target.global_position) > TARGET_RANGE:
		clear_target()
		return
	if _state_refresh <= 0.0:
		_state_refresh = 0.08
		target_changed.emit(get_target_state())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pick(get_viewport().get_canvas_transform().affine_inverse() * event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_pick(get_viewport().get_canvas_transform().affine_inverse() * event.position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_cycle_target()

func _handle_pick(world_pos: Vector2) -> void:
	if _try_pickup_at(world_pos):
		return
	_try_target_at(world_pos)

func _try_target_at(world_pos: Vector2) -> void:
	var space := _space_state()
	if space == null:
		return
	var params := PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collide_with_areas = false
	params.collide_with_bodies = true
	params.collision_mask = 2
	for hit in space.intersect_point(params, 8):
		var node := hit.collider as Node
		if node == null:
			continue
		if node.is_in_group("enemy"):
			set_target(node as Node2D)
			return
		if node.get_parent() and node.get_parent().is_in_group("enemy"):
			set_target(node.get_parent() as Node2D)
			return
	# Mobile taps do not have mouse precision. If the physics body was missed,
	# select the closest living enemy around the tapped world position.
	var fallback := _nearest_enemy_to_point(world_pos, TAP_FALLBACK_RADIUS)
	if fallback:
		set_target(fallback)

func _try_pickup_at(world_pos: Vector2) -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return false
	for node in get_tree().get_nodes_in_group("loot"):
		if node is Node2D and node.global_position.distance_to(player.global_position) <= PICKUP_RANGE:
			if node.global_position.distance_to(world_pos) <= 48.0 and node.has_method("pickup"):
				node.pickup(player)
				return true
	return false

func _cycle_target() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var options: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D and node.has_method("is_combat_alive") and node.is_combat_alive():
			if player.global_position.distance_to(node.global_position) <= CYCLE_RANGE:
				options.append(node)
	if options.is_empty():
		clear_target()
		return
	if _target == null or not is_instance_valid(_target):
		target_nearest(CYCLE_RANGE)
		return
	var idx := options.find(_target)
	set_target(options[(idx + 1) % options.size()])

func target_nearest(max_range: float = CYCLE_RANGE) -> Node2D:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return null
	var best: Node2D = null
	var best_distance := max_range
	for node in get_tree().get_nodes_in_group("enemy"):
		if not (node is Node2D):
			continue
		if node.has_method("is_combat_alive") and not node.is_combat_alive():
			continue
		var distance := player.global_position.distance_to(node.global_position)
		if distance <= best_distance:
			best = node
			best_distance = distance
	if best:
		set_target(best)
	return best

func _nearest_enemy_to_point(world_pos: Vector2, radius: float) -> Node2D:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var best: Node2D = null
	var best_distance := radius
	for node in get_tree().get_nodes_in_group("enemy"):
		if not (node is Node2D):
			continue
		if node.has_method("is_combat_alive") and not node.is_combat_alive():
			continue
		if player and player.global_position.distance_to(node.global_position) > TARGET_RANGE:
			continue
		var tap_distance := world_pos.distance_to(node.global_position)
		if tap_distance <= best_distance:
			best = node
			best_distance = tap_distance
	return best

func set_target(node: Node2D) -> void:
	if node == null or not is_instance_valid(node):
		clear_target()
		return
	if node.has_method("is_combat_alive") and not node.is_combat_alive():
		clear_target()
		return
	_target = node
	_state_refresh = 0.0
	target_changed.emit(get_target_state())

func clear_target() -> void:
	_target = null
	if _indicator:
		_indicator.visible = false
	target_changed.emit(get_target_state())

func get_target() -> Node2D:
	return _target if _target and is_instance_valid(_target) else null

func get_target_position() -> Vector2:
	var target := get_target()
	if target:
		return target.global_position
	return Vector2.ZERO

func get_target_entity_id() -> int:
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	var target := get_target()
	if target == null or registry == null:
		return 0
	return registry.entity_id_for(target)

func get_target_state() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var target := get_target()
	if target == null or player == null:
		return {
			"entity_id": 0,
			"hp": 0,
			"max_hp": 0,
			"distance": 9999.0,
			"alive": false,
			"valid": false,
			"name": "",
		}
	var dist := player.global_position.distance_to(target.global_position)
	var alive := true
	if target.has_method("is_combat_alive"):
		alive = target.is_combat_alive()
	var max_hp := int(target.get("max_hp"))
	var hp := int(target.get("hp"))
	return {
		"entity_id": get_target_entity_id(),
		"hp": hp,
		"max_hp": max_hp,
		"distance": dist,
		"alive": alive,
		"valid": alive and dist <= TARGET_RANGE,
		"name": String(target.get("enemy_name")),
	}

func _space_state() -> PhysicsDirectSpaceState2D:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		return player.get_world_2d().direct_space_state
	return null
