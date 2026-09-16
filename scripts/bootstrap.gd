extends Node2D

@export var debug_legacy_gallery := false

func _ready() -> void:
	print("BRAMBLE · Godot 4.7.2 · M02.2 Visual Production Pass")
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
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	if "--live-capture" in args:
		call_deferred("_capture_live", args)
	elif "--smoke-test" in args:
		call_deferred("_smoke_test")
	elif "--m02_2-capture" in args:
		call_deferred("_capture_m02_2", args)
	elif "--m02_1-capture" in args:
		call_deferred("_capture_m02_1")
	elif "--m02-capture" in args:
		call_deferred("_capture_shots", args)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		debug_legacy_gallery = not debug_legacy_gallery
		_ready()

func _smoke_test() -> void:
	await _wait_frames(4)
	var production := get_node_or_null("VisualMasterWorld") as Node2D
	if production == null or not production.visible:
		push_error("BRAMBLE smoke test failed: VisualMasterWorld missing or hidden")
		get_tree().quit(1)
		return
	print("BRAMBLE smoke test: PASS")
	get_tree().quit()

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
