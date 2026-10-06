class_name BrambleHybridWorld3D
extends Node3D

# Kein-Name -> Godot hybrid renderer port.
# Gameplay/authority keeps using the existing planar Vector2 simulation.
# This node is presentation only: simulation X/Y maps to 3D X/Z and Y is elevation.

const WORLD_SCALE := 0.01
const MIN_CAMERA_DISTANCE := 8.8
const MAX_CAMERA_DISTANCE := 21.0
const MIN_PITCH := deg_to_rad(18.0)
const MAX_PITCH := deg_to_rad(76.0)
const DEFAULT_PITCH := deg_to_rad(50.0)
const DEFAULT_DISTANCE := 14.8
const PLAYER_BILLBOARD_PIXEL_SIZE := 0.0043
const ENEMY_BILLBOARD_PIXEL_SIZE := 0.0045
const NPC_BILLBOARD_PIXEL_SIZE := 0.0042

var camera: Camera3D
var _camera_target := Vector3.ZERO
var _desired_yaw := 0.0
var _desired_pitch := DEFAULT_PITCH
var _yaw := 0.0
var _pitch := DEFAULT_PITCH
var _camera_distance := DEFAULT_DISTANCE
var _desired_camera_distance := DEFAULT_DISTANCE

var _player: CharacterBody2D
var _player_proxy: Sprite3D
var _entity_proxies: Dictionary = {}
var _static_root: Node3D
var _dynamic_root: Node3D

var _touches: Dictionary = {}
var _last_pinch_distance := -1.0
var _mouse_orbiting := false
var _active := false

func _ready() -> void:
	add_to_group("hybrid_world_3d")
	_build_environment()
	_build_world_geometry()
	_build_static_billboards()
	_build_dynamic_root()
	call_deferred("_activate")
	set_process(true)
	set_process_unhandled_input(true)

func _activate() -> void:
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _player == null:
		return
	var old_world := get_tree().current_scene.get_node_or_null("VisualMasterWorld") as CanvasItem
	if old_world:
		old_world.visible = false
	var old_camera := _player.get_node_or_null("Camera2D") as Camera2D
	if old_camera:
		old_camera.enabled = false
	var old_visual := _player.get_node_or_null("Visual") as CanvasItem
	if old_visual:
		old_visual.visible = false
	_ensure_player_proxy()
	_camera_target = simulation_to_world(_player.global_position, 0.75)
	var desired := _desired_camera_position(_camera_target)
	camera.global_position = desired
	camera.look_at(_camera_target, Vector3.UP)
	_active = true

func is_active() -> bool:
	return _active and visible

func camera_yaw() -> float:
	return _yaw

func camera_relative_move(input_vec: Vector2) -> Vector2:
	# Ported from Kein Name's cameraRelativeMovement().
	# Stick-up remains screen-up after orbiting the perspective camera.
	var c := cos(_yaw)
	var s := sin(_yaw)
	return Vector2(
		input_vec.x * c + input_vec.y * s,
		-input_vec.x * s + input_vec.y * c
	)

func simulation_to_world(sim: Vector2, elevation := 0.0) -> Vector3:
	return Vector3(sim.x * WORLD_SCALE, elevation, sim.y * WORLD_SCALE)

func world_to_simulation(world: Vector3) -> Vector2:
	return Vector2(world.x / WORLD_SCALE, world.z / WORLD_SCALE)

func screen_to_simulation(screen_pos: Vector2) -> Vector2:
	if camera == null:
		return Vector2.INF
	var origin := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)
	if absf(direction.y) < 0.00001:
		return Vector2.INF
	var t := -origin.y / direction.y
	if t < 0.0:
		return Vector2.INF
	var hit := origin + direction * t
	return world_to_simulation(hit)

func reset_follow_camera() -> void:
	_desired_yaw = 0.0
	_desired_pitch = DEFAULT_PITCH
	_desired_camera_distance = DEFAULT_DISTANCE

func set_zoom_distance(value: float) -> void:
	_desired_camera_distance = clampf(value, MIN_CAMERA_DISTANCE, MAX_CAMERA_DISTANCE)

func zoom_by(delta: float) -> void:
	set_zoom_distance(_desired_camera_distance + delta)

func _process(delta: float) -> void:
	if not _active or _player == null or not is_instance_valid(_player):
		return
	_sync_dynamic_proxies()
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	var player_world := simulation_to_world(_player.global_position, 0.78)
	var sim_velocity := _player.velocity
	var look_ahead := Vector3.ZERO
	if sim_velocity.length() > 8.0:
		look_ahead = Vector3(sim_velocity.x, 0.0, sim_velocity.y).normalized() * minf(1.6, sim_velocity.length() * WORLD_SCALE * 0.34)
	var anchor := player_world + look_ahead
	var target_alpha := 1.0 - exp(-delta * 7.5)
	_camera_target = _camera_target.lerp(anchor, target_alpha)
	_yaw = _damp_angle(_yaw, _desired_yaw, 1.0 - exp(-delta * 8.0))
	_pitch = lerpf(_pitch, _desired_pitch, 1.0 - exp(-delta * 8.0))
	_camera_distance = lerpf(_camera_distance, _desired_camera_distance, 1.0 - exp(-delta * 7.0))
	var desired := _desired_camera_position(_camera_target)
	camera.global_position = camera.global_position.lerp(desired, 1.0 - exp(-delta * 9.0))
	camera.look_at(_camera_target, Vector3.UP)

func _desired_camera_position(target: Vector3) -> Vector3:
	var horizontal := _camera_distance * cos(_pitch)
	return Vector3(
		target.x + sin(_yaw) * horizontal,
		target.y + _camera_distance * sin(_pitch),
		target.z + cos(_yaw) * horizontal
	)

func _damp_angle(from: float, to: float, weight: float) -> float:
	var diff := wrapf(to - from, -PI, PI)
	return from + diff * weight

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_LEFT:
			_mouse_orbiting = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(-0.9)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(0.9)
	elif event is InputEventMouseMotion and _mouse_orbiting:
		_orbit_by(event.relative)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
			if event.double_tap:
				reset_follow_camera()
		else:
			_touches.erase(event.index)
			_last_pinch_distance = -1.0
	elif event is InputEventScreenDrag:
		var previous: Vector2 = _touches.get(event.index, event.position - event.relative)
		_touches[event.index] = event.position
		if _touches.size() >= 2:
			var keys := _touches.keys()
			var a: Vector2 = _touches[keys[0]]
			var b: Vector2 = _touches[keys[1]]
			var pinch := a.distance_to(b)
			if _last_pinch_distance > 0.0:
				zoom_by((_last_pinch_distance - pinch) * 0.018)
			_last_pinch_distance = pinch
		else:
			_last_pinch_distance = -1.0
			_orbit_by(event.position - previous)

func _orbit_by(delta_screen: Vector2) -> void:
	var dx := clampf(delta_screen.x, -96.0, 96.0)
	var dy := clampf(delta_screen.y, -96.0, 96.0)
	_desired_yaw = wrapf(_desired_yaw - dx * 0.0042, -PI, PI)
	_desired_pitch = clampf(_desired_pitch + dy * 0.0028, MIN_PITCH, MAX_PITCH)

func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#8eb8c7")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#dbe6d1")
	env.ambient_light_energy = 0.78
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-55.0, -28.0, 0.0)
	sun.light_energy = 1.25
	sun.light_color = Color("#fff0cf")
	sun.shadow_enabled = true
	add_child(sun)

	camera = Camera3D.new()
	camera.name = "HybridCamera3D"
	camera.current = true
	camera.fov = 46.0
	camera.near = 0.1
	camera.far = 120.0
	add_child(camera)

func _build_world_geometry() -> void:
	_static_root = Node3D.new()
	_static_root.name = "WorldGeometry"
	add_child(_static_root)

	var bounds := BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS
	var center := bounds.position + bounds.size * 0.5
	_add_plane(
		"Ground",
		simulation_to_world(center, 0.0),
		Vector2(bounds.size.x * WORLD_SCALE, bounds.size.y * WORLD_SCALE),
		Color("#667b42")
	)
	# Main road and village cross-road.
	_add_box("MainRoad", simulation_to_world(Vector2(310, 140), 0.025), Vector3(14.6, 0.035, 0.86), Color("#aa8d62"))
	_add_box("CrossRoad", simulation_to_world(Vector2(-180, -20), 0.028), Vector3(0.82, 0.04, 4.9), Color("#a98b61"))
	# River is real world-space geometry instead of a flat background texture.
	_add_box("River", simulation_to_world(Vector2(300, 420), 0.035), Vector3(22.0, 0.045, 1.10), Color("#3d8da2"))
	_add_box("Bridge", simulation_to_world(Vector2(260, 420), 0.18), Vector3(1.75, 0.28, 1.35), Color("#8c6541"))
	# Small authored height masses create actual parallax/occlusion.
	_add_box("ShrineLedge", simulation_to_world(Vector2(-670, -390), 0.38), Vector3(3.0, 0.76, 1.75), Color("#58623d"))
	_add_box("WildsRise", simulation_to_world(Vector2(1130, -330), 0.22), Vector3(4.2, 0.44, 1.65), Color("#5c7040"))

func _build_static_billboards() -> void:
	# Same Bramble authored places, now positioned in the perspective world.
	_add_landmark("world/buildings/inn.png", Vector2(-500, -105), 0.0052, 0.05)
	_add_landmark("world/buildings/workshop.png", Vector2(-180, -130), 0.0048, 0.05)
	_add_landmark("world/buildings/cottage.png", Vector2(220, -105), 0.0047, 0.05)
	_add_landmark("world/buildings/town_fountain.png", Vector2(-20, 70), 0.0046, 0.03)
	_add_landmark("world/buildings/red_oak.png", Vector2(-735, -90), 0.0050, 0.04)
	_add_landmark("world/buildings/apple_tree.png", Vector2(465, -190), 0.0048, 0.04)
	_add_landmark("world/buildings/town_gate.png", Vector2(585, 95), 0.0047, 0.04)
	_add_landmark("world/portals/portal_arch_active.png", Vector2(735, 120), 0.0051, 0.04)
	_add_landmark("world/buildings/ruined_arch.png", Vector2(1110, -185), 0.0048, 0.04)
	for p in [Vector2(935, -190), Vector2(1320, 15), Vector2(1280, 345)]:
		_add_landmark("world/buildings/red_oak.png", p, 0.0049, 0.04)

func _build_dynamic_root() -> void:
	_dynamic_root = Node3D.new()
	_dynamic_root.name = "DynamicBillboards"
	add_child(_dynamic_root)

func _ensure_player_proxy() -> void:
	if _player_proxy:
		return
	_player_proxy = Sprite3D.new()
	_player_proxy.name = "PlayerBillboard3D"
	_player_proxy.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_player_proxy.pixel_size = PLAYER_BILLBOARD_PIXEL_SIZE
	_player_proxy.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_dynamic_root.add_child(_player_proxy)

func _sync_dynamic_proxies() -> void:
	_ensure_player_proxy()
	_sync_player_proxy()
	var alive_ids: Dictionary = {}
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not (enemy is Node2D):
			continue
		var id := enemy.get_instance_id()
		alive_ids[id] = true
		var proxy: Sprite3D = _entity_proxies.get(id)
		if proxy == null:
			proxy = Sprite3D.new()
			proxy.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			proxy.pixel_size = ENEMY_BILLBOARD_PIXEL_SIZE
			proxy.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			_dynamic_root.add_child(proxy)
			_entity_proxies[id] = proxy
		proxy.position = simulation_to_world(enemy.global_position, 0.78)
		proxy.visible = enemy.visible and (not enemy.has_method("is_combat_alive") or enemy.is_combat_alive())
		var source := enemy.get_node_or_null("Visual") as AnimatedSprite2D
		if source and source.sprite_frames and source.sprite_frames.has_animation(source.animation):
			proxy.texture = source.sprite_frames.get_frame_texture(source.animation, source.frame)
		elif proxy.texture == null:
			proxy.texture = BrambleWorldPresentationConfig.game_tex("monsters/moorling/directions/kit60_front.png")
	for id in _entity_proxies.keys():
		if not alive_ids.has(id):
			var stale: Sprite3D = _entity_proxies[id]
			if is_instance_valid(stale):
				stale.queue_free()
			_entity_proxies.erase(id)

func _sync_player_proxy() -> void:
	if _player_proxy == null or _player == null:
		return
	_player_proxy.position = simulation_to_world(_player.global_position, 0.88)
	var source := _player.get_node_or_null("Visual") as AnimatedSprite2D
	if source and source.sprite_frames and source.sprite_frames.has_animation(source.animation):
		_player_proxy.texture = source.sprite_frames.get_frame_texture(source.animation, source.frame)
		_player_proxy.flip_h = source.flip_h
	elif _player_proxy.texture == null:
		_player_proxy.texture = BrambleWorldPresentationConfig.game_tex("characters/base/male/directions/front.png")

func _add_landmark(path: String, sim_position: Vector2, pixel_size: float, base_y: float) -> void:
	var texture := BrambleWorldPresentationConfig.game_tex(path)
	if texture == null:
		return
	var sprite := Sprite3D.new()
	sprite.texture = texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.pixel_size = pixel_size
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	var height := float(texture.get_height()) * pixel_size
	sprite.position = simulation_to_world(sim_position, base_y + height * 0.5)
	_static_root.add_child(sprite)

func _add_plane(node_name: String, world_position: Vector3, size: Vector2, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var plane := PlaneMesh.new()
	plane.size = size
	mesh_instance.mesh = plane
	mesh_instance.position = world_position
	mesh_instance.material_override = _material(color)
	_static_root.add_child(mesh_instance)

func _add_box(node_name: String, world_position: Vector3, size: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = world_position
	mesh_instance.material_override = _material(color)
	_static_root.add_child(mesh_instance)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material
