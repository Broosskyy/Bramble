class_name BrambleMultiplayerE2EService
extends Node

const LOG_REL := "res://artifacts/m03_1/multiplayer_e2e.log"

var role := ""
var _remote_seen := false
var _snapshot_count := 0
var _peer_connected := false
var _active_remote_peers := 0
var _connection_events := 0
var _finished := false

func _ready() -> void:
	add_to_group("multiplayer_e2e_service")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts/m03_1/"))
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net:
		net.peer_joined.connect(_on_peer_joined)
		net.peer_left.connect(_on_peer_left)
		net.world_join_received.connect(_on_world_join)
	var sync := get_tree().get_first_node_in_group("network_world_sync")
	if sync and sync.has_signal("snapshot_sent"):
		pass

func configure(new_role: String) -> void:
	role = new_role
	log_line("configure role=%s local_peer=%d" % [role, multiplayer.get_unique_id()])

func log_line(text: String) -> void:
	var stamp := Time.get_datetime_string_from_system(true)
	var line := "[%s] %s" % [stamp, text]
	print("M03.1 E2E: ", text)
	var path := ProjectSettings.globalize_path(LOG_REL)
	var existing := ""
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			existing = f.get_as_text()
	var out := FileAccess.open(path, FileAccess.WRITE)
	if out:
		out.store_string(existing + line + "\n")

func note_snapshot(player_count: int, remote_count: int) -> void:
	_snapshot_count += 1
	if remote_count > 0:
		_remote_seen = true
	if _snapshot_count == 1 or _snapshot_count % 10 == 0:
		log_line("snapshot #%d players=%d remotes=%d" % [_snapshot_count, player_count, remote_count])

func _on_peer_joined(peer_id: int) -> void:
	if peer_id == multiplayer.get_unique_id():
		return
	if role == "client" and peer_id == 1:
		return
	_active_remote_peers += 1
	_connection_events += 1
	_peer_connected = true
	log_line("peer_connected id=%d active=%d event=%d" % [peer_id, _active_remote_peers, _connection_events])

func _on_peer_left(peer_id: int) -> void:
	_active_remote_peers = maxi(0, _active_remote_peers - 1)
	_peer_connected = _active_remote_peers > 0
	log_line("peer_left id=%d active=%d remotes=%d" % [
		peer_id,
		_active_remote_peers,
		get_tree().get_nodes_in_group("remote_player").size(),
	])
	var remote := get_tree().get_first_node_in_group("remote_player_service")
	if remote and remote.has_method("sync_players"):
		var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
		if pa:
			remote.sync_players(pa.snapshot(), multiplayer.get_unique_id())

func _on_world_join(state: Dictionary) -> void:
	log_line("world_join local=%d session=%s players=%d" % [
		multiplayer.get_unique_id(),
		String(state.get("session_id", "")),
		state.get("players", []).size(),
	])

func remote_avatar_count() -> int:
	var remote := get_tree().get_first_node_in_group("remote_player_service")
	if remote and remote.has_method("avatar_count"):
		return remote.avatar_count()
	return get_tree().get_nodes_in_group("remote_player").size()

func connection_events() -> int:
	return _connection_events

func active_remote_peers() -> int:
	return _active_remote_peers

func snapshot_count() -> int:
	return _snapshot_count

func has_remote_seen() -> bool:
	return _remote_seen

func log_remote_created(peer_id: int) -> void:
	log_line("remote_player_created peer=%d total=%d" % [peer_id, remote_avatar_count()])

func log_remote_removed(peer_id: int) -> void:
	log_line("remote_player_removed peer=%d total=%d" % [peer_id, remote_avatar_count()])

func mark_finished() -> void:
	_finished = true

func is_finished() -> bool:
	return _finished
