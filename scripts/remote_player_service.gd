class_name BrambleRemotePlayerService
extends Node

var _avatars: Dictionary = {}

func _ready() -> void:
	add_to_group("remote_player_service")

func sync_players(players: Array, local_peer_id: int) -> void:
	var seen: Dictionary = {}
	for raw in players:
		var s: Dictionary = raw
		var peer_id := int(s.get("peer_id", -1))
		if peer_id <= 0 or peer_id == local_peer_id:
			continue
		if not bool(s.get("connected", true)):
			_despawn(peer_id)
			continue
		seen[peer_id] = true
		var avatar := _ensure_avatar(peer_id)
		avatar.global_position = Vector2(float(s.get("x", 0.0)), float(s.get("y", 360.0)))
		var visual := avatar.get_node_or_null("Visual") as Sprite2D
		if visual:
			var dx := float(s.get("dir_x", 0.0))
			visual.flip_h = dx < 0.0
	for peer_id in _avatars.keys().duplicate():
		if not seen.has(peer_id):
			_despawn(peer_id)

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
