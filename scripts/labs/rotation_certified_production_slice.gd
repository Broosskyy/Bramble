extends Node3D

const GAME := "res://assets/game/"
const LAB := "res://assets/labs/m04_26/"
const COMPLETION_DIR := "res://artifacts/m04_26_completion"
const DIR_NAMES := [
	"front", "front_right", "right", "back_right",
	"back", "back_left", "left", "front_left"
]
const CAMERA_CENTER := 35.0
const CAMERA_LEFT := -10.0
const CAMERA_RIGHT := 80.0
const SPAWN := Vector3(0.0, 0.8, 8.0)
const BUILDING_POS := Vector3(-6.2, 0.0, -3.2)
const TREE_POS := Vector3(8.0, 0.0, 0.3)
const NPC_POS := Vector3(-2.0, 0.0, -0.8)
const MONSTER_POS := Vector3(5.7, 0.0, 6.2)
const LANDMARK_POS := Vector3(3.5, 0.0, -4.3)

var player: CharacterBody3D
var body_sprite: Sprite3D
var armor_sprite: Sprite3D
var hat_sprite: Sprite3D
var weapon_sprite: Sprite3D
var npc_sprite: Sprite3D
var monster_sprite: Sprite3D
var camera: Camera3D
var target_ring: MeshInstance3D
var damage_label: Label3D
var reward_label: Label3D
var attack_vfx: Sprite3D
var dialogue_panel: PanelContainer
var interaction_prompt: Label
var status_label: Label
var objective_label: Label
var mobile_hint: Label
var roof_parts: Array[MeshInstance3D] = []
var canopy_parts: Array[MeshInstance3D] = []
var canopy_materials: Array[StandardMaterial3D] = []
var canopy_sprites: Array[Sprite3D] = []
var _material_cache: Dictionary = {}
var camera_yaw := deg_to_rad(CAMERA_CENTER)
var camera_pitch := deg_to_rad(40.0)
var camera_size := 14.0
var character_facing := Vector3(0.0, 0.0, 1.0)
var equipped := true
var dragging_camera := false
var capture_running := false
var target_active := false
var combat_active := false
var interaction_active := false
var action_state := "EXPLORE"
var _last_direction := ""
var _damage_time := 0.0
var _attack_time := 0.0
var _movement_phase := 0.0
var _monster_health := 24
var _monster_defeated := false
var _fps_samples: Array[float] = []
var _draw_samples: Array[int] = []
var _frame_ms_samples: Array[float] = []


func _ready() -> void:
	_build_environment()
	_build_ground_and_routes()
	_build_production_building()
	_build_production_tree()
	_build_landmark()
	_build_boundaries_and_props()
	_build_characters()
	_build_camera()
	_build_hud()
	_set_equipped(true)
	var args := OS.get_cmdline_user_args()
	if "--m04_26-completion-capture" in args:
		capture_running = true
		call_deferred("_capture_completion_evidence")
	elif "--m04_26-capture" in args:
		capture_running = true
		call_deferred("_capture_evidence")
	elif "--m04_26-profile" in args:
		capture_running = true
		call_deferred("_profile_and_quit")
	elif "--m04_26-smoke" in args:
		call_deferred("_smoke_and_quit")


func _process(delta: float) -> void:
	if not capture_running:
		_update_movement()
	_update_camera()
	_update_directional_presentation()
	_update_equipment_attachment()
	_update_occlusion(delta)
	_update_feedback(delta)
	_update_hud()
	_fps_samples.append(Performance.get_monitor(Performance.TIME_FPS))
	_draw_samples.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	_frame_ms_samples.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	if _fps_samples.size() > 600:
		_fps_samples.pop_front()
		_draw_samples.pop_front()
		_frame_ms_samples.pop_front()


func _unhandled_input(event: InputEvent) -> void:
	if capture_running:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging_camera = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_size = clampf(camera_size - 0.8, 10.0, 18.0)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_size = clampf(camera_size + 0.8, 10.0, 18.0)
	elif event is InputEventMouseMotion and dragging_camera:
		camera_yaw = clampf(camera_yaw - event.relative.x * 0.007, deg_to_rad(CAMERA_LEFT), deg_to_rad(CAMERA_RIGHT))
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.004, deg_to_rad(34.0), deg_to_rad(48.0))
	elif event is InputEventScreenDrag:
		if _is_safe_camera_drag(event.position):
			camera_yaw = clampf(camera_yaw - event.relative.x * 0.006, deg_to_rad(CAMERA_LEFT), deg_to_rad(CAMERA_RIGHT))
	elif event is InputEventMagnifyGesture:
		camera_size = clampf(camera_size / event.factor, 10.0, 18.0)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_attack()
		elif event.keycode == KEY_G:
			_set_equipped(not equipped)
		elif event.keycode == KEY_E:
			interaction_active = player.global_position.distance_to(NPC_POS) < 2.7
			dialogue_panel.visible = interaction_active


func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#9fcbd2")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#fff2d0")
	environment.ambient_light_energy = 0.54
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54.0, -38.0, 0.0)
	sun.light_color = Color("#ffe4aa")
	sun.light_energy = 0.78
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 35.0
	add_child(sun)


func _build_ground_and_routes() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(52.0, 44.0)
	ground.mesh = plane
	var grass := _material(Color("#86a957"))
	grass.albedo_texture = load(GAME + "world/terrain/materials/grass_repeat_256.png")
	grass.uv1_scale = Vector3(11.0, 10.0, 1.0)
	ground.material_override = grass
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground)
	_add_ground_collision(Vector3(52.0, 0.2, 44.0))
	_add_path(Vector3(0.0, 0.025, 0.0), Vector2(3.5, 22.0), 0.0)
	_add_path(Vector3(-3.4, 0.03, -2.2), Vector2(7.2, 3.0), deg_to_rad(-7.0))
	_add_path(Vector3(3.1, 0.035, 5.4), Vector2(7.5, 3.4), deg_to_rad(8.0))
	_add_path(Vector3(0.0, 0.04, -8.0), Vector2(6.5, 4.2), 0.0)
	for pos in [
		Vector3(-3.1, 0.04, 3.2), Vector3(2.4, 0.04, 1.3),
		Vector3(-1.8, 0.04, -5.4), Vector3(4.1, 0.04, -4.8)
	]:
		var flowers := _sprite(GAME + "world/terrain/overlays/overlay_grass_clumps_256.png", 0.0075, true)
		flowers.position = pos + Vector3(0.0, 0.45, 0.0)
		add_child(flowers)


func _build_production_building() -> void:
	var host := Node3D.new()
	host.name = "WayfarerHall_LIMITED_ROTATION_READY"
	host.position = BUILDING_POS
	add_child(host)
	_box(host, Vector3(6.15, 0.58, 5.1), Vector3(0.0, 0.28, 0.0), Color("#665d50"))
	_box(host, Vector3(5.5, 3.25, 4.5), Vector3(0.0, 1.9, 0.0), Color("#e7c988"))
	_box(host, Vector3(5.72, 0.38, 4.7), Vector3(0.0, 0.72, 0.0), Color("#9b8260"))
	for x in [-2.55, 0.0, 2.55]:
		_box(host, Vector3(0.18, 3.2, 0.22), Vector3(x, 2.0, 2.31), Color("#694026"))
		_box(host, Vector3(0.18, 3.2, 0.22), Vector3(x, 2.0, -2.31), Color("#694026"))
	for z in [-2.05, 0.0, 2.05]:
		_box(host, Vector3(0.22, 3.2, 0.18), Vector3(-2.81, 2.0, z), Color("#694026"))
		_box(host, Vector3(0.22, 3.2, 0.18), Vector3(2.81, 2.0, z), Color("#694026"))
	_box(host, Vector3(1.15, 2.15, 0.22), Vector3(0.0, 1.35, 2.34), Color("#70412b"))
	_box(host, Vector3(0.82, 0.14, 0.28), Vector3(0.0, 2.5, 2.42), Color("#d8a84a"))
	for side in [-1.0, 1.0]:
		_box(host, Vector3(2.35, 0.16, 0.18), Vector3(side * 1.38, 3.42, 2.38), Color("#704326"), Vector3(0.0, 0.0, deg_to_rad(side * 24.0)))
		_box(host, Vector3(0.18, 0.18, 3.35), Vector3(side * 2.86, 2.0, 0.0), Color("#704326"), Vector3(deg_to_rad(28.0), 0.0, 0.0))
		_box(host, Vector3(0.18, 0.18, 3.35), Vector3(side * 2.86, 2.0, 0.0), Color("#704326"), Vector3(deg_to_rad(-28.0), 0.0, 0.0))
	for x in [-1.75, 1.75]:
		_add_window(host, Vector3(x, 2.05, 2.35), Vector3(0.0, 0.0, 0.0))
	for z in [-1.25, 1.25]:
		_add_window(host, Vector3(2.84, 2.05, z), Vector3(0.0, deg_to_rad(90.0), 0.0))
		_add_window(host, Vector3(-2.84, 2.05, z), Vector3(0.0, deg_to_rad(90.0), 0.0))
	var roof_mat := _material(Color("#225557"))
	roof_mat.roughness = 0.78
	for side in [-1.0, 1.0]:
		var roof := _box(host, Vector3(3.8, 0.3, 5.3), Vector3(side * 1.55, 4.28, 0.0), Color.WHITE, Vector3(0.0, 0.0, deg_to_rad(-side * 31.0)))
		roof.material_override = roof_mat.duplicate()
		roof_parts.append(roof)
		for row in range(5):
			var row_x: float = side * (0.58 + float(row) * 0.58)
			var row_y: float = 5.02 - float(row) * 0.36
			_box(host, Vector3(0.06, 0.07, 5.36), Vector3(row_x, row_y, 0.0), Color("#183f41"))
	_box(host, Vector3(0.22, 0.22, 5.55), Vector3(0.0, 5.25, 0.0), Color("#d49b4f"))
	for side in [-1.0, 1.0]:
		_box(host, Vector3(0.18, 0.22, 5.48), Vector3(side * 3.18, 3.35, 0.0), Color("#d49b4f"))
	_box(host, Vector3(0.78, 2.15, 0.84), Vector3(-1.7, 4.75, -0.65), Color("#88745b"))
	_box(host, Vector3(0.96, 0.22, 1.02), Vector3(-1.7, 5.86, -0.65), Color("#5c4f43"))
	_box(host, Vector3(2.2, 0.18, 0.75), Vector3(0.0, 0.64, 2.75), Color("#8a5833"))
	for x in [-0.9, -0.3, 0.3, 0.9]:
		_box(host, Vector3(0.12, 0.42, 0.12), Vector3(x, 0.85, 2.75), Color("#5f3d25"))
	for x in [-1.9, -1.45, 1.45, 1.9]:
		var flower := _sphere(host, Vector3(x, 1.45, 2.48), Vector3(0.22, 0.18, 0.22), Color("#e47c48"))
		flower.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-0.48, 0.48]:
		var lantern := _sphere(host, Vector3(x, 2.38, 2.56), Vector3(0.12, 0.2, 0.1), Color("#ffd86b"), _emissive_material(Color("#ffd86b")))
		lantern.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for z in [-1.35, 1.35]:
		_box(host, Vector3(0.2, 2.75, 0.2), Vector3(2.94, 2.05, z), Color("#633c25"))
		_box(host, Vector3(0.2, 2.75, 0.2), Vector3(-2.94, 2.05, z), Color("#633c25"))
		_box(host, Vector3(0.24, 0.34, 1.25), Vector3(2.98, 1.32, z), Color("#8a5833"))
		_box(host, Vector3(0.24, 0.34, 1.25), Vector3(-2.98, 1.32, z), Color("#8a5833"))
	for x in [-2.35, 2.35]:
		for z in [-1.9, 1.9]:
			_box(host, Vector3(0.42, 0.42, 0.42), Vector3(x, 0.62, z), Color("#a99b7d"))
	_add_static_box(host, Vector3(5.9, 3.7, 4.9), Vector3(0.0, 1.85, 0.0))
	var door_label := Label3D.new()
	door_label.text = "Wayfarer Hall"
	door_label.position = Vector3(0.0, 3.0, 2.45)
	door_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	door_label.font_size = 30
	door_label.pixel_size = 0.005
	door_label.modulate = Color("#ffe5a4")
	door_label.outline_size = 7
	host.add_child(door_label)


func _build_production_tree() -> void:
	var host := Node3D.new()
	host.name = "AmberOak_LIMITED_ROTATION_READY"
	host.position = TREE_POS
	add_child(host)
	var painted_crown := _sprite(GAME + "world/buildings/red_oak.png", 0.0112, true)
	painted_crown.name = "CanonicalRedOakSingleControlledBillboard"
	painted_crown.position = Vector3(0.0, 2.85, 0.0)
	painted_crown.render_priority = 1
	host.add_child(painted_crown)
	canopy_sprites.append(painted_crown)
	_add_contact_shadow(host, 0.82, 0.03)
	_add_static_cylinder(host, 0.76, 2.6, Vector3(0.0, 1.3, 0.0))


func _build_landmark() -> void:
	var host := Node3D.new()
	host.name = "BrambleWaystoneLandmark"
	host.position = LANDMARK_POS
	add_child(host)
	_box(host, Vector3(5.0, 0.35, 3.6), Vector3(0.0, 0.18, 0.0), Color("#625d58"))
	_box(host, Vector3(4.15, 0.28, 2.75), Vector3(0.0, 0.46, 0.0), Color("#968b78"))
	for x in [-1.45, 1.45]:
		_box(host, Vector3(0.78, 3.9, 0.78), Vector3(x, 2.35, 0.0), Color("#776f65"), Vector3(0.0, 0.0, deg_to_rad(x * 4.0)))
		_box(host, Vector3(0.95, 0.18, 0.95), Vector3(x, 1.1, 0.0), Color("#d3a94f"))
	_box(host, Vector3(3.75, 0.72, 0.82), Vector3(0.0, 4.35, 0.0), Color("#776f65"))
	_box(host, Vector3(4.05, 0.16, 1.0), Vector3(0.0, 4.75, 0.0), Color("#d3a94f"))
	var crystal := _sphere(host, Vector3(0.0, 2.55, 0.0), Vector3(0.7, 1.5, 0.46), Color("#54d9cf"), _emissive_material(Color("#54d9cf")))
	crystal.rotation_degrees.z = 45.0
	var halo_mesh := TorusMesh.new()
	halo_mesh.inner_radius = 1.05
	halo_mesh.outer_radius = 1.18
	halo_mesh.rings = 32
	halo_mesh.ring_segments = 8
	var halo := MeshInstance3D.new()
	halo.mesh = halo_mesh
	halo.position = Vector3(0.0, 2.55, 0.12)
	halo.rotation_degrees.x = 90.0
	halo.material_override = _emissive_material(Color("#8ff3df"))
	host.add_child(halo)
	for x in [-2.1, 2.1]:
		var banner := _box(host, Vector3(0.72, 1.95, 0.08), Vector3(x, 2.7, 0.45), Color("#315c78"))
		banner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _build_boundaries_and_props() -> void:
	for z in [-6.0, -3.8, -1.6, 0.6, 2.8, 5.0, 7.2]:
		_add_fence_segment(Vector3(-12.0, 0.0, z), 0.0)
	for x in [-10.0, -7.8, -5.6, 7.8, 10.0]:
		_add_fence_segment(Vector3(x, 0.0, 11.2), 90.0)
	for item in [
		[Vector3(-9.2, 0.0, 7.5), 1.0], [Vector3(8.8, 0.0, -7.2), 1.3],
		[Vector3(10.5, 0.0, 5.6), 0.8], [Vector3(-10.0, 0.0, -8.0), 1.15]
	]:
		_add_rock(item[0], item[1])
	for pos in [
		Vector3(-9.0, 0.0, -5.5), Vector3(-10.3, 0.0, 2.4),
		Vector3(9.4, 0.0, -3.8), Vector3(10.4, 0.0, 1.6),
		Vector3(-7.8, 0.0, 9.4), Vector3(7.8, 0.0, 9.4)
	]:
		var shrub := _sprite(GAME + "world/buildings/golden_shrubs.png", 0.0075, true)
		shrub.position = pos + Vector3(0.0, 0.72, 0.0)
		add_child(shrub)


func _build_characters() -> void:
	player = CharacterBody3D.new()
	player.name = "SpatialPlayer"
	player.position = SPAWN
	var player_collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.5
	player_collision.shape = capsule
	player.add_child(player_collision)
	add_child(player)
	_add_contact_shadow(player, 0.5, -0.76)
	body_sprite = _sprite(GAME + "characters/base/male/directions/front.png", 0.0055, true)
	body_sprite.name = "BaseBody"
	body_sprite.position.y = 1.2
	body_sprite.render_priority = 0
	player.add_child(body_sprite)
	armor_sprite = _sprite(LAB + "wayfarer_armor_8dir.svg", 0.0055, true)
	armor_sprite.name = "WayfarerArmor8Direction"
	armor_sprite.hframes = 8
	armor_sprite.position = Vector3(0.0, 1.2, -0.012)
	armor_sprite.render_priority = 1
	player.add_child(armor_sprite)
	hat_sprite = _sprite(LAB + "wayfarer_hat_8dir.svg", 0.0055, true)
	hat_sprite.name = "WayfarerHat8Direction"
	hat_sprite.hframes = 8
	hat_sprite.position = Vector3(0.0, 1.2, -0.024)
	hat_sprite.render_priority = 2
	player.add_child(hat_sprite)
	weapon_sprite = _sprite(GAME + "characters/equipment/weapons/melee/short_sword.png", 0.00265, true)
	weapon_sprite.name = "DirectionalWeapon"
	weapon_sprite.render_priority = 3
	add_child(weapon_sprite)

	npc_sprite = _sprite(GAME + "npcs/merchant/directions/front.png", 0.0054, true)
	npc_sprite.name = "DirectionalMerchant"
	npc_sprite.position = NPC_POS + Vector3(0.0, 1.22, 0.0)
	add_child(npc_sprite)
	_add_contact_shadow_at(NPC_POS, 0.46)
	_add_static_cylinder(self, 0.42, 1.5, NPC_POS + Vector3(0.0, 0.75, 0.0))
	_add_nameplate("Lina  ·  Wayfinder", NPC_POS + Vector3(0.0, 2.75, 0.0), Color("#ffe6a0"))
	var quest := Label3D.new()
	quest.text = "!"
	quest.position = NPC_POS + Vector3(0.0, 3.2, 0.0)
	quest.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quest.font_size = 56
	quest.pixel_size = 0.006
	quest.modulate = Color("#ffd15b")
	quest.outline_size = 8
	add_child(quest)

	monster_sprite = _sprite(GAME + "monsters/moorling/directions/kit60_front.png", 0.0058, true)
	monster_sprite.name = "MoorlingFourDirection_PARTIAL"
	monster_sprite.position = MONSTER_POS + Vector3(0.0, 1.08, 0.0)
	add_child(monster_sprite)
	_add_contact_shadow_at(MONSTER_POS, 0.55)
	_add_nameplate("Moorling  ·  Lv. 3", MONSTER_POS + Vector3(0.0, 2.55, 0.0), Color("#ffd1b0"))
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.58
	ring_mesh.outer_radius = 0.7
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 8
	target_ring = MeshInstance3D.new()
	target_ring.mesh = ring_mesh
	target_ring.position = MONSTER_POS + Vector3(0.0, 0.06, 0.0)
	target_ring.material_override = _emissive_material(Color("#ffd35a"))
	target_ring.visible = false
	add_child(target_ring)
	attack_vfx = _sprite(GAME + "combat/vfx/melee_slash_sequence/frames/03_slash_peak.png", 0.0048, true)
	attack_vfx.name = "CanonicalMeleeSlashImpact"
	attack_vfx.position = MONSTER_POS + Vector3(0.0, 1.2, -0.08)
	attack_vfx.modulate = Color(1.0, 1.0, 1.0, 0.0)
	attack_vfx.visible = false
	attack_vfx.render_priority = 6
	add_child(attack_vfx)
	damage_label = Label3D.new()
	damage_label.text = "12  HIT!"
	damage_label.position = MONSTER_POS + Vector3(0.0, 3.15, 0.0)
	damage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	damage_label.font_size = 48
	damage_label.pixel_size = 0.007
	damage_label.modulate = Color("#fff2a6")
	damage_label.outline_size = 10
	damage_label.visible = false
	add_child(damage_label)
	reward_label = Label3D.new()
	reward_label.text = "MOORLING DEFEATED\n+18 XP   ·   LEAF MOTE"
	reward_label.position = MONSTER_POS + Vector3(0.0, 3.55, 0.0)
	reward_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	reward_label.font_size = 34
	reward_label.pixel_size = 0.006
	reward_label.modulate = Color("#ffe18a")
	reward_label.outline_size = 10
	reward_label.visible = false
	add_child(reward_label)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "LimitedOrbitCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = camera_size
	camera.near = 0.2
	camera.far = 80.0
	camera.current = true
	add_child(camera)
	_update_camera()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "ProductionSliceHUD"
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(0.035, 0.07, 0.065, 0.9)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 82.0
	layer.add_child(top)
	var title := Label.new()
	title.text = "BRAMBLE  ·  AMBERWAY CROSSING"
	title.position = Vector2(20.0, 10.0)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#ffe7a4"))
	top.add_child(title)
	status_label = Label.new()
	status_label.position = Vector2(21.0, 44.0)
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color("#d7ead6"))
	top.add_child(status_label)

	var quest_panel := PanelContainer.new()
	quest_panel.position = Vector2(18.0, 98.0)
	quest_panel.custom_minimum_size = Vector2(245.0, 64.0)
	var quest_style := StyleBoxFlat.new()
	quest_style.bg_color = Color(0.035, 0.07, 0.065, 0.9)
	quest_style.border_color = Color("#d6a84e")
	quest_style.set_border_width_all(1)
	quest_style.set_corner_radius_all(4)
	quest_style.content_margin_left = 12.0
	quest_style.content_margin_top = 8.0
	quest_style.content_margin_right = 12.0
	quest_style.content_margin_bottom = 8.0
	quest_panel.add_theme_stylebox_override("panel", quest_style)
	layer.add_child(quest_panel)
	objective_label = Label.new()
	objective_label.text = "WAYFINDER'S ERRAND\nFollow the road to the waystone"
	objective_label.add_theme_font_size_override("font_size", 13)
	objective_label.add_theme_color_override("font_color", Color("#fff0bd"))
	quest_panel.add_child(objective_label)

	interaction_prompt = Label.new()
	interaction_prompt.text = "[ E ]  Talk to Lina"
	interaction_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	interaction_prompt.position = Vector2(-72.0, -112.0)
	interaction_prompt.add_theme_font_size_override("font_size", 17)
	interaction_prompt.add_theme_color_override("font_color", Color("#ffe69b"))
	layer.add_child(interaction_prompt)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialogue_panel.position = Vector2(-210.0, -230.0)
	dialogue_panel.custom_minimum_size = Vector2(420.0, 112.0)
	dialogue_panel.visible = false
	var dialogue_style := quest_style.duplicate()
	dialogue_style.bg_color = Color(0.035, 0.07, 0.065, 0.94)
	dialogue_panel.add_theme_stylebox_override("panel", dialogue_style)
	layer.add_child(dialogue_panel)
	var dialogue := Label.new()
	dialogue.text = "LINA · WAYFINDER\nThe Amberway is open. Keep to the stones;\nMoorlings gather beyond the old oak."
	dialogue.add_theme_color_override("font_color", Color("#fff0bd"))
	dialogue.add_theme_font_size_override("font_size", 15)
	dialogue_panel.add_child(dialogue)

	var bottom := ColorRect.new()
	bottom.color = Color(0.035, 0.07, 0.065, 0.86)
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -48.0
	layer.add_child(bottom)

	mobile_hint = Label.new()
	mobile_hint.text = "WASD Move   ·   RMB/Drag Orbit   ·   Wheel/Pinch Zoom   ·   Space Attack"
	mobile_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	mobile_hint.position = Vector2(16.0, -35.0)
	mobile_hint.add_theme_color_override("font_color", Color("#fff4cf"))
	layer.add_child(mobile_hint)
	var action_bar := Label.new()
	action_bar.text = "◎ SELF     ◉ TARGET        [1] STRIKE     [2] GUARD     [G] GEAR"
	action_bar.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_bar.position = Vector2(-500.0, -35.0)
	action_bar.add_theme_color_override("font_color", Color("#ffe5a0"))
	layer.add_child(action_bar)


func _update_movement() -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length_squared() < 0.01:
		player.velocity = Vector3.ZERO
		return
	var forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw)).normalized()
	var right := Vector3(forward.z, 0.0, -forward.x)
	var movement := (right * input.x + forward * -input.y).normalized()
	player.velocity = movement * 3.8
	player.move_and_slide()
	player.position.x = clampf(player.position.x, -15.0, 15.0)
	player.position.z = clampf(player.position.z, -13.5, 13.5)
	character_facing = movement
	action_state = "MOVE"


func _update_camera() -> void:
	if camera == null or player == null:
		return
	var portrait := get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x
	camera.size = camera_size * (1.22 if portrait else 1.0)
	var distance := 18.0
	var horizontal := cos(camera_pitch) * distance
	var offset := Vector3(sin(camera_yaw) * horizontal, sin(camera_pitch) * distance, cos(camera_yaw) * horizontal)
	var bias := Vector3(0.0, 0.0, -0.7 if portrait else -0.2)
	var focus := player.global_position + Vector3(0.0, 1.05, 0.0) + bias
	camera.global_position = focus + offset
	camera.look_at(focus, Vector3.UP)


func _update_directional_presentation() -> void:
	var direction := _relative_direction(character_facing, camera_yaw)
	var frame_index := DIR_NAMES.find(direction)
	if direction != _last_direction:
		body_sprite.texture = load(GAME + "characters/base/male/directions/%s.png" % direction)
		armor_sprite.frame = frame_index
		hat_sprite.frame = frame_index
		_last_direction = direction
	var npc_facing := player.global_position - NPC_POS
	npc_facing.y = 0.0
	if npc_facing.length_squared() < 0.01:
		npc_facing = Vector3(0.0, 0.0, 1.0)
	npc_sprite.texture = load(GAME + "npcs/merchant/directions/%s.png" % _relative_direction(npc_facing.normalized(), camera_yaw))
	if _monster_defeated:
		monster_sprite.texture = load(GAME + "monsters/moorling/actions/defeated.png")
	elif _damage_time > 0.0:
		monster_sprite.texture = load(GAME + "monsters/moorling/actions/hit.png")
	else:
		var monster_direction := _nearest_four_direction(_relative_direction(Vector3(-1.0, 0.0, -0.2), camera_yaw))
		monster_sprite.texture = load(GAME + "monsters/moorling/directions/kit60_%s.png" % monster_direction)


func _update_equipment_attachment() -> void:
	if not equipped:
		weapon_sprite.visible = false
		return
	var direction := _last_direction
	var data: Array = {
		"front": [0.56, 1.02, -18.0, 3],
		"front_right": [0.54, 1.02, -15.0, 3],
		"right": [0.45, 1.0, -10.0, 3],
		"back_right": [0.42, 1.08, 18.0, -1],
		"back": [-0.48, 1.1, 20.0, -1],
		"back_left": [-0.42, 1.08, -18.0, -1],
		"left": [-0.45, 1.0, 10.0, 3],
		"front_left": [-0.54, 1.02, 15.0, 3]
	}.get(direction, [0.56, 1.02, -18.0, 3])
	var camera_right := Vector3(cos(camera_yaw), 0.0, -sin(camera_yaw))
	var camera_forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw))
	weapon_sprite.global_position = player.global_position + camera_right * float(data[0]) + Vector3.UP * float(data[1]) + camera_forward * 0.04
	var attack_swing := 0.0
	if _attack_time > 0.0:
		var attack_progress := 1.0 - _attack_time
		attack_swing = lerpf(-58.0, 46.0, smoothstep(0.0, 1.0, attack_progress))
	weapon_sprite.rotation_degrees.z = float(data[2]) + attack_swing
	weapon_sprite.render_priority = int(data[3])
	weapon_sprite.visible = true


func _relative_direction(world_facing: Vector3, view_yaw: float) -> String:
	var facing_angle := atan2(world_facing.x, world_facing.z)
	var relative := wrapf(facing_angle - view_yaw, -PI, PI)
	return DIR_NAMES[posmod(int(round(relative / (TAU / 8.0))), 8)]


func _nearest_four_direction(direction: String) -> String:
	match direction:
		"front_left", "front_right": return "front"
		"back_left", "back_right": return "back"
		_: return direction


func _update_occlusion(delta: float) -> void:
	var tree_cover := _point_covers_player(TREE_POS, 1.75)
	var tree_alpha := 0.34 if tree_cover else 1.0
	for mat in canopy_materials:
		var color := mat.albedo_color
		color.a = move_toward(color.a, tree_alpha, delta * 3.5)
		mat.albedo_color = color
	for sprite in canopy_sprites:
		var color := sprite.modulate
		color.a = move_toward(color.a, tree_alpha, delta * 3.5)
		sprite.modulate = color
	var roof_cover := _point_covers_player(BUILDING_POS, 3.2)
	for roof in roof_parts:
		var mat := roof.material_override as StandardMaterial3D
		if mat:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			var color := mat.albedo_color
			color.a = move_toward(color.a, 0.38 if roof_cover else 1.0, delta * 3.5)
			mat.albedo_color = color


func _point_covers_player(point: Vector3, radius: float) -> bool:
	var a := Vector2(camera.global_position.x, camera.global_position.z)
	var b := Vector2(player.global_position.x, player.global_position.z)
	var p := Vector2(point.x, point.z)
	var segment := b - a
	var t := clampf((p - a).dot(segment) / maxf(segment.length_squared(), 0.001), 0.0, 1.0)
	return t > 0.12 and t < 0.96 and p.distance_to(a + segment * t) < radius


func _update_feedback(delta: float) -> void:
	if target_ring.visible:
		var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.008) * 0.07
		target_ring.scale = Vector3(pulse, pulse, pulse)
	if _damage_time > 0.0:
		_damage_time -= delta
		damage_label.visible = true
		damage_label.position.y += delta * 0.32
		var color := damage_label.modulate
		color.a = clampf(_damage_time * 2.5, 0.0, 1.0)
		damage_label.modulate = color
		monster_sprite.modulate = Color(1.55, 1.05, 1.05, 1.0)
		var knockback := clampf(_damage_time * 2.0, 0.0, 1.0)
		monster_sprite.position = MONSTER_POS + Vector3(0.18 * knockback, 1.08, 0.12 * knockback)
		attack_vfx.visible = true
		var vfx_color := attack_vfx.modulate
		vfx_color.a = clampf(_damage_time * 2.8, 0.0, 1.0)
		attack_vfx.modulate = vfx_color
		attack_vfx.scale = Vector3.ONE * (1.0 + (0.65 - _damage_time) * 0.45)
	else:
		damage_label.visible = false
		attack_vfx.visible = false
		if not _monster_defeated:
			monster_sprite.modulate = Color.WHITE
			monster_sprite.position = MONSTER_POS + Vector3(0.0, 1.08, 0.0)
	if _attack_time > 0.0:
		_attack_time = maxf(0.0, _attack_time - delta * 2.4)
		var anticipation := sin((1.0 - _attack_time) * PI)
		var camera_forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw))
		var lean := camera_forward * (0.16 * anticipation) + Vector3(0.0, -0.04 * anticipation, 0.0)
		body_sprite.position = Vector3(0.0, 1.2, 0.0) + lean
		armor_sprite.position = Vector3(0.0, 1.2, -0.012) + lean
		hat_sprite.position = Vector3(0.0, 1.2, -0.024) + lean
	else:
		body_sprite.position = Vector3(0.0, 1.2, 0.0)
		armor_sprite.position = Vector3(0.0, 1.2, -0.012)
		hat_sprite.position = Vector3(0.0, 1.2, -0.024)
	if action_state == "MOVEMENT":
		_movement_phase += delta * 9.0
		var bob := sin(_movement_phase) * 0.035
		body_sprite.position.y += bob
		armor_sprite.position.y += bob
		hat_sprite.position.y += bob


func _update_hud() -> void:
	if status_label == null:
		return
	var portrait := get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x
	var relative_yaw := int(round(rad_to_deg(camera_yaw) - CAMERA_CENTER))
	status_label.text = "%s  ·  CAMERA %+d° / ±45°  ·  ZOOM %.1f  ·  %s  ·  %s" % [
		"PORTRAIT" if portrait else "LANDSCAPE", relative_yaw, camera_size,
		_last_direction.replace("_", "-").to_upper(), action_state
	]
	var near_npc := player.global_position.distance_to(NPC_POS) < 2.7
	interaction_prompt.visible = near_npc and not interaction_active
	if portrait:
		mobile_hint.text = "Safe-world drag: orbit   ·   Pinch: zoom"
		mobile_hint.position = Vector2(13.0, -28.0)
	else:
		mobile_hint.text = "WASD Move   ·   RMB/Drag Orbit   ·   Wheel/Pinch Zoom   ·   Space Attack"
		mobile_hint.position = Vector2(16.0, -35.0)


func _set_equipped(value: bool) -> void:
	equipped = value
	armor_sprite.visible = value
	hat_sprite.visible = value
	weapon_sprite.visible = value
	action_state = "EQUIPPED" if value else "BASE"


func _attack() -> void:
	if _monster_defeated:
		action_state = "TARGET DEFEATED · REWARD SECURED"
		return
	target_active = true
	combat_active = true
	target_ring.visible = true
	_damage_time = 0.65
	_attack_time = 1.0
	_monster_health = maxi(0, _monster_health - 12)
	damage_label.position = MONSTER_POS + Vector3(0.0, 3.15, 0.0)
	damage_label.modulate = Color("#fff2a6")
	damage_label.text = "12  HIT!"
	action_state = "STRIKE · 12 DAMAGE"
	if _monster_health == 0:
		_monster_defeated = true
		damage_label.text = "DEFEATED!"
		reward_label.visible = true
		target_ring.visible = false
		monster_sprite.modulate = Color(0.48, 0.48, 0.48, 0.55)
		monster_sprite.rotation_degrees.z = 78.0
		action_state = "VICTORY · +18 XP · LEAF MOTE"


func _reset_monster() -> void:
	_monster_health = 24
	_monster_defeated = false
	_damage_time = 0.0
	_attack_time = 0.0
	monster_sprite.visible = true
	monster_sprite.modulate = Color.WHITE
	monster_sprite.position = MONSTER_POS + Vector3(0.0, 1.08, 0.0)
	monster_sprite.rotation_degrees = Vector3.ZERO
	target_ring.visible = false
	reward_label.visible = false
	attack_vfx.visible = false
	damage_label.visible = false
	damage_label.modulate = Color("#fff2a6")
	action_state = "EXPLORE"


func _reset_capture_state() -> void:
	_reset_monster()
	target_active = false
	combat_active = false
	interaction_active = false
	if dialogue_panel:
		dialogue_panel.visible = false


func _is_safe_camera_drag(position: Vector2) -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false
	var normalized := Vector2(position.x / viewport_size.x, position.y / viewport_size.y)
	return normalized.y > 0.12 and normalized.y < 0.68 and normalized.x > 0.28


func _sprite(path: String, pixel_size: float, billboard: bool) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = load(path)
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if billboard else BaseMaterial3D.BILLBOARD_DISABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return sprite


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


func _emissive_material(color: Color) -> StandardMaterial3D:
	var mat := _material(color, false)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	return mat


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


func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color, override_mat: StandardMaterial3D = null) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	item.mesh = mesh
	item.position = pos
	item.scale = scale_value
	item.material_override = override_mat if override_mat else _material(color)
	parent.add_child(item)
	return item


func _cylinder(parent: Node3D, pos: Vector3, top_radius: float, bottom_radius: float, height: float, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = 12
	item.mesh = mesh
	item.position = pos
	item.material_override = _material(color)
	parent.add_child(item)
	return item


func _add_window(parent: Node3D, pos: Vector3, rot: Vector3) -> void:
	_box(parent, Vector3(1.18, 1.12, 0.16), pos, Color("#6a432a"), rot)
	var glass_pos := pos
	if absf(rot.y) > 0.1:
		glass_pos.x += 0.09 if pos.x > 0.0 else -0.09
	else:
		glass_pos.z += 0.09
	_box(parent, Vector3(0.84, 0.78, 0.17), glass_pos, Color("#7cc1c1"), rot)
	_box(parent, Vector3(0.12, 0.8, 0.19), glass_pos, Color("#e5d08d"), rot)
	_box(parent, Vector3(0.86, 0.12, 0.19), glass_pos, Color("#e5d08d"), rot)


func _add_path(pos: Vector3, size: Vector2, yaw: float) -> void:
	var path := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	path.mesh = plane
	path.position = pos
	path.rotation.y = yaw
	var mat := _material(Color("#eee0ad"), false)
	mat.albedo_texture = load(GAME + "world/terrain/materials/cobble_repeat_256.png")
	mat.uv1_scale = Vector3(maxf(1.0, size.x / 2.0), maxf(1.0, size.y / 2.0), 1.0)
	path.material_override = mat
	path.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(path)


func _add_fence_segment(pos: Vector3, yaw: float) -> void:
	var host := Node3D.new()
	host.position = pos
	host.rotation_degrees.y = yaw
	add_child(host)
	for x in [-1.0, 1.0]:
		_box(host, Vector3(0.18, 1.35, 0.18), Vector3(x, 0.68, 0.0), Color("#664127")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_sphere(host, Vector3(x, 1.42, 0.0), Vector3(0.15, 0.2, 0.15), Color("#d1a04c")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for y in [0.48, 0.95]:
		_box(host, Vector3(2.2, 0.14, 0.14), Vector3(0.0, y, 0.0), Color("#81512c")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _add_rock(pos: Vector3, scale_value: float) -> void:
	var host := Node3D.new()
	host.position = pos
	host.rotation_degrees.y = pos.x * 11.0
	add_child(host)
	_sphere(host, Vector3(0.0, 0.35 * scale_value, 0.0), Vector3(1.2, 0.68, 0.9) * scale_value, Color("#77746c")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sphere(host, Vector3(0.55, 0.2, 0.2), Vector3(0.55, 0.4, 0.5) * scale_value, Color("#918a78")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _add_ground_collision(size: Vector3) -> void:
	var host := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position.y = -0.12
	host.add_child(collision)
	add_child(host)


func _add_static_box(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var host := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = pos
	host.add_child(collision)
	parent.add_child(host)


func _add_static_cylinder(parent: Node3D, radius: float, height: float, pos: Vector3) -> void:
	var host := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	collision.position = pos
	host.add_child(collision)
	parent.add_child(host)


func _add_contact_shadow(parent: Node3D, radius: float, y: float) -> void:
	var shadow := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.012
	disc.radial_segments = 28
	shadow.mesh = disc
	shadow.position.y = y
	var mat := _material(Color(0.05, 0.08, 0.04, 0.55), false)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow.material_override = mat
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)


func _add_contact_shadow_at(pos: Vector3, radius: float) -> void:
	var host := Node3D.new()
	host.position = pos + Vector3(0.0, 0.02, 0.0)
	add_child(host)
	_add_contact_shadow(host, radius, 0.0)


func _add_nameplate(text: String, pos: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 34
	label.pixel_size = 0.0055
	label.modulate = color
	label.outline_size = 8
	add_child(label)


func _smoke_and_quit() -> void:
	await _wait_frames(4)
	print("M04.26_SMOKE PASS nodes=", get_tree().get_node_count())
	get_tree().quit()


func _profile_and_quit() -> void:
	await _set_viewport(Vector2i(1280, 720))
	await _stage(SPAWN, CAMERA_CENTER, 14.0, Vector3(0.0, 0.0, 1.0), "PROFILE")
	await _wait_frames(120)
	_fps_samples.clear()
	_draw_samples.clear()
	_frame_ms_samples.clear()
	await _wait_frames(240)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(COMPLETION_DIR))
	_write_performance_report(COMPLETION_DIR + "/performance_after.txt")
	print("M04.26_PROFILE PASS")
	get_tree().quit()


func _capture_completion_evidence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(COMPLETION_DIR))
	await _set_viewport(Vector2i(1280, 720))

	_reset_capture_state()
	await _stage(BUILDING_POS + Vector3(2.0, 0.8, 5.8), CAMERA_LEFT, 12.5, Vector3(-0.3, 0.0, -1.0), "BUILDING · LEFT")
	await _shot_to(COMPLETION_DIR, "01_building_left.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "02_building_center.png")
	camera_yaw = deg_to_rad(CAMERA_RIGHT)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "03_building_right.png")

	_reset_capture_state()
	await _stage(TREE_POS + Vector3(-3.0, 0.8, 4.5), CAMERA_LEFT, 11.8, Vector3(0.4, 0.0, -1.0), "TREE · LEFT")
	await _shot_to(COMPLETION_DIR, "04_tree_left.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "05_tree_center.png")
	camera_yaw = deg_to_rad(CAMERA_RIGHT)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "06_tree_right.png")
	await _stage(TREE_POS + Vector3(-0.7, 0.8, -1.0), CAMERA_LEFT, 11.0, Vector3(0.0, 0.0, 1.0), "TREE · OCCLUSION")
	await _wait_frames(24)
	await _shot_to(COMPLETION_DIR, "07_tree_occlusion.png")

	_reset_capture_state()
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.5, _facing_for_view("front"), "EQUIPMENT · FRONT")
	await _shot_to(COMPLETION_DIR, "08_equipment_front.png")
	character_facing = _facing_for_view("right")
	await _wait_frames(6)
	await _shot_to(COMPLETION_DIR, "09_equipment_side.png")
	character_facing = _facing_for_view("back")
	await _wait_frames(6)
	await _shot_to(COMPLETION_DIR, "10_equipment_back.png")
	action_state = "MOVEMENT"
	character_facing = _facing_for_view("front_right")
	await _wait_frames(6)
	await _shot_to(COMPLETION_DIR, "11_equipment_movement.png")

	_reset_capture_state()
	await _stage(MONSTER_POS + Vector3(-3.0, 0.8, 0.8), CAMERA_CENTER, 10.8, MONSTER_POS - (MONSTER_POS + Vector3(-3.0, 0.8, 0.8)), "ATTACK · ANTICIPATION")
	_attack()
	await _wait_frames(7)
	await _shot_to(COMPLETION_DIR, "12_equipment_attack.png")
	_reset_capture_state()
	camera_yaw = deg_to_rad(CAMERA_LEFT)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "13_monster_left_camera.png")
	camera_yaw = deg_to_rad(CAMERA_RIGHT)
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "14_monster_right_camera.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	target_ring.visible = true
	action_state = "TARGET ACQUIRED"
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "15_combat_target.png")
	_attack()
	await _wait_frames(2)
	await _shot_to(COMPLETION_DIR, "16_combat_hit.png")
	await _wait_frames(10)
	await _shot_to(COMPLETION_DIR, "17_combat_active.png")
	_attack()
	await _wait_frames(48)
	await _shot_to(COMPLETION_DIR, "18_combat_defeat_reward.png")

	_reset_capture_state()
	await _stage(NPC_POS + Vector3(2.25, 0.8, 1.05), CAMERA_CENTER, 10.8, NPC_POS - (NPC_POS + Vector3(2.25, 0.8, 1.05)), "NPC · APPROACH")
	await _shot_to(COMPLETION_DIR, "19_npc_approach.png")
	interaction_active = true
	dialogue_panel.visible = true
	action_state = "NPC · INTERACTION"
	await _wait_frames(5)
	await _shot_to(COMPLETION_DIR, "20_npc_interaction.png")
	interaction_active = false
	dialogue_panel.visible = false

	_reset_capture_state()
	await _stage(SPAWN, CAMERA_CENTER, 18.0, LANDMARK_POS - SPAWN, "SPAWN · LANDMARK")
	await _shot_to(COMPLETION_DIR, "21_landmark_from_spawn.png")
	_reset_capture_state()
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.5, _facing_for_view("front"), "PROGRESSION · BEFORE")
	_set_equipped(false)
	await _wait_frames(4)
	await _shot_to(COMPLETION_DIR, "22_progression_before.png")
	_set_equipped(true)
	action_state = "PROGRESSION · AFTER"
	await _wait_frames(4)
	await _shot_to(COMPLETION_DIR, "23_progression_after.png")

	_reset_monster()
	await _stage(Vector3(0.0, 0.8, 2.8), CAMERA_CENTER, 13.5, Vector3(0.0, 0.0, -1.0), "AMBERWAY · COMPLETE")
	await _shot_to(COMPLETION_DIR, "24_final_gameplay_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot_to(COMPLETION_DIR, "25_final_gameplay_portrait.png")
	print("M04.26_COMPLETION_CAPTURE PASS")
	get_tree().quit()


func _capture_evidence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts/m04_26"))
	await _set_viewport(Vector2i(1280, 720))
	await _stage(SPAWN, CAMERA_CENTER, 14.0, Vector3(0.0, 0.0, 1.0), "EXPLORE")
	await _shot("01_slice_landscape_default.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("02_slice_portrait_default.png")
	await _set_viewport(Vector2i(1280, 720))
	await _stage(SPAWN, CAMERA_CENTER, 13.0, Vector3(0.0, 0.0, -1.0), "SPAWN")
	await _shot("03_spawn_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("04_spawn_portrait.png")
	await _set_viewport(Vector2i(1280, 720))

	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_LEFT, 14.0, Vector3(0.0, 0.0, -1.0), "LEFT LIMIT")
	await _shot("05_camera_left_limit.png")
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 14.0, Vector3(0.0, 0.0, -1.0), "CENTER")
	await _shot("06_camera_center.png")
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_RIGHT, 14.0, Vector3(0.0, 0.0, -1.0), "RIGHT LIMIT")
	await _shot("07_camera_right_limit.png")
	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.0, Vector3(0.0, 0.0, -1.0), "NEAR")
	await _shot("08_zoom_near.png")
	camera_size = 14.0
	await _wait_frames(5)
	await _shot("09_zoom_mid.png")
	camera_size = 18.0
	await _wait_frames(5)
	await _shot("10_zoom_far.png")

	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.5, _facing_for_view("front"), "BASE")
	_set_equipped(false)
	await _wait_frames(4)
	await _shot("11_player_unequipped_front.png")
	_set_equipped(true)
	await _wait_frames(4)
	await _shot("12_player_equipped_front.png")
	for index in range(8):
		var filenames := [
			"13_equipment_front.png", "14_equipment_front_right.png",
			"15_equipment_right.png", "16_equipment_back_right.png",
			"17_equipment_back.png", "18_equipment_back_left.png",
			"19_equipment_left.png", "20_equipment_front_left.png"
		]
		await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.5, _facing_for_view(DIR_NAMES[index]), "GEAR · %s" % DIR_NAMES[index].to_upper())
		await _shot(filenames[index])
	await _stage(Vector3(1.6, 0.8, 3.0), CAMERA_CENTER, 11.0, _facing_for_view("right"), "MOVEMENT")
	await _shot("21_equipment_movement.png")
	await _stage(Vector3(2.8, 0.8, 5.7), CAMERA_CENTER, 10.5, MONSTER_POS - Vector3(2.8, 0.8, 5.7), "ATTACK")
	_attack()
	await _wait_frames(2)
	await _shot("22_equipment_attack.png")

	await _stage(BUILDING_POS + Vector3(2.0, 0.8, 5.8), CAMERA_LEFT, 13.0, Vector3(-0.3, 0.0, -1.0), "BUILDING · LEFT")
	await _shot("23_building_left_view.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	await _wait_frames(5)
	await _shot("24_building_center_view.png")
	camera_yaw = deg_to_rad(CAMERA_RIGHT)
	await _wait_frames(5)
	await _shot("25_building_right_view.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	camera_size = 11.5
	await _wait_frames(5)
	await _shot("26_building_player_scale.png")

	await _stage(TREE_POS + Vector3(-2.8, 0.8, 4.2), CAMERA_LEFT, 12.0, Vector3(0.4, 0.0, -1.0), "TREE · LEFT")
	await _shot("27_tree_left_view.png")
	camera_yaw = deg_to_rad(CAMERA_CENTER)
	await _wait_frames(5)
	await _shot("28_tree_center_view.png")
	camera_yaw = deg_to_rad(CAMERA_RIGHT)
	await _wait_frames(5)
	await _shot("29_tree_right_view.png")
	await _stage(TREE_POS + Vector3(-0.75, 0.8, -1.0), CAMERA_CENTER, 11.5, Vector3(0.0, 0.0, 1.0), "TREE OCCLUSION")
	await _wait_frames(25)
	await _shot("30_tree_occlusion.png")

	await _stage(NPC_POS + Vector3(0.8, 0.8, 2.0), CAMERA_CENTER, 11.0, Vector3(-0.3, 0.0, -1.0), "APPROACH NPC")
	await _shot("31_npc_approach.png")
	interaction_active = true
	dialogue_panel.visible = true
	action_state = "INTERACTION"
	await _wait_frames(4)
	await _shot("32_npc_interaction.png")
	interaction_active = false
	dialogue_panel.visible = false

	await _stage(MONSTER_POS + Vector3(-3.3, 0.8, 0.8), CAMERA_CENTER, 12.5, Vector3(1.0, 0.0, -0.2), "COMBAT ENTRY")
	target_ring.visible = false
	await _shot("33_combat_entry.png")
	target_active = true
	target_ring.visible = true
	action_state = "TARGET LOCKED"
	await _wait_frames(4)
	await _shot("34_combat_target.png")
	_attack()
	await _wait_frames(2)
	await _shot("35_combat_active_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	_attack()
	await _wait_frames(2)
	await _shot("36_combat_active_portrait.png")
	await _set_viewport(Vector2i(1280, 720))

	await _stage(Vector3(0.0, 0.8, 5.0), CAMERA_CENTER, 16.0, Vector3(0.0, 0.0, -1.0), "OPEN TRAVERSAL")
	await _shot("37_open_traversal_space.png")
	await _stage(Vector3(-8.2, 0.8, 2.0), CAMERA_CENTER, 15.0, Vector3(0.0, 0.0, -1.0), "PERIMETER DENSITY")
	await _shot("38_environment_density.png")
	await _stage(LANDMARK_POS + Vector3(0.0, 0.8, 5.8), CAMERA_CENTER, 13.0, Vector3(0.0, 0.0, -1.0), "WAYSTONE LANDMARK")
	await _shot("39_landmark_readability.png")

	await _stage(Vector3(0.0, 0.8, 3.5), CAMERA_CENTER, 10.5, _facing_for_view("front"), "PROGRESSION · BEFORE")
	_set_equipped(false)
	await _wait_frames(4)
	await _shot("40_progression_before.png")
	_set_equipped(true)
	action_state = "PROGRESSION · AFTER"
	await _wait_frames(4)
	await _shot("41_progression_after.png")
	await _stage(Vector3(0.0, 0.8, 2.8), CAMERA_CENTER, 14.0, Vector3(0.0, 0.0, -1.0), "AMBERWAY LOOP")
	await _shot("42_final_gameplay_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("43_final_gameplay_portrait.png")
	_write_performance_report()
	print("M04.26_CAPTURE PASS")
	get_tree().quit()


func _facing_for_view(direction: String) -> Vector3:
	var relative_angle := float(DIR_NAMES.find(direction)) * TAU / 8.0
	var world_angle := camera_yaw + relative_angle
	return Vector3(sin(world_angle), 0.0, cos(world_angle)).normalized()


func _stage(pos: Vector3, yaw_degrees: float, zoom: float, facing: Vector3, state: String) -> void:
	player.position = pos
	camera_yaw = deg_to_rad(yaw_degrees)
	camera_size = zoom
	character_facing = Vector3(facing.x, 0.0, facing.z).normalized()
	action_state = state
	_last_direction = ""
	await _wait_frames(7)


func _set_viewport(size: Vector2i) -> void:
	get_window().size = size
	get_window().content_scale_size = size
	await _wait_frames(9)


func _shot(filename: String) -> void:
	await _shot_to("res://artifacts/m04_26", filename)


func _shot_to(directory: String, filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("%s/%s" % [directory, filename])
	var error := image.save_png(path)
	if error != OK:
		push_error("M04.26 screenshot failed: %s (%s)" % [path, error])
	print("M04.26 screenshot saved: ", path)
	await _wait_frames(3)


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _write_performance_report(path := "res://artifacts/m04_26/performance.txt") -> void:
	var avg_fps := _average_float(_fps_samples)
	var avg_draws := _average_int(_draw_samples)
	var avg_frame_ms := _average_float(_frame_ms_samples)
	var counts := _render_resource_counts()
	var text := "real_device_test=BLOCKED BY REAL DEVICE\nnode_count=%d\naverage_fps=%.2f\naverage_frame_process_ms=%.3f\naverage_draw_calls=%.2f\nunique_materials=%d\ntransparent_geometry=%d\nshadow_casters=%d\nmesh_instances=%d\nsprite3d_instances=%d\nrenderer=%s\ncamera_yaw_range_degrees=%d\n" % [
		get_tree().get_node_count(), avg_fps, avg_frame_ms, avg_draws,
		counts.materials, counts.transparent, counts.shadows,
		counts.meshes, counts.sprites, RenderingServer.get_video_adapter_name(),
		int(CAMERA_RIGHT - CAMERA_LEFT)
	]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(text)


func _render_resource_counts() -> Dictionary:
	var material_ids := {}
	var transparent := 0
	var shadows := 0
	var meshes := 0
	var sprites := 0
	for node in find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		if geometry == null:
			continue
		if geometry.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			shadows += 1
		if geometry is Sprite3D:
			sprites += 1
			transparent += 1
		if geometry is MeshInstance3D:
			meshes += 1
			var mesh_instance := geometry as MeshInstance3D
			var material := mesh_instance.material_override as BaseMaterial3D
			if material:
				material_ids[material.get_instance_id()] = true
				if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
					transparent += 1
	return {
		"materials": material_ids.size(),
		"transparent": transparent,
		"shadows": shadows,
		"meshes": meshes,
		"sprites": sprites
	}


func _average_float(values: Array[float]) -> float:
	var result := 0.0
	for value in values:
		result += value
	return result / maxf(float(values.size()), 1.0)


func _average_int(values: Array[int]) -> float:
	var result := 0.0
	for value in values:
		result += value
	return result / maxf(float(values.size()), 1.0)
