class_name BrambleNetworkEntityRegistry
extends Node

var next_id := 1000
var entities: Dictionary = {}

func _ready() -> void:
	add_to_group("network_entity_registry")
	call_deferred("scan_world")

func scan_world() -> void:
	for n in get_tree().get_nodes_in_group("player"):
		if n is Node and not n.has_meta("net_entity_id"):
			register(n, 1)
	for n in get_tree().get_nodes_in_group("enemy"):
		if n is Node and not n.has_meta("net_entity_id"):
			register(n)
	for n in get_tree().get_nodes_in_group("remote_player"):
		if n is Node and not n.has_meta("net_entity_id"):
			register(n, 2000 + int(n.get_meta("remote_peer_id", 0)))

func register(node: Node, forced_id := 0) -> int:
	if node.has_meta("net_entity_id"):
		return int(node.get_meta("net_entity_id"))
	var id := forced_id if forced_id > 0 else next_id
	next_id = maxi(next_id, id + 1)
	entities[id] = node
	node.set_meta("net_entity_id", id)
	return id

func unregister(node: Node) -> void:
	for id in entities.keys():
		if entities[id] == node:
			entities.erase(id)
			if node.has_meta("net_entity_id"):
				node.remove_meta("net_entity_id")
			break

func node_for_entity(id: int) -> Node:
	if entities.has(id):
		var node = entities[id]
		if is_instance_valid(node):
			return node
		entities.erase(id)
	return null

func entity_id_for(node: Node) -> int:
	if node != null and node.has_meta("net_entity_id"):
		return int(node.get_meta("net_entity_id"))
	for id in entities.keys():
		if entities[id] == node:
			return int(id)
	return 0

func enemy_snapshot() -> Array:
	var arr: Array = []
	for id in entities.keys():
		var n = entities[id]
		if is_instance_valid(n) and n.is_in_group("enemy"):
			var alive := true
			if n.has_method("is_combat_alive"):
				alive = n.is_combat_alive()
			arr.append({
				"entity_id": id,
				"enemy_id": String(n.get("enemy_id")),
				"x": n.global_position.x,
				"y": n.global_position.y,
				"hp": int(n.get("hp")),
				"max_hp": int(n.get("max_hp")),
				"alive": alive,
			})
	return arr

func player_snapshot() -> Array:
	var arr: Array = []
	for id in entities.keys():
		var n = entities[id]
		if is_instance_valid(n) and (n.is_in_group("player") or n.is_in_group("remote_player")):
			arr.append({
				"entity_id": id,
				"x": n.global_position.x,
				"y": n.global_position.y,
				"peer_id": int(n.get_meta("remote_peer_id", 1 if n.is_in_group("player") else 0)),
			})
	return arr
