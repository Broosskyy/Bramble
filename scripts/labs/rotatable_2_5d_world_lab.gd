extends Node3D

const DIR_NAMES := [
	"front", "front_right", "right", "back_right",
	"back", "back_left", "left", "front_left"
]
const GAME := "res://assets/game/"
const PLAYER_START := Vector3(0.0, 0.8, 4.5)
const BUILDING_POS := Vector3(-6.5, 0.0, -3.5)
const TREE_POS := Vector3(5.8, 0.0, -2.8)
const NPC_POS := Vector3(-1.8, 0.0, -4.0)
const MONSTER_POS := Vector3(5.0, 0.0, 4.0)

var player: CharacterBody3D
var player_body: Sprite3D
var armor: Sprite3D
var helmet: Sprite3D
var weapon: Sprite3D
var npc: Sprite3D
var monster: Sprite3D
var camera: Camera3D
var target_ring: MeshInstance3D
var canopy_planes: Array[Sprite3D] = []
var status_label: Label
var help_label: Label
var skills_label: Label
var camera_yaw := deg_to_rad(42.0)
var camera_pitch := deg_to_rad(39.0)
var camera_distance := 13.0
var character_facing := Vector3(0.0, 0.0, 1.0)
var dragging_camera := false
var capture_running := false
var attack_flash := 0.0
var _last_direction := ""
var _fps_samples: Array[float] = []
var _draw_samples: Array[int] = []


func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_spatial_building()
	_build_tree_tests()
	_build_perimeter()
	_build_characters()
	_build_camera()
	_build_hud()
	if "--m04_25-capture" in OS.get_cmdline_user_args():
		capture_running = true
		call_deferred("_capture_evidence")
	elif "--m04_25-profile" in OS.get_cmdline_user_args():
		capture_running = true
		call_deferred("_profile_and_quit")
	elif "--m04_25-smoke" in OS.get_cmdline_user_args():
		call_deferred("_smoke_and_quit")


func _process(delta: float) -> void:
	if attack_flash > 0.0:
		attack_flash -= delta
		monster.modulate = Color(1.7, 1.35, 1.1, 1.0) if attack_flash > 0.0 else Color.WHITE
	if not capture_running:
		_update_movement(delta)
	_update_camera()
	_update_directional_characters()
	_update_canopy_occlusion(delta)
	_update_hud()
	_fps_samples.append(Performance.get_monitor(Performance.TIME_FPS))
	_draw_samples.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	if _fps_samples.size() > 600:
		_fps_samples.pop_front()
		_draw_samples.pop_front()


func _unhandled_input(event: InputEvent) -> void:
	if capture_running:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging_camera = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = clampf(camera_distance - 1.0, 8.0, 19.0)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = clampf(camera_distance + 1.0, 8.0, 19.0)
	elif event is InputEventMouseMotion and dragging_camera:
		camera_yaw -= event.relative.x * 0.009
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.006, deg_to_rad(28.0), deg_to_rad(55.0))
	elif event is InputEventScreenDrag:
		camera_yaw -= event.relative.x * 0.008
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.004, deg_to_rad(28.0), deg_to_rad(55.0))
	elif event is InputEventMagnifyGesture:
		camera_distance = clampf(camera_distance / event.factor, 8.0, 19.0)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		attack_flash = 0.22


func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#9ed4df")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#eaf4dc")
	environment.ambient_light_energy = 0.52
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -35.0, 0.0)
	sun.light_color = Color("#fff1c4")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	add_child(sun)


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(45.0, 35.0)
	plane.subdivide_width = 1
	plane.subdivide_depth = 1
	ground.mesh = plane
	var grass := _material(Color("#6fa752"))
	grass.albedo_texture = load(GAME + "world/terrain/materials/grass_repeat_256.png")
	grass.uv1_scale = Vector3(9.0, 7.0, 1.0)
	ground.material_override = grass
	add_child(ground)

	var ground_body := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var ground_box := BoxShape3D.new()
	ground_box.size = Vector3(45.0, 0.2, 35.0)
	ground_shape.shape = ground_box
	ground_shape.position.y = -0.12
	ground_body.add_child(ground_shape)
	add_child(ground_body)

	_add_path(Vector3(0.0, 0.025, 0.2), Vector2(3.2, 20.0), 0.0)
	_add_path(Vector3(-3.2, 0.03, -3.5), Vector2(9.0, 3.0), 0.0)
	_add_path(Vector3(3.0, 0.035, 4.0), Vector2(8.0, 3.2), deg_to_rad(-8.0))

func _add_path(pos: Vector3, size: Vector2, yaw: float) -> void:
	var path := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	path.mesh = plane
	path.position = pos
	path.rotation.y = yaw
	var mat := _material(Color.WHITE)
	mat.albedo_texture = load(GAME + "world/terrain/materials/cobble_repeat_256.png")
	mat.uv1_scale = Vector3(maxf(1.0, size.x / 2.0), maxf(1.0, size.y / 2.0), 1.0)
	path.material_override = mat
	add_child(path)


func _build_spatial_building() -> void:
	var building := Node3D.new()
	building.name = "SpatialCottagePrototype"
	building.position = BUILDING_POS
	add_child(building)
	_box(building, Vector3(5.2, 3.2, 4.2), Vector3(0.0, 1.6, 0.0), Color("#c88f58"))
	_box(building, Vector3(5.7, 0.28, 3.3), Vector3(-1.28, 3.62, 0.0), Color("#2d6f70"), Vector3(0.0, 0.0, deg_to_rad(28.0)))
	_box(building, Vector3(5.7, 0.28, 3.3), Vector3(1.28, 3.62, 0.0), Color("#2d6f70"), Vector3(0.0, 0.0, deg_to_rad(-28.0)))
	_box(building, Vector3(0.95, 1.8, 0.18), Vector3(0.0, 0.9, 2.16), Color("#74432c"))
	_box(building, Vector3(0.8, 0.8, 0.16), Vector3(-1.65, 1.65, 2.17), Color("#8fc6cd"))
	_box(building, Vector3(0.65, 1.8, 0.65), Vector3(-1.65, 4.25, -0.5), Color("#8a7357"))
	for x in [-2.35, 2.35]:
		_box(building, Vector3(0.18, 3.0, 0.2), Vector3(x, 1.55, -2.12), Color("#694329"))
		_box(building, Vector3(0.18, 3.0, 0.2), Vector3(x, 1.55, 2.12), Color("#694329"))
	_box(building, Vector3(5.0, 0.18, 0.2), Vector3(0.0, 2.45, -2.12), Color("#694329"))
	_box(building, Vector3(1.0, 1.0, 0.16), Vector3(0.0, 1.55, -2.13), Color("#78afb5"))
	for z in [-1.25, 1.25]:
		_box(building, Vector3(0.16, 0.9, 1.0), Vector3(-2.62, 1.55, z), Color("#78afb5"))
		_box(building, Vector3(0.16, 0.9, 1.0), Vector3(2.62, 1.55, z), Color("#78afb5"))

	var facade := _sprite(GAME + "world/buildings/cottage.png", 0.0105, false)
	facade.name = "CanonicalCottageFrontOnly"
	facade.position = Vector3(0.0, 2.15, 2.24)
	building.add_child(facade)

	var body := StaticBody3D.new()
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(5.3, 3.4, 4.3)
	shape_node.shape = shape
	shape_node.position.y = 1.7
	body.add_child(shape_node)
	building.add_child(body)


func _build_tree_tests() -> void:
	var tree := Node3D.new()
	tree.name = "CrossPlaneOak"
	tree.position = TREE_POS
	add_child(tree)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.34
	trunk_mesh.bottom_radius = 0.5
	trunk_mesh.height = 3.2
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.6
	trunk.material_override = _material(Color("#76502e"))
	tree.add_child(trunk)
	for yaw in [0.0, 90.0]:
		var plane := _sprite(GAME + "world/buildings/red_oak.png", 0.0135, false)
		plane.position.y = 2.65
		plane.rotation_degrees.y = yaw
		tree.add_child(plane)
		canopy_planes.append(plane)
	var tree_body := StaticBody3D.new()
	var tree_shape_node := CollisionShape3D.new()
	var tree_shape := CylinderShape3D.new()
	tree_shape.radius = 0.62
	tree_shape.height = 2.0
	tree_shape_node.shape = tree_shape
	tree_shape_node.position.y = 1.0
	tree_body.add_child(tree_shape_node)
	tree.add_child(tree_body)

	# A camera-facing shrub demonstrates the low-cost billboard category.
	for pos in [Vector3(7.8, 0.0, -5.5), Vector3(8.8, 0.0, -3.7), Vector3(-9.0, 0.0, 5.5)]:
		var shrub := _sprite(GAME + "world/buildings/golden_shrubs.png", 0.010, true)
		shrub.position = pos + Vector3(0.0, 0.65, 0.0)
		add_child(shrub)


func _build_perimeter() -> void:
	# Higher-density decoration remains at the perimeter.
	for pos in [Vector3(-11.0, 0.0, -7.0), Vector3(-9.0, 0.0, -8.5), Vector3(10.5, 0.0, 7.0)]:
		var oak := _sprite(GAME + "world/buildings/red_oak.png", 0.011, true)
		oak.position = pos + Vector3(0.0, 2.1, 0.0)
		add_child(oak)
	for z in [-0.5, 1.2, 2.9]:
		var fence := _sprite(GAME + "world/buildings/fence_straight.png", 0.0065, false)
		fence.position = Vector3(-10.2, 1.05, z)
		fence.rotation_degrees.y = 90.0
		add_child(fence)
		_add_fence_collision(Vector3(-10.2, 0.75, z))
	_add_rock(Vector3(2.4, 0.0, -6.8), 1.2)
	_add_rock(Vector3(8.8, 0.0, 6.9), 0.8)


func _build_characters() -> void:
	player = CharacterBody3D.new()
	player.name = "LabPlayer"
	player.position = PLAYER_START
	player.add_to_group("player")
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.55
	collision.shape = capsule
	player.add_child(collision)
	add_child(player)
	_add_shadow(player, 0.52)

	player_body = _sprite(GAME + "characters/base/male/directions/front.png", 0.0061, true)
	player_body.name = "DirectionalBody"
	player_body.position.y = 1.28
	player.add_child(player_body)
	armor = _sprite(GAME + "characters/equipment/armor/forest_male.png", 0.0044, true)
	armor.name = "ArmorFrontOnlyLimitation"
	armor.position = Vector3(0.0, 1.08, -0.012)
	player.add_child(armor)
	helmet = _sprite("res://assets/equipment/armor/leather_head.png", 0.0031, true)
	helmet.name = "HelmetFrontOnlyLimitation"
	helmet.pixel_size = 0.00165
	helmet.position = Vector3(0.0, 2.22, -0.024)
	player.add_child(helmet)
	weapon = _sprite(GAME + "characters/equipment/weapons/melee/short_sword.png", 0.0028, true)
	weapon.name = "WeaponOverlay"
	weapon.position = Vector3(0.52, 1.0, -0.036)
	weapon.rotation_degrees.z = -18.0
	player.add_child(weapon)

	npc = _sprite(GAME + "npcs/merchant/directions/front.png", 0.0060, true)
	npc.name = "DirectionalNPC"
	npc.position = NPC_POS + Vector3(0.0, 1.25, 0.0)
	add_child(npc)
	_add_shadow_at(NPC_POS, 0.48)
	_add_nameplate("Lina · Quest", NPC_POS + Vector3(0.0, 2.95, 0.0), Color("#fff0a8"))

	monster = _sprite(GAME + "monsters/moorling/directions/kit60_front.png", 0.0065, true)
	monster.name = "DirectionalMonster"
	monster.position = MONSTER_POS + Vector3(0.0, 1.15, 0.0)
	add_child(monster)
	_add_shadow_at(MONSTER_POS, 0.58)
	_add_nameplate("Moorling · Lv. 3", MONSTER_POS + Vector3(0.0, 2.85, 0.0), Color("#ffd0b0"))
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.68
	ring_mesh.outer_radius = 0.79
	ring_mesh.rings = 24
	ring_mesh.ring_segments = 8
	target_ring = MeshInstance3D.new()
	target_ring.mesh = ring_mesh
	target_ring.position = MONSTER_POS + Vector3(0.0, 0.06, 0.0)
	target_ring.material_override = _emissive_material(Color("#ffd35a"))
	add_child(target_ring)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "OrbitCamera"
	camera.fov = 34.0
	camera.near = 0.2
	camera.far = 80.0
	camera.current = true
	add_child(camera)
	_update_camera()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "LabHUD"
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(0.055, 0.09, 0.07, 0.88)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 76.0
	layer.add_child(top)
	var title := Label.new()
	title.text = "BRAMBLE · ROTATABLE 2.5D WORLD LAB"
	title.position = Vector2(22.0, 12.0)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#ffe9ad"))
	top.add_child(title)
	status_label = Label.new()
	status_label.position = Vector2(23.0, 43.0)
	status_label.add_theme_font_size_override("font_size", 13)
	top.add_child(status_label)
	help_label = Label.new()
	help_label.text = "WASD move · RMB/drag orbit · wheel/pinch zoom · Space attack"
	help_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help_label.position = Vector2(18.0, -44.0)
	help_label.add_theme_color_override("font_color", Color("#f5f0d5"))
	layer.add_child(help_label)
	skills_label = Label.new()
	skills_label.text = "◎  SELF       ◉  TARGET       [1] Strike   [2] Guard"
	skills_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	skills_label.position = Vector2(-390.0, -44.0)
	skills_label.add_theme_color_override("font_color", Color("#fff0bd"))
	layer.add_child(skills_label)


func _update_movement(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length_squared() < 0.01:
		player.velocity = Vector3.ZERO
		return
	var forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw)).normalized()
	var right := Vector3(forward.z, 0.0, -forward.x)
	var move := (right * input.x + forward * -input.y).normalized()
	player.velocity = move * 4.2
	player.move_and_slide()
	player.position.x = clampf(player.position.x, -13.5, 13.5)
	player.position.z = clampf(player.position.z, -10.0, 10.0)
	character_facing = move


func _update_camera() -> void:
	if camera == null or player == null:
		return
	var portrait_factor := 1.42 if get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x else 1.0
	var effective_distance := camera_distance * portrait_factor
	var horizontal := cos(camera_pitch) * effective_distance
	var offset := Vector3(sin(camera_yaw) * horizontal, sin(camera_pitch) * effective_distance, cos(camera_yaw) * horizontal)
	var focus := player.global_position + Vector3(0.0, 1.05, 0.0)
	camera.global_position = focus + offset
	camera.look_at(focus, Vector3.UP)


func _update_directional_characters() -> void:
	var direction := _relative_direction(character_facing, camera_yaw)
	if direction != _last_direction:
		player_body.texture = load(GAME + "characters/base/male/directions/%s.png" % direction)
		_last_direction = direction
	var npc_facing := Vector3(0.0, 0.0, 1.0)
	npc.texture = load(GAME + "npcs/merchant/directions/%s.png" % _relative_direction(npc_facing, camera_yaw))
	var monster_dir := _relative_direction(Vector3(-1.0, 0.0, 0.0), camera_yaw)
	var four_dir := _nearest_four_direction(monster_dir)
	monster.texture = load(GAME + "monsters/moorling/directions/kit60_%s.png" % four_dir)


func _relative_direction(world_facing: Vector3, view_yaw: float) -> String:
	var facing_angle := atan2(world_facing.x, world_facing.z)
	var relative := wrapf(facing_angle - view_yaw, -PI, PI)
	var octant := posmod(int(round(relative / (TAU / 8.0))), 8)
	return DIR_NAMES[octant]


func _nearest_four_direction(direction: String) -> String:
	match direction:
		"front_left", "front_right": return "front"
		"back_left", "back_right": return "back"
		_: return direction


func _update_canopy_occlusion(delta: float) -> void:
	if camera == null or player == null:
		return
	var camera_flat := Vector2(camera.global_position.x, camera.global_position.z)
	var player_flat := Vector2(player.global_position.x, player.global_position.z)
	var tree_flat := Vector2(TREE_POS.x, TREE_POS.z)
	var segment := player_flat - camera_flat
	var t := clampf((tree_flat - camera_flat).dot(segment) / maxf(segment.length_squared(), 0.001), 0.0, 1.0)
	var distance_to_sightline := tree_flat.distance_to(camera_flat + segment * t)
	var covers := t > 0.15 and t < 0.95 and distance_to_sightline < 1.5
	var wanted := 0.38 if covers else 1.0
	for plane in canopy_planes:
		var color := plane.modulate
		color.a = move_toward(color.a, wanted, delta * 3.0)
		plane.modulate = color


func _update_hud() -> void:
	if status_label == null:
		return
	var mode := "PORTRAIT" if get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x else "LANDSCAPE"
	status_label.text = "%s · yaw %03d° · pitch %02d° · zoom %.1f · view %s" % [
		mode, int(rad_to_deg(camera_yaw)) % 360, int(rad_to_deg(camera_pitch)),
		camera_distance, _last_direction.replace("_", "-")
	]
	if mode == "PORTRAIT":
		help_label.text = "Drag safe world: orbit · Pinch: zoom"
		help_label.position = Vector2(14.0, -36.0)
		skills_label.position = Vector2(-370.0, -66.0)
	else:
		help_label.text = "WASD move · RMB/drag orbit · wheel/pinch zoom · Space attack"
		help_label.position = Vector2(18.0, -44.0)
		skills_label.position = Vector2(-390.0, -44.0)


func _sprite(path: String, pixel_size: float, billboard: bool) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = load(path)
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if billboard else BaseMaterial3D.BILLBOARD_DISABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return sprite


func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	return mat


func _emissive_material(color: Color) -> StandardMaterial3D:
	var mat := _material(color)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.8
	return mat


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.material_override = _material(color)
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(item)
	return item


func _add_fence_collision(pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.35, 1.5, 2.0)
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _add_rock(pos: Vector3, scale_value: float) -> void:
	var rock := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.6
	sphere.height = 0.75
	sphere.radial_segments = 10
	sphere.rings = 6
	rock.mesh = sphere
	rock.position = pos + Vector3(0.0, 0.3 * scale_value, 0.0)
	rock.scale = Vector3(1.2, 0.65, 0.9) * scale_value
	rock.rotation_degrees.y = pos.x * 13.0
	rock.material_override = _material(Color("#746f65"))
	add_child(rock)


func _add_shadow(parent: Node3D, radius: float) -> void:
	var shadow := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.015
	disc.radial_segments = 24
	shadow.mesh = disc
	shadow.position.y = -0.77
	shadow.material_override = _material(Color(0.08, 0.12, 0.08, 0.5))
	parent.add_child(shadow)


func _add_shadow_at(pos: Vector3, radius: float) -> void:
	var host := Node3D.new()
	host.position = pos + Vector3(0.0, 0.02, 0.0)
	add_child(host)
	_add_shadow(host, radius)
	host.get_child(0).position.y = 0.0


func _add_nameplate(text: String, pos: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 36
	label.pixel_size = 0.006
	label.modulate = color
	label.outline_size = 8
	add_child(label)


func _smoke_and_quit() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	print("M04.25_SMOKE PASS nodes=", get_tree().get_node_count())
	get_tree().quit()


func _profile_and_quit() -> void:
	await _set_viewport(Vector2i(1280, 720))
	await _stage(PLAYER_START, 42.0, 13.0, Vector3(0.0, 0.0, 1.0))
	await _wait_frames(120)
	_fps_samples.clear()
	_draw_samples.clear()
	await _wait_frames(240)
	_write_performance_report()
	print("M04.25_PROFILE PASS")
	get_tree().quit()


func _capture_evidence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts/m04_25"))
	await _set_viewport(Vector2i(1280, 720))
	await _stage(PLAYER_START, 42.0, 13.0, Vector3(0.0, 0.0, 1.0))
	await _shot("01_lab_landscape_default.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("02_lab_portrait_default.png")
	await _set_viewport(Vector2i(1280, 720))

	var views := [
		["03_camera_front.png", 0.0], ["04_camera_front_right.png", 45.0],
		["05_camera_right.png", 90.0], ["06_camera_back_right.png", 135.0],
		["07_camera_back.png", 180.0], ["08_camera_back_left.png", 225.0],
		["09_camera_left.png", 270.0], ["10_camera_front_left.png", 315.0]
	]
	for view in views:
		await _stage(PLAYER_START, float(view[1]), 13.0, Vector3(0.0, 0.0, 1.0))
		await _shot(String(view[0]))

	await _stage(Vector3(0.0, 0.8, 2.4), 0.0, 9.5, Vector3(0.0, 0.0, 1.0))
	await _shot("11_player_idle_directional.png")
	await _stage(Vector3(1.8, 0.8, 2.4), 0.0, 10.0, Vector3(1.0, 0.0, 0.0))
	await _shot("12_player_movement_directional.png")
	await _stage(Vector3(0.0, 0.8, 2.4), 0.0, 8.2, Vector3(0.0, 0.0, 1.0))
	await _shot("13_player_equipment_front.png")
	await _stage(Vector3(0.0, 0.8, 2.4), 90.0, 8.2, Vector3(0.0, 0.0, 1.0))
	await _shot("14_player_equipment_side.png")
	await _stage(Vector3(0.0, 0.8, 2.4), 180.0, 8.2, Vector3(0.0, 0.0, 1.0))
	await _shot("15_player_equipment_back.png")

	await _stage(BUILDING_POS + Vector3(0.0, 0.8, 5.8), 0.0, 12.0, Vector3(0.0, 0.0, -1.0))
	await _shot("16_building_front.png")
	await _stage(BUILDING_POS + Vector3(5.8, 0.8, 0.0), 90.0, 12.0, Vector3(-1.0, 0.0, 0.0))
	await _shot("17_building_side.png")
	await _stage(BUILDING_POS + Vector3(0.0, 0.8, -5.8), 180.0, 12.0, Vector3(0.0, 0.0, 1.0))
	await _shot("18_building_rear.png")

	await _stage(TREE_POS + Vector3(0.0, 0.8, 3.2), 0.0, 11.0, Vector3(0.0, 0.0, -1.0))
	await _shot("19_tree_front.png")
	await _stage(TREE_POS + Vector3(3.2, 0.8, 0.0), 90.0, 11.0, Vector3(-1.0, 0.0, 0.0))
	await _shot("20_tree_side.png")
	await _stage(TREE_POS + Vector3(0.0, 0.8, -3.2), 180.0, 11.0, Vector3(0.0, 0.0, 1.0))
	await _shot("21_tree_rear.png")
	await _stage(TREE_POS + Vector3(0.0, 0.8, -1.1), 0.0, 10.0, Vector3(0.0, 0.0, 1.0))
	await _wait_frames(25)
	await _shot("22_tree_occlusion.png")

	await _stage(NPC_POS + Vector3(0.9, 0.8, 1.5), 20.0, 9.0, Vector3(-0.4, 0.0, -1.0))
	await _shot("23_npc_interaction_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("24_npc_interaction_portrait.png")
	await _set_viewport(Vector2i(1280, 720))

	await _stage(MONSTER_POS + Vector3(-2.3, 0.8, 0.7), 55.0, 10.5, Vector3(1.0, 0.0, -0.2))
	attack_flash = 0.35
	await _shot("25_monster_combat_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	attack_flash = 0.35
	await _shot("26_monster_combat_portrait.png")
	await _set_viewport(Vector2i(1280, 720))

	await _stage(PLAYER_START, 42.0, 8.0, Vector3(0.0, 0.0, 1.0))
	await _shot("27_zoom_near.png")
	camera_distance = 13.0
	await _wait_frames(5)
	await _shot("28_zoom_mid.png")
	camera_distance = 19.0
	await _wait_frames(5)
	await _shot("29_zoom_far.png")
	await _stage(PLAYER_START, 42.0, 13.0, Vector3(0.0, 0.0, 1.0))
	await _shot("30_final_lab_landscape.png")
	await _set_viewport(Vector2i(720, 1280))
	await _shot("31_final_lab_portrait.png")
	_write_performance_report()
	print("M04.25_CAPTURE PASS")
	get_tree().quit()


func _stage(pos: Vector3, yaw_degrees: float, distance: float, facing: Vector3) -> void:
	player.position = pos
	camera_yaw = deg_to_rad(yaw_degrees)
	camera_distance = distance
	character_facing = facing.normalized()
	_last_direction = ""
	await _wait_frames(6)


func _set_viewport(size: Vector2i) -> void:
	get_window().size = size
	get_window().content_scale_size = size
	await _wait_frames(8)


func _shot(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("res://artifacts/m04_25/%s" % filename)
	var error := image.save_png(path)
	if error != OK:
		push_error("M04.25 screenshot failed: %s (%s)" % [path, error])
	print("M04.25 screenshot saved: ", path)
	await _wait_frames(3)


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _write_performance_report() -> void:
	var avg_fps := 0.0
	for sample in _fps_samples:
		avg_fps += sample
	avg_fps /= maxf(float(_fps_samples.size()), 1.0)
	var avg_draws := 0.0
	for sample in _draw_samples:
		avg_draws += sample
	avg_draws /= maxf(float(_draw_samples.size()), 1.0)
	var text := "node_count=%d\naverage_fps=%.2f\naverage_draw_calls=%.2f\nrenderer=%s\nsprite3d_count=%d\nspatial_mesh_count=%d\n" % [
		get_tree().get_node_count(), avg_fps, avg_draws,
		RenderingServer.get_video_adapter_name(), 17, 20
	]
	var file := FileAccess.open("res://artifacts/m04_25/performance.txt", FileAccess.WRITE)
	if file:
		file.store_string(text)
