extends Node3D

const Presenter = preload("res://scripts/spatial/spatial_entity_presenter.gd")
const GAME := "res://assets/game/"
const OUTPUT := "res://artifacts/m04_30"
const PROFILE_PATH := "res://data/spatial/m04_30_entity_profiles.json"
const CAMERA_CENTER := 35.0
const CAMERA_MIN := -10.0
const CAMERA_MAX := 80.0
const PLAYER_SPAWN := Vector3(0.0, 0.8, 11.0)
const HALL_POS := Vector3(-6.4, 0.0, -4.5)
const OAK_POS := Vector3(7.3, 0.0, 0.0)
const NPC_POS := Vector3(-2.5, 0.0, -1.4)
const WAYSTONE_POS := Vector3(3.8, 0.0, -5.5)
const MOORLING_SPAWNS := [
	Vector3(4.8, 0.0, 5.8), Vector3(7.0, 0.0, 7.2), Vector3(7.8, 0.0, 4.1),
]

var profiles: Dictionary
var player: CharacterBody3D
var player_visual: SpatialEntityPresenter
var camera: Camera3D
var camera_yaw := deg_to_rad(CAMERA_CENTER)
var camera_pitch := deg_to_rad(40.0)
var camera_zoom := 14.0
var facing := Vector3(0.0, 0.0, -1.0)
var player_state := "idle"
var state_time := 0.0
var attack_phase := -1.0
var capture_mode := false
var dragging := false
var selected := 0
var target_active := false
var moorlings: Array[Dictionary] = []
var loot_nodes: Array[Node3D] = []
var roof_parts: Array[MeshInstance3D] = []
var canopy_sprites: Array[Sprite3D] = []
var hud_status: Label
var hud_objective: Label
var prompt: Label
var dialogue: PanelContainer
var toast: Label
var target_panel: PanelContainer
var target_label: Label
var slash_vfx: Sprite3D
var damage_label: Label3D
var xp := 82
var level := 3
var upgraded := false
var equipment_state_id := "starter_clothes"
var equipment_stats := {"attack": 8, "defense": 3}
var interaction_done := false
var force_roof_fade_capture := false
var _material_cache := {}
var _fps: Array[float] = []
var _draws: Array[int] = []
var _frame_ms: Array[float] = []
var _measured_fps := 0.0
var _toast_tween: Tween


func _ready() -> void:
	profiles = _load_profiles()
	_build_environment()
	_build_area()
	_build_player()
	_build_entities()
	_build_camera()
	_build_hud()
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	if "--m04_30-capture" in args:
		capture_mode = true
		call_deferred("_capture_and_quit")
	elif "--m04_30-profile" in args:
		capture_mode = true
		call_deferred("_profile_and_quit")
	elif "--m04_30-smoke" in args:
		capture_mode = true
		call_deferred("_smoke_and_quit")


func _process(delta: float) -> void:
	state_time = fmod(state_time + delta, 1.0)
	if not capture_mode:
		_update_player(delta)
		_update_combat(delta)
	_update_presenters()
	_update_camera()
	_update_occlusion(delta)
	_update_hud()
	_fps.append(Performance.get_monitor(Performance.TIME_FPS))
	_draws.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	_frame_ms.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	if _fps.size() > 600:
		_fps.pop_front()
		_draws.pop_front()
		_frame_ms.pop_front()


func _unhandled_input(event: InputEvent) -> void:
	if capture_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_zoom = clampf(camera_zoom - 0.8, 10.0, 18.0)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_zoom = clampf(camera_zoom + 0.8, 10.0, 18.0)
	elif event is InputEventMouseMotion and dragging:
		camera_yaw = clampf(camera_yaw - event.relative.x * 0.007, deg_to_rad(CAMERA_MIN), deg_to_rad(CAMERA_MAX))
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.004, deg_to_rad(34.0), deg_to_rad(48.0))
	elif event is InputEventScreenDrag and _safe_world_drag(event.position):
		camera_yaw = clampf(camera_yaw - event.relative.x * 0.006, deg_to_rad(CAMERA_MIN), deg_to_rad(CAMERA_MAX))
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, deg_to_rad(34.0), deg_to_rad(48.0))
	elif event is InputEventMagnifyGesture:
		camera_zoom = clampf(camera_zoom / event.factor, 10.0, 18.0)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			_select_next_target()
		elif event.keycode == KEY_SPACE:
			_begin_attack()
		elif event.keycode == KEY_E:
			_interact()


func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#91c7ce")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff0cd")
	env.ambient_light_energy = 0.56
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54.0, -38.0, 0.0)
	sun.light_color = Color("#ffe2a7")
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 38.0
	add_child(sun)


func _build_area() -> void:
	# Overscan terrain keeps every supported yaw/zoom/aspect capture inside world.
	_plane(Vector3.ZERO, Vector2(86.0, 74.0), GAME + "world/terrain/materials/grass_repeat_256.png", Color("#88a95c"), Vector2(19.0, 17.0))
	_add_ground_collision()
	_path(Vector3(0.0, 0.03, 2.0), Vector2(3.4, 25.0), 0.0)
	_path(Vector3(-3.5, 0.04, -2.8), Vector2(8.0, 3.1), -8.0)
	_path(Vector3(4.4, 0.05, 5.7), Vector2(9.0, 4.8), 7.0)
	_path(Vector3(2.5, 0.06, -6.2), Vector2(7.0, 4.2), 0.0)
	_build_hall()
	_build_waystone()
	_add_world_sprite(GAME + "world/buildings/red_oak.png", OAK_POS + Vector3.UP * 2.9, 0.0112, "AmberOakCanopy", true)
	canopy_sprites.append(get_child(get_child_count() - 1) as Sprite3D)
	_add_static_cylinder(OAK_POS + Vector3.UP * 1.3, 0.75, 2.6)
	for item in [
		[GAME + "world/buildings/cottage_complete.png", Vector3(9.8, 1.9, -8.0), 0.009],
		[GAME + "world/buildings/stream_bridge.png", Vector3(-0.5, 0.9, -10.5), 0.008],
		[GAME + "world/buildings/ruined_arch.png", Vector3(10.5, 1.7, 9.4), 0.008],
		[GAME + "world/buildings/town_fountain.png", Vector3(-8.8, 1.15, 5.6), 0.007],
		[GAME + "world/buildings/produce_cart.png", Vector3(-7.4, 0.85, 2.5), 0.0065],
		[GAME + "world/buildings/bench_crates.png", Vector3(-4.7, 0.7, 2.2), 0.006],
		[GAME + "world/buildings/lantern_post.png", Vector3(2.0, 1.4, 1.0), 0.0065],
		[GAME + "world/buildings/lantern_post.png", Vector3(2.0, 1.4, -7.7), 0.0065],
	]:
		_add_world_sprite(item[0], item[1], item[2], "AuthoredWorldProp", true)
	for pos in [
		Vector3(-10.2, 0.72, -5.0), Vector3(-10.0, 0.72, 1.0), Vector3(10.6, 0.72, -2.5),
		Vector3(10.0, 0.72, 2.3), Vector3(-8.5, 0.72, 9.5), Vector3(8.8, 0.72, 11.0),
	]:
		_add_world_sprite(GAME + "world/buildings/golden_shrubs.png", pos, 0.0072, "GoldenShrub", true)
	for pos in [Vector3(-3.1, 0.48, 4.2), Vector3(2.8, 0.48, 2.2), Vector3(-1.9, 0.48, -6.0), Vector3(5.1, 0.48, -4.2)]:
		_add_world_sprite(GAME + "world/terrain/overlays/overlay_grass_clumps_256.png", pos, 0.007, "GrassComposition", true)
	for z in [-8.0, -5.5, -3.0, -0.5, 2.0, 4.5, 7.0, 9.5]:
		_add_world_sprite(GAME + "world/buildings/fence_straight.png", Vector3(-12.0, 0.65, z), 0.005, "BoundaryFence", true)


func _build_hall() -> void:
	var host := Node3D.new()
	host.name = "WayfarerHallMeaningfulBuilding"
	host.position = HALL_POS
	add_child(host)
	_box(host, Vector3(6.2, 0.55, 5.1), Vector3(0.0, 0.28, 0.0), Color("#685a48"))
	_box(host, Vector3(5.5, 3.3, 4.5), Vector3(0.0, 1.95, 0.0), Color("#e5c482"))
	for x in [-2.55, 0.0, 2.55]:
		_box(host, Vector3(0.18, 3.25, 0.2), Vector3(x, 2.0, 2.31), Color("#6b4025"))
		_box(host, Vector3(0.18, 3.25, 0.2), Vector3(x, 2.0, -2.31), Color("#6b4025"))
	for z in [-2.05, 0.0, 2.05]:
		_box(host, Vector3(0.2, 3.25, 0.18), Vector3(-2.82, 2.0, z), Color("#6b4025"))
		_box(host, Vector3(0.2, 3.25, 0.18), Vector3(2.82, 2.0, z), Color("#6b4025"))
	_box(host, Vector3(1.18, 2.2, 0.24), Vector3(0.0, 1.4, 2.35), Color("#71432a"))
	# Porch, eaves, side braces and inset windows make the volume readable at all supported yaws.
	_box(host, Vector3(3.4, 0.18, 1.25), Vector3(0.0, 0.62, 2.85), Color("#98643a"))
	for x in [-1.5, 1.5]:
		_box(host, Vector3(0.16, 2.25, 0.16), Vector3(x, 1.72, 2.88), Color("#684027"))
		_box(host, Vector3(1.5, 0.14, 0.14), Vector3(x * 0.52, 2.72, 2.5), Color("#d6a04b"), Vector3(0, 0, deg_to_rad(x * 8.0)))
	for x in [-1.78, 1.78]:
		_add_hall_window(host, Vector3(x, 2.15, 2.34), false)
	for z in [-1.25, 1.25]:
		_add_hall_window(host, Vector3(2.81, 2.15, z), true)
		_add_hall_window(host, Vector3(-2.81, 2.15, z), true)
	var roof_mat := _material(Color("#23575a"), false)
	roof_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for side in [-1.0, 1.0]:
		var roof := _box(host, Vector3(3.8, 0.3, 5.35), Vector3(side * 1.55, 4.3, 0.0), Color.WHITE, Vector3(0.0, 0.0, deg_to_rad(-side * 31.0)))
		roof.material_override = roof_mat.duplicate()
		roof_parts.append(roof)
		for row in range(5):
			_box(host, Vector3(0.055, 0.065, 5.4), Vector3(side * (0.58 + row * 0.58), 5.02 - row * 0.36, 0.0), Color("#174244"))
	_box(host, Vector3(0.25, 0.25, 5.6), Vector3(0.0, 5.25, 0.0), Color("#d6a04b"))
	_box(host, Vector3(0.86, 1.85, 0.86), Vector3(-1.65, 4.88, -0.55), Color("#89745a"))
	_box(host, Vector3(1.05, 0.2, 1.05), Vector3(-1.65, 5.82, -0.55), Color("#554940"))
	for x in [-2.98, 2.98]:
		_box(host, Vector3(0.18, 0.2, 5.45), Vector3(x, 3.34, 0.0), Color("#d6a04b"))
	_add_static_box(HALL_POS + Vector3.UP * 1.85, Vector3(5.9, 3.7, 4.9))


func _build_waystone() -> void:
	var host := Node3D.new()
	host.name = "BrambleWaystoneLandmark"
	host.position = WAYSTONE_POS
	add_child(host)
	_box(host, Vector3(5.0, 0.32, 3.6), Vector3(0.0, 0.16, 0.0), Color("#68625a"))
	for x in [-1.45, 1.45]:
		_box(host, Vector3(0.76, 3.9, 0.76), Vector3(x, 2.25, 0.0), Color("#777168"))
	_box(host, Vector3(3.8, 0.7, 0.8), Vector3(0.0, 4.25, 0.0), Color("#777168"))
	var crystal := _sphere(host, Vector3(0.0, 2.45, 0.0), Vector3(0.72, 1.45, 0.46), Color("#5be4d2"))
	var mat := crystal.material_override as StandardMaterial3D
	mat.emission_enabled = true
	mat.emission = Color("#5be4d2")
	mat.emission_energy_multiplier = 1.5


func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "PlayableWayfarer"
	player.position = PLAYER_SPAWN
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.5
	collision.shape = capsule
	player.add_child(collision)
	add_child(player)
	_contact_shadow(player, 0.5, -0.76)
	player_visual = Presenter.new()
	player_visual.configure(profiles.wayfarer)
	player.add_child(player_visual)
	_apply_equipment_state("starter_clothes")


func _build_entities() -> void:
	for index in range(MOORLING_SPAWNS.size()):
		var host := Node3D.new()
		host.name = "Moorling_%d" % (index + 1)
		host.position = MOORLING_SPAWNS[index]
		add_child(host)
		_contact_shadow(host, 0.55, 0.02)
		var visual: SpatialEntityPresenter = Presenter.new()
		visual.configure(profiles.moorling)
		host.add_child(visual)
		var ring := _target_ring()
		host.add_child(ring)
		moorlings.append({
			"host": host, "visual": visual, "ring": ring, "hp": 24,
			"state": "move", "time": float(index) * 0.23, "defeated": false,
			"origin": MOORLING_SPAWNS[index], "loot": null,
		})
	var npc := _add_world_sprite(GAME + "npcs/merchant/directions/front.png", NPC_POS + Vector3.UP * 1.2, 0.0054, "LinaWayfinderNPC", true)
	_add_static_cylinder(NPC_POS + Vector3.UP * 0.75, 0.42, 1.5)
	_contact_shadow_at(NPC_POS, 0.46)
	npc.set_meta("companion_interface", {"slot_id": "npc_wayfinder", "body_replacement_compatible": true})
	slash_vfx = _add_world_sprite(GAME + "combat/vfx/melee_slash_sequence/frames/03_slash_peak.png", Vector3.ZERO, 0.0048, "AuthoredSlashImpactVFX", true)
	slash_vfx.render_priority = 8
	slash_vfx.visible = false
	damage_label = Label3D.new()
	damage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	damage_label.font_size = 42
	damage_label.pixel_size = 0.006
	damage_label.modulate = Color("#fff0a0")
	damage_label.outline_size = 9
	damage_label.visible = false
	add_child(damage_label)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "LocalOnlyConstrainedCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.2
	camera.far = 80.0
	camera.current = true
	add_child(camera)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "RestrainedMobileSafeHUD"
	add_child(layer)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.06, 0.055, 0.84)
	style.border_color = Color(0.83, 0.64, 0.29, 0.8)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10.0)
	var status_panel := PanelContainer.new()
	status_panel.position = Vector2(16.0, 14.0)
	status_panel.custom_minimum_size = Vector2(305.0, 54.0)
	status_panel.add_theme_stylebox_override("panel", style)
	layer.add_child(status_panel)
	hud_status = Label.new()
	hud_status.add_theme_font_size_override("font_size", 13)
	hud_status.add_theme_color_override("font_color", Color("#fff0bd"))
	status_panel.add_child(hud_status)
	var quest_panel := PanelContainer.new()
	quest_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	quest_panel.position = Vector2(-252.0, 14.0)
	quest_panel.custom_minimum_size = Vector2(236.0, 54.0)
	quest_panel.add_theme_stylebox_override("panel", style)
	layer.add_child(quest_panel)
	hud_objective = Label.new()
	hud_objective.add_theme_color_override("font_color", Color("#fff0bd"))
	hud_objective.add_theme_font_size_override("font_size", 13)
	quest_panel.add_child(hud_objective)
	target_panel = PanelContainer.new()
	target_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	target_panel.position = Vector2(-252.0, 78.0)
	target_panel.custom_minimum_size = Vector2(236.0, 45.0)
	target_panel.add_theme_stylebox_override("panel", style.duplicate())
	target_panel.visible = false
	layer.add_child(target_panel)
	target_label = Label.new()
	target_label.add_theme_font_size_override("font_size", 13)
	target_label.add_theme_color_override("font_color", Color("#ffd69b"))
	target_panel.add_child(target_label)
	prompt = Label.new()
	prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.position = Vector2(-105.0, -72.0)
	prompt.add_theme_font_size_override("font_size", 16)
	prompt.add_theme_color_override("font_color", Color("#ffe49a"))
	layer.add_child(prompt)
	dialogue = PanelContainer.new()
	dialogue.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialogue.position = Vector2(-210.0, -225.0)
	dialogue.custom_minimum_size = Vector2(420.0, 112.0)
	dialogue.add_theme_stylebox_override("panel", style.duplicate())
	dialogue.visible = false
	layer.add_child(dialogue)
	var dialogue_text := Label.new()
	dialogue_text.text = "LINA · WAYFINDER\nClear the Moorlings from the old oak.\nTheir leaf motes will awaken the waystone."
	dialogue_text.add_theme_color_override("font_color", Color("#fff0bd"))
	dialogue_text.add_theme_font_size_override("font_size", 15)
	dialogue.add_child(dialogue_text)
	toast = Label.new()
	toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast.position = Vector2(-170.0, 18.0)
	toast.add_theme_font_size_override("font_size", 18)
	toast.add_theme_color_override("font_color", Color("#fff1a8"))
	toast.visible = false
	layer.add_child(toast)
	var action_panel := PanelContainer.new()
	action_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_panel.position = Vector2(-390.0, -62.0)
	action_panel.custom_minimum_size = Vector2(374.0, 46.0)
	action_panel.add_theme_stylebox_override("panel", style.duplicate())
	layer.add_child(action_panel)
	var controls := Label.new()
	controls.text = "Q  TARGET     SPACE  STRIKE     E  INTERACT"
	controls.add_theme_color_override("font_color", Color("#fff0c8"))
	action_panel.add_child(controls)


func _update_player(_delta: float) -> void:
	if attack_phase >= 0.0:
		player.velocity = Vector3.ZERO
		return
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length_squared() < 0.01:
		player.velocity = Vector3.ZERO
		player_state = "idle"
		return
	var forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw)).normalized()
	var right := Vector3(forward.z, 0.0, -forward.x)
	var movement := (right * input.x + forward * -input.y).normalized()
	player.velocity = movement * 4.0
	player.move_and_slide()
	player.position.x = clampf(player.position.x, -11.2, 11.2)
	player.position.z = clampf(player.position.z, -11.5, 12.0)
	facing = movement
	player_state = "move"
	_pickup_nearby_loot()


func _update_combat(delta: float) -> void:
	if attack_phase < 0.0:
		return
	attack_phase += delta / 0.72
	if attack_phase >= 0.32 and attack_phase - delta / 0.72 < 0.32:
		_apply_attack_impact()
	if attack_phase >= 1.0:
		attack_phase = -1.0
		player_state = "idle"


func _begin_attack() -> void:
	if attack_phase >= 0.0:
		return
	if not target_active:
		target_active = true
		moorlings[selected].ring.visible = true
	if moorlings.is_empty() or bool(moorlings[selected].defeated):
		_select_next_target()
	var target: Dictionary = moorlings[selected]
	if bool(target.defeated):
		_show_toast("CLEARING SECURED · COLLECT LEAF MOTES")
		return
	var offset: Vector3 = target.host.global_position - player.global_position
	offset.y = 0.0
	if offset.length() > 3.2:
		_show_toast("TARGET OUT OF RANGE")
		return
	facing = offset.normalized()
	attack_phase = 0.0
	player_state = "attack"


func _apply_attack_impact() -> void:
	var target: Dictionary = moorlings[selected]
	if bool(target.defeated):
		return
	var damage := int(equipment_stats.attack)
	target.hp = maxi(0, int(target.hp) - damage)
	target.state = "hit"
	target.time = 0.0
	slash_vfx.global_position = target.host.global_position + Vector3(0.0, 1.2, 0.0)
	slash_vfx.visible = true
	damage_label.text = "-%d" % damage
	damage_label.global_position = target.host.global_position + Vector3(0.0, 2.55, 0.0)
	damage_label.visible = true
	_show_toast("%d  HIT!" % damage)
	var feedback := create_tween()
	feedback.tween_interval(0.28)
	feedback.tween_callback(func() -> void:
		slash_vfx.visible = false
		damage_label.visible = false
	)
	if int(target.hp) == 0:
		target.defeated = true
		target.state = "defeated"
		# Hold the authored final Kit71 cel instead of leaving the creature on
		# the first rolling reaction frame.
		target.time = 1.0
		target.ring.visible = false
		_spawn_loot(target)


func _spawn_loot(target: Dictionary) -> void:
	var loot := Node3D.new()
	loot.name = "LeafMoteLoot"
	loot.position = target.host.position + Vector3(0.5, 0.0, 0.2)
	add_child(loot)
	var mote := _sphere(loot, Vector3.UP * 0.55, Vector3.ONE * 0.36, Color("#77efd1"))
	var mat := mote.material_override as StandardMaterial3D
	mat.emission_enabled = true
	mat.emission = Color("#77efd1")
	mat.emission_energy_multiplier = 1.7
	var loot_label := Label3D.new()
	loot_label.text = "LEAF MOTE"
	loot_label.position = Vector3.UP * 1.05
	loot_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	loot_label.font_size = 26
	loot_label.pixel_size = 0.0045
	loot_label.modulate = Color("#c8fff0")
	loot_label.outline_size = 7
	loot.add_child(loot_label)
	_contact_shadow(loot, 0.25, 0.03)
	loot_nodes.append(loot)
	target.loot = loot
	_show_toast("MOORLING DEFEATED · LEAF MOTE DROPPED")


func _pickup_nearby_loot() -> void:
	for loot in loot_nodes.duplicate():
		if is_instance_valid(loot) and player.global_position.distance_to(loot.global_position) < 1.25:
			loot_nodes.erase(loot)
			loot.queue_free()
			xp += 18
			if xp >= 100 and level == 3:
				level = 4
				xp -= 100
				upgraded = true
				_apply_equipment_state("wayfarer_set")
				_show_toast("LEVEL 4 · WAYFARER BLADE UPGRADED")
			else:
				_show_toast("+18 XP · LEAF MOTE SECURED")


func _select_next_target() -> void:
	target_active = true
	for step in range(1, moorlings.size() + 1):
		var candidate := posmod(selected + step, moorlings.size())
		if not bool(moorlings[candidate].defeated):
			selected = candidate
			break
	for index in range(moorlings.size()):
		moorlings[index].ring.visible = index == selected and not bool(moorlings[index].defeated)


func _interact() -> void:
	if player.global_position.distance_to(NPC_POS) < 2.7:
		interaction_done = true
		dialogue.visible = not dialogue.visible
		_show_toast("QUEST UPDATED · CLEAR THE OLD OAK")
	elif player.global_position.distance_to(HALL_POS) < 4.4 and level >= 4:
		upgraded = true
		_apply_equipment_state("wayfarer_set")
		_show_toast("EQUIPMENT UPGRADED · BRAMBLE EDGE +1")


func _apply_equipment_state(state_id: String) -> void:
	var loadouts: Dictionary = profiles.wayfarer.get("equipment_loadouts", {})
	assert(loadouts.has(state_id), "Unknown equipment state: %s" % state_id)
	equipment_state_id = state_id
	var loadout: Dictionary = loadouts[state_id]
	equipment_stats = loadout.get("stats", {}).duplicate()
	player_visual.set_equipment_state(state_id, loadout.get("visibility", {}))
	upgraded = state_id == "wayfarer_set"


func _equipment_visibility() -> Dictionary:
	var loadouts: Dictionary = profiles.wayfarer.get("equipment_loadouts", {})
	return loadouts.get(equipment_state_id, {}).get("visibility", {}).duplicate()


func _update_presenters() -> void:
	var player_snapshot := {
		"world_facing": facing, "state": player_state,
		"normalized_time": attack_phase if attack_phase >= 0.0 else state_time,
		"moving": player_state == "move", "body_replacement_id": "",
		"companion_slot_id": "player", "equipment_state_id": equipment_state_id,
		"equipment_visibility": _equipment_visibility(),
	}
	player_visual.consume_world_snapshot(player_snapshot)
	player_visual.set_local_camera_yaw(camera_yaw)
	for index in range(moorlings.size()):
		var data: Dictionary = moorlings[index]
		if data.state == "hit":
			data.time = minf(1.0, float(data.time) + get_process_delta_time() * 3.2)
			if float(data.time) >= 1.0:
				data.state = "idle"
				data.time = 0.0
		elif data.state in ["idle", "move"]:
			data.state = "move"
			data.time = fmod(float(data.time) + get_process_delta_time() * 0.65, 1.0)
			var orbit := Vector3(sin(float(data.time) * TAU + index), 0.0, cos(float(data.time) * TAU + index))
			data.host.position = Vector3(data.origin) + orbit * 0.18
		var to_player: Vector3 = player.global_position - data.host.global_position
		to_player.y = 0.0
		data.visual.consume_world_snapshot({
			"world_facing": to_player.normalized(),
			"state": data.state,
			"normalized_time": data.time,
			"moving": data.state == "move",
			"body_replacement_id": "",
			"companion_slot_id": "hostile",
		})
		data.visual.set_local_camera_yaw(camera_yaw)


func _update_camera() -> void:
	if camera == null:
		return
	var portrait := get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x
	camera.size = camera_zoom * (1.22 if portrait else 1.0)
	var distance := 18.0
	var horizontal := cos(camera_pitch) * distance
	var offset := Vector3(sin(camera_yaw) * horizontal, sin(camera_pitch) * distance, cos(camera_yaw) * horizontal)
	var focus := player.global_position + Vector3(0.0, 1.05, -0.7 if portrait else -0.2)
	camera.global_position = focus + offset
	camera.look_at(focus, Vector3.UP)


func _update_occlusion(delta: float) -> void:
	var tree_alpha := 0.34 if _covers_player(OAK_POS, 1.8) else 1.0
	for sprite in canopy_sprites:
		var color := sprite.modulate
		color.a = tree_alpha if capture_mode else move_toward(color.a, tree_alpha, delta * 3.5)
		sprite.modulate = color
	var roof_alpha := 0.38 if force_roof_fade_capture or _covers_player(HALL_POS, 3.2) else 1.0
	for roof in roof_parts:
		var mat := roof.material_override as StandardMaterial3D
		var color := mat.albedo_color
		color.a = roof_alpha if capture_mode else move_toward(color.a, roof_alpha, delta * 3.5)
		mat.albedo_color = color


func _covers_player(point: Vector3, radius: float) -> bool:
	var a := Vector2(camera.global_position.x, camera.global_position.z)
	var b := Vector2(player.global_position.x, player.global_position.z)
	var p := Vector2(point.x, point.z)
	var segment := b - a
	var t := clampf((p - a).dot(segment) / maxf(segment.length_squared(), 0.001), 0.0, 1.0)
	return t > 0.12 and t < 0.96 and p.distance_to(a + segment * t) < radius


func _update_hud() -> void:
	if hud_status == null:
		return
	var portrait := get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x
	hud_status.text = "LV %d  ·  XP %d/100  ·  %s  ·  %s  ·  CAMERA %+d°" % [
		level, xp, "WAYFARER SET · ATK %d" % int(equipment_stats.attack) if upgraded else "STARTER · ATK %d" % int(equipment_stats.attack),
		"PORTRAIT" if portrait else "LANDSCAPE",
		int(round(rad_to_deg(camera_yaw) - CAMERA_CENTER)),
	]
	var alive := 0
	for data in moorlings:
		if not bool(data.defeated):
			alive += 1
	hud_objective.text = "THE OLD OAK\n%s" % ("Return to Wayfarer Hall" if alive == 0 else "Clear Moorlings · %d remaining" % alive)
	var target: Dictionary = moorlings[selected]
	target_panel.visible = target_active and not bool(target.defeated)
	target_label.text = "MOORLING  ·  LV 3\nHP %d / 24" % int(target.hp)
	var near_npc := player.global_position.distance_to(NPC_POS) < 2.7
	prompt.visible = near_npc or player.global_position.distance_to(HALL_POS) < 4.4
	prompt.text = "[ E ]  Talk to Lina" if near_npc else "[ E ]  Upgrade equipment"


func _show_toast(text: String) -> void:
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	toast.text = text
	toast.visible = true
	toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.25)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.45)
	_toast_tween.tween_callback(func() -> void: toast.visible = false)


func authoritative_snapshot() -> Dictionary:
	return {
		"player_position": [player.position.x, player.position.y, player.position.z],
		"world_facing": [facing.x, facing.y, facing.z],
		"state": player_state,
		"normalized_time": attack_phase if attack_phase >= 0.0 else state_time,
		"target_index": selected,
		"xp": xp,
		"level": level,
		"equipment_state_id": equipment_state_id,
		"equipment_stats": equipment_stats.duplicate(),
		"equipment_visibility": _equipment_visibility(),
		"moorling_hp": moorlings.map(func(item: Dictionary) -> int: return int(item.hp)),
		"body_replacement_id": "",
		"companion_slots": ["player", "npc_wayfinder", "hostile"],
	}


func _load_profiles() -> Dictionary:
	var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	assert(file != null, "M04.30 profile catalog missing")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary and parsed.has("profiles"), "M04.30 profile catalog invalid")
	return parsed.profiles


func _smoke_and_quit() -> void:
	await _wait_frames(8)
	var snapshot := authoritative_snapshot()
	assert(not snapshot.has("camera_yaw"), "Camera yaw leaked into authoritative snapshot")
	assert(not snapshot.has("camera_pitch"), "Camera pitch leaked into authoritative snapshot")
	assert(moorlings.size() == 3, "Expected multiple Moorlings")
	assert(player_visual.get_resolved_direction() != "", "Player presenter did not resolve")
	assert(player_visual.equipment_sprites.size() == 3, "Equipment layers missing")
	assert(snapshot.equipment_state_id == "starter_clothes")
	assert(int(snapshot.equipment_stats.attack) == 8)
	assert(player_visual.get_visible_equipment_count() == 0)
	_apply_equipment_state("wayfarer_set")
	assert(equipment_state_id == "wayfarer_set" and int(equipment_stats.attack) == 14)
	assert(player_visual.get_visible_equipment_count() == 3)
	_apply_equipment_state("starter_clothes")
	assert(moorlings[0].state == "move", "Spatially moving Moorling must report move")
	var fallback_probe := player_visual.resolver_probe("missing_state", Vector3.RIGHT, 0.0)
	assert(fallback_probe.state == "idle" and fallback_probe.direction == "right")
	var mirror_profile := {
		"id": "ResolverSmoke", "direction_mode": Presenter.DirectionMode.FOUR_DIRECTION,
		"fallback_state": "idle", "states": {"idle": {
			"directional_frames": {"right": GAME + "monsters/moorling/directions/kit60_right.png"},
			"mirror_explicit": {"left": "right"}, "authored_generic": GAME + "monsters/moorling/directions/kit60_front.png",
		}},
	}
	var resolver := Presenter.new()
	resolver.configure(mirror_profile)
	add_child(resolver)
	assert(bool(resolver.resolver_probe("idle", Vector3.LEFT, 0.0).flip_h))
	assert(not bool(resolver.resolver_probe("idle", Vector3.RIGHT, 0.0).flip_h), "Exact resolve must reset flip")
	var previous_target := selected
	_select_next_target()
	assert(selected != previous_target, "Target selection did not advance")
	var smoke_loot := Node3D.new()
	smoke_loot.position = player.position
	add_child(smoke_loot)
	loot_nodes.append(smoke_loot)
	xp = 82
	level = 3
	_pickup_nearby_loot()
	assert(level == 4 and xp == 0 and equipment_state_id == "wayfarer_set")
	assert(rad_to_deg(camera_yaw) >= CAMERA_MIN and rad_to_deg(camera_yaw) <= CAMERA_MAX)
	print("M04.30_SMOKE PASS camera_independent=true equipment=starter_clothes->wayfarer_set stats=8->14 visible_layers=0->3 moorling_move=true resolver=true target=true loot_xp_level=true nodes=", get_tree().get_node_count())
	get_tree().quit()


func _profile_and_quit() -> void:
	await _set_viewport(Vector2i(1280, 720))
	await _wait_frames(120)
	_fps.clear()
	_draws.clear()
	_frame_ms.clear()
	var started := Time.get_ticks_usec()
	await _wait_frames(600)
	var elapsed_seconds := maxf(float(Time.get_ticks_usec() - started) / 1000000.0, 0.001)
	_measured_fps = 600.0 / elapsed_seconds
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	_write_profile()
	print("M04.30_PROFILE PASS")
	get_tree().quit()


func _capture_and_quit() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	_reset_demo_state()
	await _set_viewport(Vector2i(1280, 720))
	await _stage(PLAYER_SPAWN, CAMERA_CENTER, 16.5, Vector3(0, 0, -1), "idle")
	await _shot("01_entrance_route_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("02_entrance_route_portrait.png")
	await _set_viewport(Vector2i(1280, 720))
	for shot in [
		["03_camera_left_bound.png", CAMERA_MIN], ["04_camera_center.png", CAMERA_CENTER], ["05_camera_right_bound.png", CAMERA_MAX],
	]:
		camera_yaw = deg_to_rad(float(shot[1]))
		await _wait_frames(8)
		await _shot(shot[0])
	await _stage(Vector3(0.0, 0.8, 2.8), CAMERA_CENTER, 10.5, Vector3(0, 0, 1), "idle")
	_apply_equipment_state("starter_clothes")
	await _shot("06_equipment_idle_front.png")
	_apply_equipment_state("wayfarer_set")
	level = 4
	xp = 0
	facing = Vector3(1, 0, 0)
	player_state = "move"
	await _wait_frames(8)
	await _shot("07_equipment_move_side.png")
	await _stage(MOORLING_SPAWNS[0] + Vector3(-2.3, 0.8, 0.2), CAMERA_CENTER, 10.5, Vector3(1, 0, 0), "idle")
	selected = 0
	target_active = true
	moorlings[0].ring.visible = true
	_begin_attack()
	attack_phase = 0.18
	await _wait_frames(5)
	await _shot("08_equipment_attack_anticipation.png")
	attack_phase = 0.32
	_apply_attack_impact()
	await _wait_frames(5)
	await _shot("09_equipment_attack_impact.png")
	attack_phase = 0.82
	await _wait_frames(5)
	await _shot("10_equipment_attack_recovery.png")
	attack_phase = -1.0
	player_state = "idle"
	target_active = false
	moorlings[0].ring.visible = false
	slash_vfx.visible = false
	damage_label.visible = false
	toast.visible = false
	_apply_equipment_state("wayfarer_set")
	await _wait_frames(4)
	await _shot("11_equipment_after_upgrade.png")
	await _stage(NPC_POS + Vector3(2.2, 0.8, 1.2), CAMERA_CENTER, 10.8, NPC_POS - (NPC_POS + Vector3(2.2, 0.8, 1.2)), "idle")
	await _shot("12_npc_approach.png")
	dialogue.visible = true
	interaction_done = true
	await _wait_frames(5)
	await _shot("13_npc_interaction.png")
	dialogue.visible = false
	await _stage(MOORLING_SPAWNS[0] + Vector3(-2.6, 0.8, 0.5), CAMERA_CENTER, 11.0, Vector3(1, 0, 0), "idle")
	selected = 0
	target_active = true
	moorlings[0].ring.visible = true
	await _shot("14_moorling_target_cardinal.png")
	moorlings[0].state = "attack"
	moorlings[0].time = 0.22
	await _wait_frames(4)
	await _shot("15_moorling_attack_anticipation.png")
	moorlings[0].time = 0.62
	await _wait_frames(4)
	await _shot("16_moorling_attack_keypose.png")
	moorlings[0].state = "hit"
	moorlings[0].time = 0.35
	await _wait_frames(4)
	await _shot("17_moorling_hit.png")
	attack_phase = 0.32
	_apply_attack_impact()
	attack_phase = -1.0
	moorlings[0].state = "defeated"
	moorlings[0].time = 1.0
	slash_vfx.visible = false
	damage_label.visible = false
	await _wait_frames(5)
	await _shot("18_moorling_defeated_loot.png")
	_apply_equipment_state("starter_clothes")
	level = 3
	xp = 82
	var dropped: Node3D = moorlings[0].loot
	player.global_position = dropped.global_position
	_pickup_nearby_loot()
	await _wait_frames(3)
	await _shot("19_loot_pickup_feedback.png")
	await _stage(OAK_POS + Vector3(-0.8, 0.8, -1.1), CAMERA_CENTER, 11.0, Vector3(0, 0, 1), "idle")
	await _wait_frames(24)
	await _shot("20_canopy_occlusion_fade.png")
	await _stage(HALL_POS + Vector3(0.0, 0.8, -0.5), CAMERA_CENTER, 11.5, Vector3(0, 0, 1), "idle")
	await _wait_frames(24)
	force_roof_fade_capture = true
	await _shot("21_roof_occlusion_fade.png")
	force_roof_fade_capture = false
	await _stage(WAYSTONE_POS + Vector3(0, 0.8, 5.5), CAMERA_CENTER, 13.0, Vector3(0, 0, -1), "idle")
	await _shot("22_waystone_landmark.png")
	await _stage(Vector3(-3.0, 0.8, 3.0), CAMERA_MIN, 18.0, Vector3(0, 0, -1), "idle")
	await _shot("23_area_overview_left.png")
	camera_yaw = deg_to_rad(CAMERA_MAX)
	await _wait_frames(8)
	await _shot("24_area_overview_right.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("25_combat_clearing_portrait.png")
	_reset_moorlings()
	target_active = false
	slash_vfx.visible = false
	damage_label.visible = false
	_apply_equipment_state("wayfarer_set")
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 16.0, Vector3(0, 0, -1), "idle")
	await _shot("26_final_progression_portrait.png")
	await _set_viewport(Vector2i(1280, 720))
	await _shot("27_final_playable_landscape.png")
	_reset_moorlings()
	moorlings[0].state = "idle"
	await _stage(MOORLING_SPAWNS[0] + Vector3(-3.0, 0.8, 0.5), CAMERA_CENTER, 11.5, Vector3(1, 0, 0), "idle")
	await _shot("28_moorling_idle_landscape.png")
	moorlings[0].state = "move"
	moorlings[0].time = 0.55
	await _wait_frames(6)
	await _shot("29_moorling_movement_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _stage(NPC_POS + Vector3(1.9, 0.8, 1.0), CAMERA_CENTER, 11.2, NPC_POS - (NPC_POS + Vector3(1.9, 0.8, 1.0)), "idle")
	dialogue.visible = true
	await _shot("30_npc_interaction_portrait.png")
	dialogue.visible = false
	camera_yaw = deg_to_rad(CAMERA_MAX)
	await _wait_frames(7)
	await _shot("31_camera_right_bound_portrait.png")
	await _stage(MOORLING_SPAWNS[1] + Vector3(-2.5, 0.8, 0.5), CAMERA_CENTER, 12.0, Vector3(1, 0, 0), "attack")
	selected = 1
	target_active = true
	moorlings[1].ring.visible = true
	attack_phase = 0.32
	slash_vfx.global_position = moorlings[1].host.global_position + Vector3.UP * 1.2
	slash_vfx.visible = true
	damage_label.text = "-14"
	damage_label.global_position = moorlings[1].host.global_position + Vector3.UP * 2.5
	damage_label.visible = true
	await _shot("32_final_combat_portrait.png")
	_write_profile()
	print("M04.30_CAPTURE PASS screenshots=32 categories=landscape+portrait+combat+equipment+occlusion")
	get_tree().quit()


func _reset_demo_state() -> void:
	level = 3
	xp = 82
	_apply_equipment_state("starter_clothes")
	selected = 0
	target_active = false
	dialogue.visible = false
	slash_vfx.visible = false
	damage_label.visible = false
	for loot in loot_nodes:
		if is_instance_valid(loot):
			loot.queue_free()
	loot_nodes.clear()
	_reset_moorlings()


func _reset_moorlings() -> void:
	target_active = false
	for index in range(moorlings.size()):
		var data: Dictionary = moorlings[index]
		data.hp = 24
		data.state = "move"
		data.time = float(index) * 0.23
		data.defeated = false
		data.loot = null
		data.host.position = data.origin
		data.ring.visible = false


func _stage(pos: Vector3, yaw: float, zoom: float, new_facing: Vector3, state: String) -> void:
	toast.visible = false
	toast.modulate.a = 1.0
	player.position = pos
	camera_yaw = deg_to_rad(yaw)
	camera_zoom = zoom
	facing = Vector3(new_facing.x, 0.0, new_facing.z).normalized()
	player_state = state
	attack_phase = -1.0
	await _wait_frames(8)


func _set_viewport(size: Vector2i) -> void:
	get_window().size = size
	get_window().content_scale_size = size
	await _wait_frames(10)


func _shot(filename: String) -> void:
	# Dummy headless displays do not emit frame_post_draw. Process settling keeps
	# command-line evidence generation deterministic on both GUI and headless runs.
	await _wait_frames(2)
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT, filename])
	var error := image.save_png(path)
	assert(error == OK, "M04.30 screenshot failed: %s" % path)
	print("M04.30 screenshot saved: ", path)
	await _wait_frames(3)


func _write_profile() -> void:
	var counts := _visual_counts()
	var report := "scene=res://scenes/world/amberway_moor_m04_30.tscn\n"
	report += "renderer=%s\n" % RenderingServer.get_video_adapter_name()
	report += "node_count=%d\nunthrottled_engine_loop_fps=%.2f\nreported_process_monitor_ms=%.3f\naverage_draw_calls=%.2f\n" % [
		get_tree().get_node_count(), _measured_fps if _measured_fps > 0.0 else _average(_fps), _average(_frame_ms), _average_int(_draws),
	]
	report += "measured_wall_clock_frame_ms=%.3f\n" % (1000.0 / maxf(_measured_fps, 1.0))
	report += "unthrottled_engine_loop_scope=desktop automated process-frame throughput; not display FPS and not mobile performance\n"
	report += "reported_process_monitor_scope=Godot Performance.TIME_PROCESS sampled per process frame; not inverse of unthrottled throughput\n"
	report += "profile_nodes=%d\ndraw_nodes=%d\nmaterials=%d\ntransparent=%d\nshadow_casters=%d\nmesh_instances=%d\nsprite3d_instances=%d\ncollision_shapes=%d\nanimated_entities=%d\n" % [
		counts.profile_nodes, counts.draw_nodes, counts.materials, counts.transparent, counts.shadows,
		counts.meshes, counts.sprites, counts.collisions, counts.animated,
	]
	report += "camera_yaw_absolute=-10..80\ncamera_yaw_relative=-45..45\ncamera_pitch=34..48\ncamera_zoom=10..18\nauthoritative_snapshot_contains_camera=false\nmobile_performance_claim=false\nreal_device_test=NOT RUN\n"
	var file := FileAccess.open(OUTPUT + "/performance.txt", FileAccess.WRITE)
	if file:
		file.store_string(report)


func _visual_counts() -> Dictionary:
	var material_ids := {}
	var transparent := 0
	var shadows := 0
	var meshes := 0
	var sprites := 0
	var draw_nodes := 0
	for node in find_children("*", "GeometryInstance3D", true, false):
		draw_nodes += 1
		var geometry := node as GeometryInstance3D
		if geometry.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			shadows += 1
		if geometry is Sprite3D:
			sprites += 1
			transparent += 1
		elif geometry is MeshInstance3D:
			meshes += 1
			var material := (geometry as MeshInstance3D).material_override as BaseMaterial3D
			if material:
				material_ids[material.get_instance_id()] = true
				if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
					transparent += 1
	return {
		"profile_nodes": find_children("*", "SpatialEntityPresenter", true, false).size(),
		"draw_nodes": draw_nodes, "materials": material_ids.size(), "transparent": transparent,
		"shadows": shadows, "meshes": meshes, "sprites": sprites,
		"collisions": find_children("*", "CollisionShape3D", true, false).size(),
		"animated": 1 + moorlings.size(),
	}


func _plane(pos: Vector3, size: Vector2, texture_path: String, color: Color, uv: Vector2) -> void:
	var item := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	var mat := _material(color, false)
	mat.albedo_texture = load(texture_path)
	mat.uv1_scale = Vector3(uv.x, uv.y, 1.0)
	item.material_override = mat
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(item)


func _path(pos: Vector3, size: Vector2, yaw: float) -> void:
	var item := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	item.rotation_degrees.y = yaw
	var mat := _material(Color("#eee0ad"), false)
	mat.albedo_texture = load(GAME + "world/terrain/materials/cobble_repeat_256.png")
	mat.uv1_scale = Vector3(maxf(1.0, size.x / 2.0), maxf(1.0, size.y / 2.0), 1.0)
	item.material_override = mat
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(item)


func _add_world_sprite(path: String, pos: Vector3, pixel_size: float, node_name: String, billboard: bool) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = node_name
	sprite.texture = load(path)
	sprite.position = pos
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if billboard else BaseMaterial3D.BILLBOARD_DISABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sprite)
	return sprite


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.material_override = _material(color)
	parent.add_child(item)
	return item


func _add_hall_window(parent: Node3D, pos: Vector3, side: bool) -> void:
	var frame_size := Vector3(0.18, 1.18, 1.12) if side else Vector3(1.12, 1.18, 0.18)
	var glass_size := Vector3(0.19, 0.82, 0.78) if side else Vector3(0.78, 0.82, 0.19)
	_box(parent, frame_size, pos, Color("#70452a"))
	var glass := pos
	glass.x += 0.1 * signf(pos.x) if side else 0.0
	glass.z += 0.1 if not side else 0.0
	_box(parent, glass_size, glass, Color("#76bfc1"))
	var mullion_size := Vector3(0.2, 0.1, 0.82) if side else Vector3(0.82, 0.1, 0.2)
	_box(parent, mullion_size, glass, Color("#ead18b"))


func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	item.mesh = mesh
	item.position = pos
	item.scale = scale_value
	item.material_override = _material(color, false)
	parent.add_child(item)
	return item


func _target_ring() -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.58
	mesh.outer_radius = 0.76
	mesh.rings = 24
	mesh.ring_segments = 8
	ring.mesh = mesh
	ring.position.y = 0.06
	var mat := _material(Color("#ffd35a"), false)
	mat.emission_enabled = true
	mat.emission = Color("#ffd35a")
	ring.material_override = mat
	ring.scale = Vector3(1.18, 1.18, 1.18)
	ring.visible = false
	return ring


func _material(color: Color, cached := true) -> StandardMaterial3D:
	var key := color.to_html(true)
	if cached and _material_cache.has(key):
		return _material_cache[key]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if cached:
		_material_cache[key] = mat
	return mat


func _contact_shadow(parent: Node3D, radius: float, y: float) -> void:
	var shadow := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.012
	disc.radial_segments = 20
	shadow.mesh = disc
	shadow.position.y = y
	var mat := _material(Color(0.04, 0.07, 0.03, 0.5), false)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow.material_override = mat
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)


func _contact_shadow_at(pos: Vector3, radius: float) -> void:
	var host := Node3D.new()
	host.position = pos
	add_child(host)
	_contact_shadow(host, radius, 0.02)


func _nameplate(text: String, pos: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 32
	label.pixel_size = 0.0055
	label.modulate = color
	label.outline_size = 8
	add_child(label)


func _add_ground_collision() -> void:
	_add_static_box(Vector3(0.0, -0.12, 0.0), Vector3(86.0, 0.2, 74.0))


func _add_static_box(pos: Vector3, size: Vector3) -> void:
	var host := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	host.position = pos
	host.add_child(collision)
	add_child(host)


func _add_static_cylinder(pos: Vector3, radius: float, height: float) -> void:
	var host := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	host.position = pos
	host.add_child(collision)
	add_child(host)


func _safe_world_drag(pos: Vector2) -> bool:
	var size := get_viewport().get_visible_rect().size
	var normalized := Vector2(pos.x / maxf(size.x, 1.0), pos.y / maxf(size.y, 1.0))
	return normalized.y > 0.12 and normalized.y < 0.72 and normalized.x > 0.24


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _average(values: Array[float]) -> float:
	var total := 0.0
	for value in values:
		total += value
	return total / maxf(float(values.size()), 1.0)


func _average_int(values: Array[int]) -> float:
	var total := 0.0
	for value in values:
		total += value
	return total / maxf(float(values.size()), 1.0)
