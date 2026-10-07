class_name BrambleHybridWorld3D
extends Node3D

# Kein-Name -> Godot hybrid renderer port.
# Gameplay/authority keeps using the existing planar Vector2 simulation.
# This node is presentation only: simulation X/Y maps to 3D X/Z and Y is elevation.

# Keep the same planar-to-spatial contract as Kein Name:
# 100 simulation units == 1 rendered metre.
const WORLD_SCALE := 0.01

# Direct port of Kein Name's HybridCameraController defaults.
const MIN_CAMERA_DISTANCE := 9.5
const MAX_CAMERA_DISTANCE := 22.0
const MIN_PITCH := deg_to_rad(16.0)
const MAX_PITCH := deg_to_rad(78.0)
const DEFAULT_PITCH := deg_to_rad(52.0)
const DEFAULT_DISTANCE := 16.8
const CAMERA_FOV := 48.0

# Character sizes are authored in world metres, never raw source pixels.
# Kein Name's hero presentation uses a 2.45 m world-space sprite.
const PLAYER_WORLD_HEIGHT := 2.45
const NPC_WORLD_HEIGHT := 2.10
const ENEMY_WORLD_HEIGHT := 2.35
const LOOT_WORLD_HEIGHT := 0.70
const PORTAL_WORLD_HEIGHT := 3.80
const VISUAL_GROUND_MIN_SIZE := Vector2(70.0, 58.0)
const HYBRID_ACTOR_RADIUS := 38.0

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
var _player_shadow: MeshInstance3D
var _player_ground_ring: MeshInstance3D
var _entity_proxies: Dictionary = {}
var _static_root: Node3D
var _dynamic_root: Node3D
var _last_player_world_direction := Vector2(0, 1)
var _player_view_direction := "front"
var _view_candidate := ""
var _view_candidate_time := 0.0
var _motion_time := 0.0
var _attack_visual_remaining := 0.0
var _was_attacking := false
var _occluders: Array[Dictionary] = []
var _hybrid_colliders: Array[Dictionary] = []

var _touches: Dictionary = {}
var _last_pinch_distance := -1.0
var _mouse_orbiting := false
var _active := false

func _ready() -> void:
	add_to_group("hybrid_world_3d")
	_build_environment()
	_build_world_geometry()
	_build_static_world()
	_build_collision_model()
	_build_visible_world_boundary()
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
	# Legacy Bramble used collision layer 4 for hidden 2D scenery. In the
	# hybrid renderer that geometry is no longer authoritative and caused
	# invisible walls that did not match the visible 3D world.
	_player.collision_mask = _player.collision_mask & ~4
	_hide_2d_source_presentation()
	_ensure_player_proxy()
	_camera_target = simulation_to_world(_player.global_position, 0.72)
	var desired := _desired_camera_position(_camera_target)
	camera.global_position = desired
	camera.look_at(_camera_target, Vector3.UP)
	_active = true

func is_active() -> bool:
	return _active

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

func resolve_simulation_position(position: Vector2) -> Vector2:
	var bounds := BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS
	var resolved := Vector2(
		clampf(position.x, bounds.position.x + HYBRID_ACTOR_RADIUS, bounds.end.x - HYBRID_ACTOR_RADIUS),
		clampf(position.y, bounds.position.y + HYBRID_ACTOR_RADIUS, bounds.end.y - HYBRID_ACTOR_RADIUS)
	)
	for collider in _hybrid_colliders:
		var shape := String(collider.get("shape", "box"))
		var center: Vector2 = collider.get("center", Vector2.ZERO)
		if shape == "circle":
			resolved = _resolve_circle_collider(resolved, center, float(collider.get("radius", 0.0)) + HYBRID_ACTOR_RADIUS)
		else:
			resolved = _resolve_box_collider(
				resolved,
				center,
				float(collider.get("half_width", 0.0)) + HYBRID_ACTOR_RADIUS,
				float(collider.get("half_depth", 0.0)) + HYBRID_ACTOR_RADIUS
			)
	return Vector2(
		clampf(resolved.x, bounds.position.x + HYBRID_ACTOR_RADIUS, bounds.end.x - HYBRID_ACTOR_RADIUS),
		clampf(resolved.y, bounds.position.y + HYBRID_ACTOR_RADIUS, bounds.end.y - HYBRID_ACTOR_RADIUS)
	)

func _resolve_circle_collider(point: Vector2, center: Vector2, radius: float) -> Vector2:
	var delta := point - center
	var distance := delta.length()
	if distance >= radius:
		return point
	if distance < 0.001:
		return center + Vector2(radius, 0)
	return center + delta / distance * radius

func _resolve_box_collider(point: Vector2, center: Vector2, half_width: float, half_depth: float) -> Vector2:
	var dx := point.x - center.x
	var dy := point.y - center.y
	if absf(dx) >= half_width or absf(dy) >= half_depth:
		return point
	var x_pen := half_width - absf(dx)
	var y_pen := half_depth - absf(dy)
	if x_pen < y_pen:
		return Vector2(center.x + (half_width if dx >= 0.0 else -half_width), point.y)
	return Vector2(point.x, center.y + (half_depth if dy >= 0.0 else -half_depth))

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
	_motion_time += minf(delta, 0.05)
	_sync_dynamic_proxies(delta)
	_update_camera(delta)
	_update_occluders(delta)

func _update_camera(delta: float) -> void:
	var player_world := simulation_to_world(_player.global_position, 0.72)
	var sim_velocity := _player.velocity
	var look_ahead := Vector3.ZERO
	# Kein Name uses velocity * .00072. Preserve that rather than inventing
	# a normalized camera offset; slow and fast movement then compose naturally.
	if sim_velocity.length() > 10.0:
		look_ahead = Vector3(sim_velocity.x * 0.00072, 0.0, sim_velocity.y * 0.00072)
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
			if event.pressed:
				_mouse_orbiting = not _hud_blocks_input(event.position)
			else:
				_mouse_orbiting = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP and not _hud_blocks_input(event.position):
			zoom_by(-0.9)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and not _hud_blocks_input(event.position):
			zoom_by(0.9)
	elif event is InputEventMouseMotion and _mouse_orbiting:
		_orbit_by(event.relative)
	elif event is InputEventScreenTouch:
		if event.pressed:
			# Exactly like Kein Name's cameraGestureAllowedFromTarget(): a finger
			# that starts on joystick/combat/HUD never becomes a camera pointer.
			if _hud_blocks_input(event.position):
				return
			_touches[event.index] = event.position
			if event.double_tap:
				reset_follow_camera()
		else:
			_touches.erase(event.index)
			_last_pinch_distance = -1.0
	elif event is InputEventScreenDrag:
		# Do not adopt a drag halfway through. Only pointers that began in the
		# world surface are allowed to orbit or pinch.
		if not _touches.has(event.index):
			return
		var previous: Vector2 = _touches[event.index]
		_touches[event.index] = event.position
		if _touches.size() >= 2:
			var keys := _touches.keys()
			var a: Vector2 = _touches[keys[0]]
			var b: Vector2 = _touches[keys[1]]
			var pinch := a.distance_to(b)
			if _last_pinch_distance > 0.0 and absf(pinch - _last_pinch_distance) > 3.0:
				# Kein Name uses a very small pinch delta. Scale this to the
				# Godot zoom-distance units without the previous jumpiness.
				zoom_by((_last_pinch_distance - pinch) * 0.0025 * 12.0)
			_last_pinch_distance = pinch
		else:
			_last_pinch_distance = -1.0
			_orbit_by(event.position - previous)

func _hud_blocks_input(screen_position: Vector2) -> bool:
	var hud = get_tree().get_first_node_in_group("production_hud")
	if hud and hud.has_method("camera_input_blocked_at"):
		return bool(hud.camera_input_blocked_at(screen_position))
	return false

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
	# Kein Name Harvest Haven uses a restrained slate sky instead of a bright
	# empty blue void. The warm geometry/light carries the readable foreground.
	env.background_color = Color("#283247")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#c0d6eb")
	env.ambient_light_energy = 0.92
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-55.0, -28.0, 0.0)
	sun.light_energy = 1.75
	sun.light_color = Color("#ffd6ad")
	sun.shadow_enabled = true
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "CoolFill"
	fill.rotation_degrees = Vector3(-38.0, 148.0, 0.0)
	fill.light_energy = 0.48
	fill.light_color = Color("#6d86b9")
	fill.shadow_enabled = false
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "HybridCamera3D"
	camera.fov = CAMERA_FOV
	camera.near = 0.1
	camera.far = 120.0
	add_child(camera)
	camera.make_current()

func _build_world_geometry() -> void:
	_static_root = Node3D.new()
	_static_root.name = "WorldGeometry"
	add_child(_static_root)

	var bounds := BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS
	var center := bounds.position + bounds.size * 0.5
	var authored_size := Vector2(bounds.size.x * WORLD_SCALE, bounds.size.y * WORLD_SCALE)
	# Bramble's old 2D slice is much shallower than Kein Name's 32x28 m Haven.
	# The renderer therefore carries a visual terrain apron around the gameplay
	# bounds so the 16.8 m follow camera always stands above world, never void.
	var ground_size := Vector2(
		maxf(VISUAL_GROUND_MIN_SIZE.x, authored_size.x + 12.0),
		maxf(VISUAL_GROUND_MIN_SIZE.y, authored_size.y + 18.0)
	)
	_add_plane("Ground", simulation_to_world(center, 0.0), ground_size, Color("#465044"))

	# Haven-like plaza + connected roads. These are genuine meshes so camera
	# orbit creates parallax and scale instead of sliding a flat background.
	_add_disc("VillagePlaza", simulation_to_world(Vector2(-20, 70), 0.055), 4.1, 0.16, Color("#55595a"))
	_add_box("VillageRoadEW", simulation_to_world(Vector2(20, 115), 0.08), Vector3(18.6, 0.11, 2.35), Color("#4a4d50"))
	_add_box("VillageRoadNS", simulation_to_world(Vector2(-20, 300), 0.082), Vector3(2.25, 0.11, 8.9), Color("#4a4d50"))
	_add_box("EastApproach", simulation_to_world(Vector2(720, 125), 0.085), Vector3(7.8, 0.11, 2.15), Color("#55565a"))

	# South field mass and water follow Kein Name's readable layered ground:
	# thin geometry, no giant vertical debug blocks.
	_add_box("SouthField", simulation_to_world(Vector2(100, 500), 0.035), Vector3(19.0, 0.055, 3.1), Color("#3a4638"))
	for x in [-650.0, -400.0, -150.0, 100.0, 350.0, 600.0, 850.0]:
		_add_box("Furrow", simulation_to_world(Vector2(x, 505), 0.07), Vector3(0.08, 0.025, 2.75), Color("#293528"))
	_add_box("River", simulation_to_world(Vector2(300, 420), 0.045), Vector3(25.0, 0.035, 1.85), Color("#315b71"))
	_add_box("Bridge", simulation_to_world(Vector2(260, 420), 0.17), Vector3(2.35, 0.24, 2.15), Color("#785a3c"))

func _build_static_world() -> void:
	# Kein Name's Haven buildings are real geometry. Use the same principle here
	# and reserve billboards for characters, monsters and a few stylised accents.
	_add_building("GuildHall", Vector2(0, -520), 4.9, 3.5, 2.55, Color("#565160"), Color("#263048"), 0.0)
	_add_building("Inn", Vector2(-620, -260), 3.8, 2.90, 2.30, Color("#565160"), Color("#263048"), 0.18)
	_add_building("Workshop", Vector2(620, -220), 3.70, 2.90, 2.20, Color("#4a4240"), Color("#6b3528"), -0.16, true)
	_add_building("WestHouse", Vector2(-720, 300), 3.30, 2.70, 2.10, Color("#4b5360"), Color("#263048"), 0.08)
	_add_building("EastHouse", Vector2(740, 320), 3.30, 2.70, 2.10, Color("#4b5360"), Color("#263048"), -0.10)
	_add_fountain(Vector2(-20, 70))
	_add_arch("WestGate", Vector2(-1010, 650), 2.8, 3.0, Color("#555866"))
	_add_arch("FarmArch", Vector2(0, 690), 3.0, 3.2, Color("#4b4e58"))

	for spec in [
		[Vector2(-1150, -100), 1.0],
		[Vector2(-1030, 700), 0.88],
		[Vector2(-820, 200), 0.92],
		[Vector2(-930, 820), 0.86],
		[Vector2(890, 500), 0.94],
		[Vector2(1010, 940), 0.88],
		[Vector2(1180, 800), 0.96],
		[Vector2(1290, 1060), 0.84],
		[Vector2(-1450, 1180), 0.90],
		[Vector2(1480, -920), 0.92],
		[Vector2(-1600, -1050), 0.84],
		[Vector2(1600, 1200), 0.88],
	]:
		_add_tree(spec[0], spec[1])

	_add_world_billboard("world/portals/portal_arch_active.png", Vector2(735, 120), PORTAL_WORLD_HEIGHT, 0.04)

func _build_collision_model() -> void:
	_hybrid_colliders.clear()
	# Collider sizes are derived from the visible 3D geometry above. There are
	# intentionally no hidden legacy blockers and no colliders on decorative
	# trees/arches, following Kein Name's authored-collider approach.
	_register_box_collider(Vector2(-620, -260), 190.0, 145.0)
	_register_box_collider(Vector2(620, -220), 185.0, 145.0)
	_register_box_collider(Vector2(-720, 300), 165.0, 135.0)
	_register_box_collider(Vector2(740, 320), 165.0, 135.0)
	_register_box_collider(Vector2(0, -520), 245.0, 175.0)
	_register_circle_collider(Vector2(-20, 70), 122.0)

	# Water is visibly non-walkable except for the bridge opening.
	_register_box_collider(Vector2(-404, 420), 546.0, 92.0)
	_register_box_collider(Vector2(964, 420), 586.0, 92.0)

func _register_box_collider(center: Vector2, half_width: float, half_depth: float) -> void:
	_hybrid_colliders.append({
		"shape": "box",
		"center": center,
		"half_width": half_width,
		"half_depth": half_depth,
	})

func _register_circle_collider(center: Vector2, radius: float) -> void:
	_hybrid_colliders.append({
		"shape": "circle",
		"center": center,
		"radius": radius,
	})

func _build_visible_world_boundary() -> void:
	# The playable edge must always have a visible reason to stop. These low
	# hedge/cliff bands sit exactly on the simulation bounds and replace the
	# old invisible clamp.
	var bounds := BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS
	var center := bounds.position + bounds.size * 0.5
	var half_w := bounds.size.x * WORLD_SCALE * 0.5
	var half_d := bounds.size.y * WORLD_SCALE * 0.5
	var thickness := 0.55
	var height := 1.15
	var edge_color := Color("#344632")
	_add_box("NorthBoundary", Vector3(center.x * WORLD_SCALE, height * 0.5, (bounds.position.y + 10.0) * WORLD_SCALE), Vector3(half_w * 2.0, height, thickness), edge_color)
	_add_box("SouthBoundary", Vector3(center.x * WORLD_SCALE, height * 0.5, (bounds.end.y - 10.0) * WORLD_SCALE), Vector3(half_w * 2.0, height, thickness), edge_color)
	_add_box("WestBoundary", Vector3((bounds.position.x + 10.0) * WORLD_SCALE, height * 0.5, center.y * WORLD_SCALE), Vector3(thickness, height, half_d * 2.0), edge_color)
	_add_box("EastBoundary", Vector3((bounds.end.x - 10.0) * WORLD_SCALE, height * 0.5, center.y * WORLD_SCALE), Vector3(thickness, height, half_d * 2.0), edge_color)

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
	_player_proxy.shaded = false
	_player_proxy.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_dynamic_root.add_child(_player_proxy)

	_player_shadow = _disc_mesh(0.58, 0.018, Color(0.02, 0.03, 0.04, 0.42))
	_player_shadow.name = "PlayerShadow"
	_dynamic_root.add_child(_player_shadow)
	_player_ground_ring = _disc_mesh(0.68, 0.010, Color(0.25, 0.68, 0.82, 0.18))
	_player_ground_ring.name = "PlayerGroundRing"
	_dynamic_root.add_child(_player_ground_ring)

func _sync_dynamic_proxies(delta: float) -> void:
	_ensure_player_proxy()
	_sync_player_proxy(delta)
	var alive_ids: Dictionary = {}

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not (enemy is Node2D):
			continue
		var id := enemy.get_instance_id()
		alive_ids[id] = true
		var proxy := _entity_sprite(id, ENEMY_WORLD_HEIGHT)
		var source := enemy.get_node_or_null("Visual") as AnimatedSprite2D
		if source:
			source.visible = false
		if source and source.sprite_frames and source.sprite_frames.has_animation(source.animation):
			_set_sprite_texture_and_height(proxy, source.sprite_frames.get_frame_texture(source.animation, source.frame), ENEMY_WORLD_HEIGHT)
		elif proxy.texture == null:
			_set_sprite_texture_and_height(proxy, BrambleWorldPresentationConfig.game_tex("monsters/moorling/directions/kit60_front.png"), ENEMY_WORLD_HEIGHT)
		proxy.position = simulation_to_world(enemy.global_position, ENEMY_WORLD_HEIGHT * 0.5)
		proxy.visible = enemy.visible and (not enemy.has_method("is_combat_alive") or enemy.is_combat_alive())

	for node in get_tree().get_nodes_in_group("interactable"):
		if not (node is Node2D):
			continue
		var source_sprite := node.get_node_or_null("Sprite") as Sprite2D
		if source_sprite == null or source_sprite.texture == null:
			continue
		var id := node.get_instance_id()
		alive_ids[id] = true
		var proxy := _entity_sprite(id, NPC_WORLD_HEIGHT)
		source_sprite.visible = false
		for child in node.get_children():
			if child is Label:
				child.visible = false
		_set_sprite_texture_and_height(proxy, source_sprite.texture, NPC_WORLD_HEIGHT)
		proxy.position = simulation_to_world(node.global_position, NPC_WORLD_HEIGHT * 0.5)
		proxy.visible = node.visible

	for node in get_tree().get_nodes_in_group("loot"):
		if not (node is Node2D):
			continue
		var loot_sprite := node.get_node_or_null("Sprite") as Sprite2D
		if loot_sprite == null or loot_sprite.texture == null:
			continue
		var id := node.get_instance_id()
		alive_ids[id] = true
		var proxy := _entity_sprite(id, LOOT_WORLD_HEIGHT)
		loot_sprite.visible = false
		_set_sprite_texture_and_height(proxy, loot_sprite.texture, LOOT_WORLD_HEIGHT)
		proxy.position = simulation_to_world(node.global_position, LOOT_WORLD_HEIGHT * 0.5 + 0.08)
		proxy.visible = node.visible

	for id in _entity_proxies.keys():
		if not alive_ids.has(id):
			var stale: Sprite3D = _entity_proxies[id]
			if is_instance_valid(stale):
				stale.queue_free()
			_entity_proxies.erase(id)

func _entity_sprite(id: int, _world_height: float) -> Sprite3D:
	var proxy: Sprite3D = _entity_proxies.get(id)
	if proxy != null:
		return proxy
	proxy = Sprite3D.new()
	proxy.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	proxy.shaded = false
	proxy.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_dynamic_root.add_child(proxy)
	_entity_proxies[id] = proxy
	return proxy

func _sync_player_proxy(delta: float) -> void:
	if _player_proxy == null or _player == null:
		return
	var speed := _player.velocity.length()
	if speed > 6.0:
		_last_player_world_direction = _player.velocity.normalized()
	_player_view_direction = _stable_camera_relative_direction(_last_player_world_direction, delta)

	var source := _player.get_node_or_null("Visual") as BramblePlayerVisual
	var gender := source.gender if source else "male"
	var texture := BrambleWorldPresentationConfig.game_tex("characters/base/%s/directions/%s.png" % [gender, _player_view_direction])
	if texture == null and source and source.sprite_frames and source.sprite_frames.has_animation(source.animation):
		texture = source.sprite_frames.get_frame_texture(source.animation, source.frame)
	_set_sprite_texture_and_height(_player_proxy, texture, PLAYER_WORLD_HEIGHT)
	_player_proxy.flip_h = false

	var render_position := simulation_to_world(_player.global_position, PLAYER_WORLD_HEIGHT * 0.5)
	var visual_scale := Vector3.ONE
	var speed_ratio := clampf(speed / 500.0, 0.0, 1.0)
	if speed_ratio > 0.04:
		# The current Bramble art has authored directional stills but no 8-way
		# run sheets. A tiny cadence keeps motion alive without changing facing.
		var cadence := sin(_motion_time * lerpf(8.0, 13.0, speed_ratio))
		render_position.y += absf(cadence) * 0.055 * speed_ratio
		visual_scale.x = 1.0 + cadence * 0.018 * speed_ratio
		visual_scale.y = 1.0 - cadence * 0.014 * speed_ratio

	var attacking_now := bool(_player.get("attacking"))
	if attacking_now and not _was_attacking:
		_attack_visual_remaining = 0.24
	_was_attacking = attacking_now
	_attack_visual_remaining = maxf(0.0, _attack_visual_remaining - delta)
	if _attack_visual_remaining > 0.0:
		var phase := 1.0 - (_attack_visual_remaining / 0.24)
		var punch := sin(phase * PI)
		var attack_direction := _last_player_world_direction
		var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
		if targeting and targeting.has_method("get_target"):
			var target: Node2D = targeting.get_target()
			if target:
				attack_direction = _player.global_position.direction_to(target.global_position)
		render_position.x += attack_direction.x * WORLD_SCALE * 48.0 * punch
		render_position.z += attack_direction.y * WORLD_SCALE * 48.0 * punch
		visual_scale *= 1.0 + punch * 0.070

	_player_proxy.position = render_position
	_player_proxy.scale = visual_scale

	if _player_shadow:
		_player_shadow.position = simulation_to_world(_player.global_position, 0.025)
		var dash_active := float(_player.get("_dash_remaining")) > 0.0
		_player_shadow.scale = Vector3(1.30, 1.0, 0.72) if dash_active else Vector3.ONE
	if _player_ground_ring:
		_player_ground_ring.position = simulation_to_world(_player.global_position, 0.018)

func _stable_camera_relative_direction(world_direction: Vector2, delta: float) -> String:
	var c := cos(_yaw)
	var si := sin(_yaw)
	var screen_direction := Vector2(
		world_direction.x * c - world_direction.y * si,
		world_direction.x * si + world_direction.y * c
	)
	if screen_direction.length_squared() <= 0.0001:
		return _player_view_direction
	var relative_angle := screen_direction.angle()
	var current_angle := _direction_angle(_player_view_direction)
	var distance_from_current := absf(wrapf(relative_angle - current_angle, -PI, PI))
	if distance_from_current < PI / 8.0 + 0.17:
		_view_candidate = ""
		_view_candidate_time = 0.0
		return _player_view_direction

	var next := _direction_from_angle(relative_angle)
	if next == _player_view_direction:
		_view_candidate = ""
		_view_candidate_time = 0.0
		return _player_view_direction
	if next != _view_candidate:
		_view_candidate = next
		_view_candidate_time = 0.0
	_view_candidate_time += maxf(0.0, delta)
	if _view_candidate_time >= 0.09:
		_player_view_direction = next
		_view_candidate = ""
		_view_candidate_time = 0.0
	return _player_view_direction

func _direction_from_angle(angle: float) -> String:
	var oct := posmod(int(round(angle / (TAU / 8.0))), 8)
	var mapping := ["right", "front_right", "front", "front_left", "left", "back_left", "back", "back_right"]
	return mapping[oct]

func _direction_angle(direction: String) -> float:
	match direction:
		"right": return 0.0
		"front_right": return PI / 4.0
		"front": return PI / 2.0
		"front_left": return PI * 3.0 / 4.0
		"left": return PI
		"back_left": return -PI * 3.0 / 4.0
		"back": return -PI / 2.0
		"back_right": return -PI / 4.0
	return PI / 2.0

func _set_sprite_texture_and_height(sprite: Sprite3D, texture: Texture2D, world_height: float) -> void:
	if sprite == null or texture == null:
		return
	sprite.texture = texture
	var source_height := maxf(1.0, float(texture.get_height()))
	sprite.pixel_size = world_height / source_height

func _add_world_billboard(path: String, sim_position: Vector2, world_height: float, base_y: float) -> void:
	var texture := BrambleWorldPresentationConfig.game_tex(path)
	if texture == null:
		return
	var sprite := Sprite3D.new()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_set_sprite_texture_and_height(sprite, texture, world_height)
	sprite.position = simulation_to_world(sim_position, base_y + world_height * 0.5)
	_static_root.add_child(sprite)

func _hide_2d_source_presentation() -> void:
	var source := _player.get_node_or_null("Visual") as CanvasItem if _player else null
	if source:
		source.visible = false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var visual := enemy.get_node_or_null("Visual") as CanvasItem
		if visual:
			visual.visible = false
	for node in get_tree().get_nodes_in_group("interactable"):
		for child in node.get_children():
			if child is CanvasItem:
				child.visible = false
	for node in get_tree().get_nodes_in_group("loot"):
		var sprite := node.get_node_or_null("Sprite") as CanvasItem
		if sprite:
			sprite.visible = false

func _add_building(node_name: String, sim_position: Vector2, width: float, depth: float, wall_height: float, wall_color: Color, roof_color: Color, yaw: float, chimney := false) -> void:
	var root := Node3D.new()
	root.name = node_name
	root.position = simulation_to_world(sim_position, 0.0)
	root.rotation.y = yaw
	_static_root.add_child(root)

	var body := _box_mesh(Vector3(width, wall_height, depth), wall_color)
	body.position.y = wall_height * 0.5
	root.add_child(body)
	_register_occluder(body, maxf(width, depth) * 0.56)

	var roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.0
	roof_mesh.bottom_radius = width * 0.72
	roof_mesh.height = 1.55
	roof_mesh.radial_segments = 4
	roof.mesh = roof_mesh
	roof.material_override = _material(roof_color)
	roof.position.y = wall_height + 0.62
	roof.rotation.y = PI * 0.25
	roof.scale.z = depth / width
	root.add_child(roof)
	_register_occluder(roof, maxf(width, depth) * 0.62)

	var door := _box_mesh(Vector3(0.72, 1.25, 0.10), Color("#34261f"))
	door.position = Vector3(0, 0.625, depth * 0.5 + 0.055)
	root.add_child(door)
	for x in [-width * 0.30, width * 0.30]:
		var window := _box_mesh(Vector3(0.58, 0.52, 0.11), Color("#71b8cf"))
		window.position = Vector3(x, 1.35, depth * 0.5 + 0.06)
		root.add_child(window)
	if chimney:
		var stack := _box_mesh(Vector3(0.52, 2.0, 0.52), Color("#343139"))
		stack.position = Vector3(width * 0.28, wall_height + 0.65, -depth * 0.20)
		root.add_child(stack)
		_register_occluder(stack, 0.55)

func _add_tree(sim_position: Vector2, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = simulation_to_world(sim_position, 0.0)
	root.scale = Vector3.ONE * scale_value
	_static_root.add_child(root)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.22
	trunk_mesh.height = 1.75
	trunk_mesh.radial_segments = 8
	trunk.mesh = trunk_mesh
	trunk.material_override = _material(Color("#5b3d2a"))
	trunk.position.y = 0.875
	root.add_child(trunk)
	_register_occluder(trunk, 0.38 * scale_value)

	for spec in [[Vector3(0, 2.0, 0), 1.15], [Vector3(-0.52, 1.85, 0.12), 0.82], [Vector3(0.48, 1.82, -0.10), 0.78]]:
		var crown := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = spec[1]
		sphere.height = spec[1] * 1.65
		crown.mesh = sphere
		crown.material_override = _material(Color("#6f844e"))
		crown.position = spec[0]
		root.add_child(crown)
		_register_occluder(crown, float(spec[1]) * scale_value)

func _add_fountain(sim_position: Vector2) -> void:
	var root := Node3D.new()
	root.name = "TownFountain"
	root.position = simulation_to_world(sim_position, 0.0)
	_static_root.add_child(root)
	var base := _cylinder_mesh(1.22, 0.30, Color("#5a5d63"))
	base.position.y = 0.15
	root.add_child(base)
	var basin := _cylinder_mesh(0.95, 0.16, Color("#46505a"))
	basin.position.y = 0.34
	root.add_child(basin)
	var water := _cylinder_mesh(0.78, 0.025, Color("#4c91aa"))
	water.position.y = 0.435
	root.add_child(water)
	var pillar := _cylinder_mesh(0.18, 1.10, Color("#666a70"))
	pillar.position.y = 0.88
	root.add_child(pillar)

func _add_arch(node_name: String, sim_position: Vector2, width: float, height: float, color: Color) -> void:
	var root := Node3D.new()
	root.name = node_name
	root.position = simulation_to_world(sim_position, 0.0)
	_static_root.add_child(root)
	var pillar_size := Vector3(0.42, height, 0.62)
	var left := _box_mesh(pillar_size, color)
	left.position = Vector3(-width * 0.5, height * 0.5, 0)
	root.add_child(left)
	_register_occluder(left, 0.55)
	var right := _box_mesh(pillar_size, color)
	right.position = Vector3(width * 0.5, height * 0.5, 0)
	root.add_child(right)
	_register_occluder(right, 0.55)
	var lintel := _box_mesh(Vector3(width + 0.55, 0.46, 0.72), color.lightened(0.08))
	lintel.position = Vector3(0, height - 0.18, 0)
	root.add_child(lintel)
	_register_occluder(lintel, width * 0.55)

func _register_occluder(mesh: MeshInstance3D, radius: float) -> void:
	if mesh == null:
		return
	_occluders.append({"mesh": mesh, "radius": maxf(0.25, radius)})

func _update_occluders(delta: float) -> void:
	if camera == null or _occluders.is_empty():
		return
	var from := camera.global_position
	var to := _camera_target
	var segment := to - from
	var length_sq := segment.length_squared()
	if length_sq <= 0.0001:
		return
	var alpha := 1.0 - exp(-delta * 14.0)
	for entry in _occluders:
		var mesh := entry.get("mesh") as MeshInstance3D
		if mesh == null or not is_instance_valid(mesh):
			continue
		var point := mesh.global_position
		var t := clampf((point - from).dot(segment) / length_sq, 0.0, 1.0)
		var closest := from + segment * t
		var radius := float(entry.get("radius", 0.8))
		var blocks_view := t > 0.08 and t < 0.90 and point.distance_to(closest) < radius
		var wanted := 0.72 if blocks_view else 0.0
		mesh.transparency = lerpf(mesh.transparency, wanted, alpha)

func spawn_hit_feedback(sim_position: Vector2, damage: int, emphasized := false) -> void:
	var root := Node3D.new()
	root.name = "CombatFeedback3D"
	root.position = simulation_to_world(sim_position, ENEMY_WORLD_HEIGHT + 0.30)
	_dynamic_root.add_child(root)

	var label := Label3D.new()
	label.text = str(damage)
	label.font_size = 42 if emphasized else 34
	label.outline_size = 9 if emphasized else 7
	label.modulate = Color("#ffd35a") if emphasized else Color.WHITE
	label.outline_modulate = Color(0.04, 0.03, 0.02, 0.98)
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	root.add_child(label)

	var spark := Label3D.new()
	spark.text = "✦"
	spark.font_size = 48 if emphasized else 38
	spark.modulate = Color(1.0, 0.82, 0.34, 0.92)
	spark.pixel_size = 0.005
	spark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	spark.no_depth_test = true
	spark.position = Vector3(0, -0.22, 0)
	root.add_child(spark)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "position:y", root.position.y + 0.72, 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.48).set_delay(0.10)
	tween.tween_property(spark, "scale", Vector3.ONE * 1.55, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(spark, "modulate:a", 0.0, 0.28).set_delay(0.05)
	tween.chain().tween_callback(root.queue_free)

func spawn_skill_feedback(sim_position: Vector2) -> void:
	var root := Node3D.new()
	root.position = simulation_to_world(sim_position, ENEMY_WORLD_HEIGHT * 0.65)
	_dynamic_root.add_child(root)
	var pulse := Label3D.new()
	pulse.text = "✧"
	pulse.font_size = 66
	pulse.modulate = Color(0.78, 0.58, 1.0, 0.90)
	pulse.pixel_size = 0.006
	pulse.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pulse.no_depth_test = true
	root.add_child(pulse)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(pulse, "scale", Vector3.ONE * 1.8, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(pulse, "modulate:a", 0.0, 0.34)
	tween.chain().tween_callback(root.queue_free)

func _add_disc(node_name: String, world_position: Vector3, radius: float, height: float, color: Color) -> void:
	var disc := _cylinder_mesh(radius, height, color)
	disc.name = node_name
	disc.position = world_position
	_static_root.add_child(disc)

func _disc_mesh(radius: float, height: float, color: Color) -> MeshInstance3D:
	return _cylinder_mesh(radius, height, color)

func _cylinder_mesh(radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 24
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = _material(color)
	return mesh_instance

func _box_mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _material(color)
	return mesh_instance

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
	var mesh_instance := _box_mesh(size, color)
	mesh_instance.name = node_name
	mesh_instance.position = world_position
	_static_root.add_child(mesh_instance)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.94
	if color.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
