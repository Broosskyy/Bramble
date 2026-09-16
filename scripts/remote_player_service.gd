class_name BrambleRemotePlayerService
extends Node

var _avatars: Dictionary = {}
var _missing_counts: Dictionary = {}

func _ready() -> void:
	add_to_group("remote_player_service")

func avatar_count() -> int:
	var count := 0
	for peer_id in _avatars.keys():
		if is_instance_valid(_avatars[peer_id]):
			count += 1
	return count

func sync_players(players: Array, local_peer_id: int) -> void:
	var seen: Dictionary = {}
	for raw in players:
		if not raw is Dictionary:
			continue
		var s: Dictionary = raw
		var peer_id := int(s.get("peer_id", -1))
		if peer_id <= 0 or peer_id == local_peer_id:
			continue
		if not bool(s.get("connected", true)):
			if _avatars.has(peer_id):
				_despawn(peer_id)
			_missing_counts.erase(peer_id)
			continue
		seen[peer_id] = true
		var avatar := _ensure_avatar(peer_id)
		avatar.global_position = Vector2(float(s.get("x", 0.0)), float(s.get("y", 360.0)))
		var visual := avatar.get_node_or_null("Visual") as Sprite2D
		if visual:
			var dx := float(s.get("dir_x", 0.0))
			visual.flip_h = dx < 0.0
	for peer_id in _avatars.keys().duplicate():
		if seen.has(peer_id):
			_missing_counts.erase(peer_id)
			continue
		_missing_counts[peer_id] = int(_missing_counts.get(peer_id, 0)) + 1
		if _missing_counts[peer_id] >= 3:
			_despawn(peer_id)
			_missing_counts.erase(peer_id)

func _ensure_avatar(peer_id: int) -> Node2D:
	if _avatars.has(peer_id) and is_instance_valid(_avatars[peer_id]):
		return _avatars[peer_id]
	var body := CharacterBody2D.new()
	body.name = "RemotePlayer_%d" % peer_id
	body.add_to_group("remote_player")
	body.collision_layer = 0
	body.collision_mask = 0
	body.set_meta("remote_peer_id", peer_id)
	var visual := Sprite2D.new()
	visual.name = "Visual"
	visual.texture = BrambleWorldPresentationConfig.game_tex("characters/base/male/directions/front.png")
	visual.scale = Vector2.ONE * BrambleWorldPresentationConfig.SCALE_PLAYER
	visual.position = Vector2(0, -58)
	body.add_child(visual)
	var tag := Label.new()
	tag.text = "P%d" % peer_id
	tag.position = Vector2(-16, -118)
	tag.add_theme_font_size_override("font_size", 11)
	tag.add_theme_color_override("font_color", Color("#9fd4ff"))
	body.add_child(tag)
	get_tree().current_scene.add_child(body)
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	if registry:
		registry.register(body, 2000 + peer_id)
	_avatars[peer_id] = body
	var e2e := get_tree().get_first_node_in_group("multiplayer_e2e_service")
	if e2e and e2e.has_method("log_remote_created"):
		e2e.log_remote_created(peer_id)
	return body

func _despawn(peer_id: int) -> void:
	if not _avatars.has(peer_id):
		return
	var node = _avatars[peer_id]
	if is_instance_valid(node):
		var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
		if registry:
			registry.unregister(node)
		node.queue_free()
	_avatars.erase(peer_id)
	var e2e := get_tree().get_first_node_in_group("multiplayer_e2e_service")
	if e2e and e2e.has_method("log_remote_removed"):
		e2e.log_remote_removed(peer_id)
