extends Node2D

@export var debug_legacy_gallery := false

func _enter_tree() -> void:
	_ensure_m03_services()

func _cli_args() -> PackedStringArray:
	var merged: PackedStringArray = []
	for arg in OS.get_cmdline_args():
		if arg not in merged:
			merged.append(arg)
	for arg in OS.get_cmdline_user_args():
		if arg not in merged:
			merged.append(arg)
	return merged

func _has_arg(name: String) -> bool:
	return name in OS.get_cmdline_user_args() or name in OS.get_cmdline_args()

func _ready() -> void:
	print("BRAMBLE · Godot 4.7.2 · M03 Playable Combat Loop")
	var legacy := get_node_or_null("Village") as Node2D
	var production := get_node_or_null("VisualMasterWorld") as Node2D
	if legacy:
		legacy.visible = debug_legacy_gallery
		legacy.process_mode = Node.PROCESS_MODE_INHERIT if debug_legacy_gallery else Node.PROCESS_MODE_DISABLED
	if production:
		production.visible = not debug_legacy_gallery
	var player := get_node_or_null("Player") as Node2D
	if player and not debug_legacy_gallery:
		player.global_position = BrambleWorldPresentationConfig.PLAYER_SPAWN
	var dev_hud := get_node_or_null("HUD") as CanvasItem
	var prod_hud := get_node_or_null("ProductionHUD") as CanvasItem
	if dev_hud:
		dev_hud.visible = debug_legacy_gallery
	if prod_hud:
		prod_hud.visible = not debug_legacy_gallery
	var args := _cli_args()
	_handle_network_args(args)
	if _has_arg("--live-capture"):
		call_deferred("_capture_live", args)
	elif _has_arg("--smoke-test"):
		call_deferred("_smoke_test")
	elif _has_arg("--m03-capture"):
		call_deferred("_capture_m03", args)
	elif _has_arg("--m02_2-capture"):
		call_deferred("_capture_m02_2", args)
	elif _has_arg("--m02_1-capture"):
		call_deferred("_capture_m02_1")
	elif _has_arg("--m02-capture"):
		call_deferred("_capture_shots", args)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		debug_legacy_gallery = not debug_legacy_gallery
		_ready()

func _smoke_test() -> void:
	await _wait_frames(8)
	for _attempt in range(60):
		var production := get_node_or_null("VisualMasterWorld") as Node2D
		var enemies := get_tree().get_nodes_in_group("enemy")
		if production != null and production.visible and enemies.size() > 0:
			print("BRAMBLE smoke test: PASS")
			get_tree().quit()
			return
		await _wait_frames(5)
	push_error("BRAMBLE smoke test failed: production world or combat entities unavailable")
	get_tree().quit(1)

func _capture_live(args: PackedStringArray) -> void:
	await _wait_frames(3)
	_ensure_dir("res://artifacts/live/")
	get_window().size = Vector2i(1920, 1080)
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_live("latest_landscape.png")
	get_window().size = Vector2i(1080, 1920)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_live("latest_portrait.png")
	if "gameplay" in args:
		get_window().size = Vector2i(1920, 1080)
		if orient:
			orient._refresh()
		await _wait_frames(1)
		_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
		await _wait_frames(1.2)
		_shot_live("latest_gameplay.png")
	get_tree().quit()

func _shot_live(filename: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var rel := "res://artifacts/live/%s" % filename
	var path := ProjectSettings.globalize_path(rel)
	img.save_png(path)
	print("LIVE screenshot saved: ", path)

func _capture_m02_2(args: PackedStringArray) -> void:
	await _wait_frames(3)
	_ensure_dir("res://artifacts/m02_2/")
	get_window().size = Vector2i(1920, 1080)
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("landscape_village.png")
	_move_player(BrambleWorldPresentationConfig.WILDS_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("landscape_wilds.png")
	_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("landscape_combat.png")
	get_window().size = Vector2i(1080, 1920)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("portrait_village.png")
	_move_player(BrambleWorldPresentationConfig.WILDS_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("portrait_wilds.png")
	_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_2("portrait_combat.png")
	if "walk" in args:
		await _walk_qa_path()
	get_tree().quit()

func _walk_qa_path() -> void:
	get_window().size = Vector2i(1920, 1080)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	var path := [
		BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS,
		Vector2(120, 70),
		Vector2(380, 100),
		BrambleWorldPresentationConfig.WILDS_CAMERA_FOCUS,
		BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS
	]
	for point in path:
		_move_player(point)
		await get_tree().create_timer(0.35).timeout
		await RenderingServer.frame_post_draw

func _capture_m02_1() -> void:
	await _wait_frames(3)
	_ensure_dir("res://artifacts/m02_1/")
	get_window().size = Vector2i(1920, 1080)
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_1("landscape_village.png")
	_move_player(BrambleWorldPresentationConfig.WILDS_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_1("landscape_wilds.png")
	get_window().size = Vector2i(1080, 1920)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_1("portrait_village.png")
	_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
	await _wait_frames(1.2)
	_shot_m02_1("portrait_combat.png")
	get_tree().quit()

func _capture_shots(args: PackedStringArray) -> void:
	await _wait_frames(3)
	_shot("landscape_world.png")
	if "portrait" in args:
		get_window().size = Vector2i(1080, 1920)
		var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
		if orient:
			orient._refresh()
		await _wait_frames(2)
		_shot("portrait_world.png")
	get_tree().quit()

func _move_player(pos: Vector2) -> void:
	var player := get_node_or_null("Player") as Node2D
	if player:
		player.global_position = pos

func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	await RenderingServer.frame_post_draw

func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _ensure_dir(rel: String) -> void:
	var path := ProjectSettings.globalize_path(rel)
	DirAccess.make_dir_recursive_absolute(path)

func _shot(filename: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var rel := "res://artifacts/m02/%s" % filename
	var path := ProjectSettings.globalize_path(rel)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	img.save_png(path)
	print("M02 screenshot saved: ", path)

func _shot_m02_1(filename: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var rel := "res://artifacts/m02_1/%s" % filename
	var path := ProjectSettings.globalize_path(rel)
	img.save_png(path)
	print("M02.1 screenshot saved: ", path)

func _shot_m02_2(filename: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var rel := "res://artifacts/m02_2/%s" % filename
	var path := ProjectSettings.globalize_path(rel)
	img.save_png(path)
	print("M02.2 screenshot saved: ", path)

func _ensure_m03_services() -> void:
	_add_service_if_missing("combat_targeting_service", "res://scripts/combat_targeting_service.gd", "CombatTargetingService")
	_add_service_if_missing("combat_runtime_service", "res://scripts/combat_runtime_service.gd", "CombatRuntimeService")
	_add_service_if_missing("remote_player_service", "res://scripts/remote_player_service.gd", "RemotePlayerService")

func _add_service_if_missing(group: String, script_path: String, node_name: String) -> void:
	if get_tree().get_first_node_in_group(group):
		return
	var node: Node = load(script_path).new()
	node.name = node_name
	add_child(node)

func _handle_network_args(args: PackedStringArray) -> void:
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net == null:
		return
	if _has_arg("--host"):
		net.host()
	elif _has_arg("--join"):
		var all := _cli_args()
		var idx := all.find("--join")
		var address := "127.0.0.1"
		if idx >= 0 and idx + 1 < all.size():
			address = String(all[idx + 1])
		net.join(address)

func _capture_m03(args: PackedStringArray) -> void:
	await _wait_frames(40)
	_ensure_dir("res://artifacts/m03/")
	get_window().size = Vector2i(1920, 1080)
	await _wait_frames(2)
	await _m03_accept_quest()
	_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
	await _wait_seconds(1.0)
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	var player := get_node_or_null("Player") as BramblePlayerController
	var enemy := _nearest_enemy()
	if enemy and targeting:
		targeting.set_target(enemy)
	await _wait_seconds(1.0)
	_shot_m03("landscape_target.png")
	if player and runtime and enemy:
		runtime.resolve_basic_attack(player, targeting.get_target_entity_id() if targeting else 0)
	await _wait_seconds(0.8)
	_shot_m03("landscape_combat.png")
	if player and runtime and enemy and is_instance_valid(enemy):
		runtime.resolve_skill(player, 0, targeting.get_target_entity_id() if targeting else 0)
	await _wait_seconds(0.8)
	_shot_m03("landscape_skill.png")
	await _m03_kill_moorlings(3)
	await _wait_seconds(1.0)
	_shot_m03("landscape_loot.png")
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state and state.quest_stage >= 2:
		_move_player(Vector2(-40, 30))
		await _wait_seconds(1.0)
		_shot_m03("landscape_quest_complete.png")
	get_window().size = Vector2i(1080, 1920)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.COMBAT_CAMERA_FOCUS)
	enemy = _nearest_enemy()
	if enemy and targeting:
		targeting.set_target(enemy)
	await _wait_seconds(1.0)
	_shot_m03("portrait_combat.png")
	await _wait_seconds(0.5)
	_shot_m03("portrait_loot.png")
	if "multiplayer" in args or _has_arg("multiplayer"):
		await _m03_multiplayer_shot()
	get_tree().quit()

func _m03_accept_quest() -> void:
	_move_player(Vector2(-40, 30))
	await _wait_seconds(1.0)
	var player := get_node_or_null("Player") as BramblePlayerController
	if player:
		player.interact()

func _m03_kill_moorlings(count: int) -> void:
	var player := get_node_or_null("Player") as Node2D
	var killed := 0
	for pass_i in range(4):
		for node in get_tree().get_nodes_in_group("enemy"):
			if killed >= count:
				return
			if not (node is Node2D and node.has_method("is_combat_alive") and node.is_combat_alive()):
				continue
			_move_player(node.global_position + Vector2(-60, 0))
			await _wait_frames(10)
			var hits := 0
			while node.has_method("is_combat_alive") and node.is_combat_alive() and hits < 12:
				if node.has_method("take_damage"):
					node.take_damage(30, player)
				hits += 1
				await _wait_frames(5)
			killed += 1
		if killed >= count:
			return
		await get_tree().create_timer(1.0).timeout

func _m03_multiplayer_shot() -> void:
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode == "offline":
		net.host()
	await get_tree().create_timer(1.5).timeout
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa:
		var host_id := multiplayer.get_unique_id()
		var guest := pa.ensure_peer(host_id + 1, {
			"x": BrambleWorldPresentationConfig.PLAYER_SPAWN.x + 80.0,
			"y": BrambleWorldPresentationConfig.PLAYER_SPAWN.y,
			"connected": true,
		})
		guest["x"] = BrambleWorldPresentationConfig.PLAYER_SPAWN.x + 80.0
		guest["y"] = BrambleWorldPresentationConfig.PLAYER_SPAWN.y
	var remote = get_tree().get_first_node_in_group("remote_player_service")
	if remote and pa:
		remote.sync_players(pa.snapshot(), multiplayer.get_unique_id())
	get_window().size = Vector2i(1920, 1080)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient._refresh()
	await _wait_frames(2)
	_move_player(BrambleWorldPresentationConfig.VILLAGE_CAMERA_FOCUS)
	await _wait_seconds(1.0)
	_shot_m03("multiplayer_two_players.png")

func _nearest_enemy() -> Node2D:
	var player := get_node_or_null("Player") as Node2D
	var best: Node2D = null
	var best_dist := 99999.0
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D and node.has_method("is_combat_alive") and node.is_combat_alive():
			var d := player.global_position.distance_to(node.global_position) if player else 0.0
			if d < best_dist:
				best = node
				best_dist = d
	return best

func _shot_m03(filename: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var rel := "res://artifacts/m03/%s" % filename
	var path := ProjectSettings.globalize_path(rel)
	img.save_png(path)
	print("M03 screenshot saved: ", path)
