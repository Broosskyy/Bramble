class_name BrambleVisualMasterWorldBuilder
extends Node2D

const MapRegistry := preload("res://scripts/world_map_registry.gd")
const TilePlacer := preload("res://scripts/terrain_tile_placer.gd")

@onready var ground: Node2D = $Ground
@onready var water: Node2D = $Water
@onready var roads: Node2D = $Roads
@onready var objects: Node2D = $WorldObjects
@onready var elevated: Node2D = $Elevated
@onready var npcs: Node2D = $NPCs
@onready var monsters: Node2D = $Monsters
@onready var portals: Node2D = $Portals
@onready var collisions: Node2D = $Collisions
@onready var elevation_zones: Node2D = $ElevationZones

var _map: Node

func _ready() -> void:
	_map = MapRegistry.new()
	_map.name = "WorldMapRegistry"
	add_child(_map)
	_map.configure(BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS, BrambleWorldPresentationConfig.WORLD_MAP_CELL_SIZE)
	_build_base_canvas()
	_build_terrain_variation()
	_build_roads()
	_build_river()
	_build_village()
	_build_elevation()
	_build_transition()
	_build_wilds()
	_build_npcs()
	_build_monsters()
	_build_portals()
	_register_map_markers()

func _tex(path: String) -> Texture2D:
	return BrambleWorldPresentationConfig.game_tex(path)

func _paint_map(pos: Vector2, cell: int, radius_cells: int = 2) -> void:
	_map.paint_cell(pos, cell, radius_cells)

func _place(
	parent: Node2D,
	path: String,
	pos: Vector2,
	scale_value: float,
	foot_y_offset := 0.0,
	occluder := false,
	height_level := 0,
	occlusion_half_w := 36.0,
	occlusion_height := 96.0
) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = _tex(path)
	if sp.texture == null:
		push_warning("Missing production asset: %s" % path)
		return sp
	sp.position = Vector2(snapped(pos.x, 1.0), snapped(pos.y, 1.0))
	sp.scale = Vector2.ONE * scale_value
	sp.centered = true
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sp.z_as_relative = false
	parent.add_child(sp)
	var foot_y := sp.global_position.y + foot_y_offset
	if occluder:
		sp.add_to_group("occluder")
		sp.set_meta("foot_y", foot_y)
		sp.set_meta("occlusion_foot_y", foot_y)
		sp.set_meta("occlusion_half_w", occlusion_half_w * scale_value)
		sp.set_meta("occlusion_height", occlusion_height * scale_value)
	var foot := BrambleFootpointSort.new()
	foot.foot_offset = Vector2(0, foot_y_offset)
	foot.height_level = height_level
	sp.add_child(foot)
	sp.z_index = BrambleWorldPresentationConfig.sort_key(foot_y, height_level)
	return sp

func _fill_tiles(path: String, origin: Vector2, cols: int, rows: int, scale_value: float, layer: TilePlacer.Layer, _cell_type: int) -> void:
	TilePlacer.fill_grid(ground, path, origin, cols, rows, scale_value, layer)

func _solid_rect(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	collisions.add_child(body)

func _solid_circle(pos: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	body.add_child(shape)
	collisions.add_child(body)

func _elevation_zone(rect_pos: Vector2, rect_size: Vector2, level: int, zone_name: String) -> void:
	var area := BrambleElevationZone.new()
	area.height_level = level
	area.zone_name = zone_name
	area.position = rect_pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = rect_size
	shape.shape = rect
	area.add_child(shape)
	elevation_zones.add_child(area)
	for x in range(0, int(rect_size.x), 48):
		for y in range(0, int(rect_size.y), 48):
			_paint_map(rect_pos + Vector2(x, y), MapRegistry.Cell.ELEVATION)

func _build_base_canvas() -> void:
	var cfg := BrambleWorldPresentationConfig
	TilePlacer.fill_grid_variated(
		ground,
		[
			"world/terrain/materials/grass_repeat_256.png",
			"world/terrain/materials/dirt_repeat_256.png",
			"world/terrain/materials/grass_repeat_256.png",
		],
		cfg.WORLD_FILL_ORIGIN,
		cfg.WORLD_FILL_COLS,
		cfg.WORLD_FILL_ROWS,
		cfg.SCALE_TERRAIN,
		TilePlacer.Layer.GROUND
	)

func _build_terrain_variation() -> void:
	var sc := BrambleWorldPresentationConfig.SCALE_TERRAIN
	for pos in [Vector2(-420, 180), Vector2(180, 220), Vector2(760, 200)]:
		TilePlacer.place(ground, "world/terrain/overlays/overlay_grass_clumps_256.png", pos, sc * 0.62, TilePlacer.Layer.OVERLAY)
	for pos in [Vector2(520, 80), Vector2(-180, -320)]:
		TilePlacer.place(ground, "world/terrain/overlays/overlay_grass_clumps_256.png", pos, sc * 0.58, TilePlacer.Layer.OVERLAY)
	for x in range(320, 900, 140):
		for y in range(-40, 260, 120):
			TilePlacer.place(ground, "world/terrain/overlays/overlay_fallen_leaves_256.png", Vector2(x, y), sc * 0.46, TilePlacer.Layer.OVERLAY)
			_paint_map(Vector2(x, y), MapRegistry.Cell.WILDS)

func _paint_road(pos: Vector2, scale_value: float, path := "world/roads/road_cobble.png") -> void:
	TilePlacer.place(roads, path, pos, scale_value, TilePlacer.Layer.ROAD)
	_paint_map(pos, MapRegistry.Cell.ROAD)

func _paint_road_shoulder(pos: Vector2, scale_value: float) -> void:
	for offset in [Vector2(0, -34), Vector2(0, 34)]:
		TilePlacer.place(roads, "world/terrain/materials/dirt_repeat_256.png", pos + offset, scale_value * 0.72, TilePlacer.Layer.OVERLAY)
		_paint_map(pos + offset, MapRegistry.Cell.DIRT)

func _build_roads() -> void:
	var sc := BrambleWorldPresentationConfig.SCALE_ROAD
	var step := TilePlacer.tile_step("world/roads/road_cobble.png", sc)
	var y_main := 70.0
	for x in range(-5, 5):
		var pos := Vector2(x * step * 0.98, y_main)
		_paint_road(pos, sc)
		_paint_road_shoulder(pos, sc)
	_paint_road(Vector2(0, y_main), sc * 1.02, "world/roads/road_cross.png")
	_paint_road(Vector2(350, 95), sc, "world/roads/road_bend.png")
	for x in range(3, 7):
		var pos := Vector2(350 + x * step * 0.94, 130 + x * 18)
		_paint_road(pos, sc * 0.96)
		_paint_road_shoulder(pos, sc * 0.96)
	for y in range(-2, 0):
		var pos := Vector2(-60, y_main + y * step * 0.88)
		_paint_road(pos, sc * 0.88)
		_paint_road_shoulder(pos, sc * 0.88)

func _build_river() -> void:
	var sc_w := BrambleWorldPresentationConfig.SCALE_WATER
	var sc_r := BrambleWorldPresentationConfig.SCALE_ROAD
	var river_y := 300.0
	var water_step := TilePlacer.tile_step("world/terrain/materials/water_repeat_256.png", sc_w)
	var bank_scale := sc_r * 0.92
	var start_x := -560.0
	var cols := 15
	for x in range(cols):
		var pos := Vector2(start_x + x * water_step, river_y)
		TilePlacer.place(water, "world/terrain/materials/water_repeat_256.png", pos, sc_w, TilePlacer.Layer.WATER, 0, 4.0)
		_paint_map(pos, MapRegistry.Cell.WATER, 3)
		_solid_rect(pos + Vector2(0, 8), Vector2(water_step * 0.92, 72))
		var bank_pos := Vector2(start_x + x * water_step, river_y - 52)
		TilePlacer.place(water, "world/roads/riverbank_straight.png", bank_pos, bank_scale, TilePlacer.Layer.WATER, 1, 3.0)
		_paint_map(bank_pos, MapRegistry.Cell.WATER)
	var end_x := start_x + float(cols - 1) * water_step
	_place(water, "world/roads/river_edge.png", Vector2(start_x - water_step * 0.5, river_y - 18), sc_r * 0.88, 6.0)
	_place(water, "world/roads/pond_edge_endcap.png", Vector2(end_x + water_step * 0.5, river_y - 18), sc_r * 0.88, 6.0)
	_place(objects, "world/buildings/stream_bridge.png", Vector2(200, river_y - 8), BrambleWorldPresentationConfig.SCALE_PROP_LARGE, 22.0)

func _build_village() -> void:
	var bl := BrambleWorldPresentationConfig.SCALE_BUILDING_LARGE
	var bs := BrambleWorldPresentationConfig.SCALE_BUILDING_SMALL
	var tr := BrambleWorldPresentationConfig.SCALE_TREE
	var ps := BrambleWorldPresentationConfig.SCALE_PROP_SMALL
	var pl := BrambleWorldPresentationConfig.SCALE_PROP_LARGE
	var sh := BrambleWorldPresentationConfig.SCALE_SHRUB

	_place(objects, "world/buildings/inn.png", Vector2(-260, -30), bl, 52.0, false, 0, 70.0, 120.0)
	_solid_rect(Vector2(-260, 28), Vector2(148, 88))
	_place(objects, "world/buildings/workshop.png", Vector2(-70, -70), bs * 1.05, 46.0, false, 0, 58.0, 96.0)
	_solid_rect(Vector2(-70, -18), Vector2(132, 78))
	_place(objects, "world/buildings/cottage.png", Vector2(150, -20), bs, 42.0, false, 0, 52.0, 88.0)
	_solid_rect(Vector2(150, 24), Vector2(118, 72))
	_place(objects, "world/buildings/town_fountain.png", Vector2(20, 55), pl, 28.0)
	_place(objects, "world/buildings/village_well.png", Vector2(-180, 130), ps * 1.1, 18.0)
	_place(objects, "world/buildings/garden.png", Vector2(-330, 90), ps * 1.2, 10.0)
	_place(objects, "world/buildings/flower_bed.png", Vector2(120, 120), sh, 6.0)
	_place(objects, "world/buildings/hay_bales.png", Vector2(240, 150), ps, 8.0)
	_place(objects, "world/buildings/produce_cart.png", Vector2(-20, 170), ps * 1.05, 12.0)
	_place(objects, "world/buildings/lantern_post.png", Vector2(80, 20), ps * 1.1, 18.0)
	_place(objects, "world/buildings/bench_crates.png", Vector2(-120, 180), ps, 8.0)
	_place(objects, "world/buildings/blank_signpost.png", Vector2(260, 40), ps, 16.0)

	for x in [-420, -320, -220]:
		_place(objects, "world/buildings/fence_straight.png", Vector2(x, 200), ps * 0.95, 10.0)
	_place(objects, "world/buildings/fence_corner.png", Vector2(-420, 200), ps * 0.95, 10.0)
	_place(objects, "world/buildings/gate_fence.png", Vector2(310, 70), ps * 1.05, 14.0)

	_place(objects, "world/buildings/red_oak.png", Vector2(-480, -40), tr, 78.0, true, 0, 44.0, 118.0)
	_solid_circle(Vector2(-480, 38), 32.0)
	_place(objects, "world/buildings/apple_tree.png", Vector2(320, -120), tr * 0.95, 70.0, true, 0, 40.0, 108.0)
	_solid_circle(Vector2(320, -50), 28.0)
	_place(objects, "world/buildings/golden_shrubs.png", Vector2(-380, 150), sh, 6.0)
	_place(objects, "world/buildings/golden_shrubs.png", Vector2(200, 200), sh * 0.9, 6.0)

func _build_elevation() -> void:
	var sc := BrambleWorldPresentationConfig.SCALE_ELEVATION
	var base := Vector2(-340, -260)
	_place(elevated, "world/elevation/cliff_wall.png", base + Vector2(-40, -30), sc * 1.05, 20.0, false, 1, 80.0, 110.0)
	_place(elevated, "world/elevation/earth_ledge.png", base + Vector2(30, 10), sc, 34.0, false, 1)
	_place(elevated, "world/elevation/grass_edge.png", base + Vector2(150, 40), sc * 0.95, 22.0, false, 1)
	_place(elevated, "world/buildings/watchtower.png", base + Vector2(60, -50), BrambleWorldPresentationConfig.SCALE_BUILDING_SMALL * 1.1, 50.0, false, 1, 42.0, 130.0)
	_solid_rect(base + Vector2(60, 0), Vector2(110, 82))
	_place(objects, "world/elevation/earthen_ramp.png", base + Vector2(130, 130), sc, 20.0)
	_place(objects, "world/elevation/embedded_stone_stairs.png", base + Vector2(90, 160), sc * 0.92, 16.0)
	_elevation_zone(base + Vector2(-20, -80), Vector2(260, 160), 1, "shrine_ledge")

func _build_transition() -> void:
	var tr := BrambleWorldPresentationConfig.SCALE_TREE
	var sh := BrambleWorldPresentationConfig.SCALE_SHRUB
	_place(objects, "world/buildings/market_stall.png", Vector2(380, 60), BrambleWorldPresentationConfig.SCALE_PROP_LARGE, 26.0)
	_place(objects, "world/buildings/blank_sign.png", Vector2(450, 150), BrambleWorldPresentationConfig.SCALE_PROP_SMALL, 12.0)
	for pos in [Vector2(360, -80), Vector2(480, 200), Vector2(520, 40)]:
		_place(objects, "world/buildings/red_oak.png", pos, tr * 0.92, 68.0, true, 0, 40.0, 112.0)
		_solid_circle(pos + Vector2(0, 62), 26.0)
		_paint_map(pos, MapRegistry.Cell.WILDS)
	for pos in [Vector2(410, 120), Vector2(560, 80), Vector2(340, 180)]:
		_place(objects, "world/buildings/golden_shrubs.png", pos, sh, 6.0)

func _build_wilds() -> void:
	var tr := BrambleWorldPresentationConfig.SCALE_TREE
	_place(objects, "world/buildings/ruined_arch.png", Vector2(720, 40), BrambleWorldPresentationConfig.SCALE_PROP_LARGE, 38.0, false, 0, 52.0, 100.0)
	for pos in [Vector2(560, -40), Vector2(780, 180), Vector2(860, 60), Vector2(700, 210)]:
		var half_w := 34.0 if pos.x < 650.0 else 42.0
		var canopy := 96.0 if pos.x < 650.0 else 116.0
		_place(objects, "world/buildings/red_oak.png", pos, tr * (0.88 if pos.x < 650.0 else 1.0), 72.0, true, 0, half_w, canopy)
		_solid_circle(pos + Vector2(0, 66), 28.0)
		_paint_map(pos, MapRegistry.Cell.WILDS)
	_place(objects, "world/buildings/apple_tree.png", Vector2(820, -40), tr * 0.9, 66.0, true, 0, 34.0, 96.0)
	_solid_circle(Vector2(820, 26), 24.0)

func _add_npc(id: String, name_text: String, role_text: String, pos: Vector2, production_path: String) -> void:
	var n := BrambleNpc.new()
	n.npc_id = id
	n.npc_name = name_text
	n.npc_role = role_text
	n.use_production_assets = true
	n.production_texture_path = production_path
	n.position = pos
	npcs.add_child(n)

func _build_npcs() -> void:
	_add_npc("lina", "Lina", "Questgeberin", Vector2(-40, 30), "npcs/merchant/directions/front.png")
	_add_npc("ferro", "Ferro", "Schmied", Vector2(-120, 90), "npcs/blacksmith/directions/front.png")

func _add_enemy(pos: Vector2) -> void:
	var e := BrambleEnemy.new()
	e.enemy_id = "moorling"
	e.enemy_name = "Moorling"
	e.asset_id = "moorling"
	e.use_production_assets = true
	e.production_texture_path = "monsters/moorling/directions/kit60_front.png"
	e.max_hp = 48
	e.attack_damage = 8
	e.xp_reward = 22
	e.gold_reward = 6
	e.move_speed = 92.0
	e.position = pos
	monsters.add_child(e)

func _build_monsters() -> void:
	_add_enemy(Vector2(650, 110))
	_add_enemy(Vector2(760, 170))
	_add_enemy(Vector2(700, 140))

func _build_portals() -> void:
	_place(objects, "world/portals/portal_arch_active.png", Vector2(540, 120), BrambleWorldPresentationConfig.SCALE_PORTAL, 40.0)
	var p := BramblePortal.new()
	p.portal_name = "Nebelbruch"
	p.destination = Vector2(650, 110)
	p.position = Vector2(540, 120)
	portals.add_child(p)

func _register_map_markers() -> void:
	_map.add_marker(MapRegistry.MarkerKind.NPC, Vector2(-40, 30), "Lina")
	_map.add_marker(MapRegistry.MarkerKind.NPC, Vector2(-120, 90), "Ferro")
	_map.add_marker(MapRegistry.MarkerKind.PORTAL, Vector2(540, 120), "Nebelbruch")
	_map.add_marker(MapRegistry.MarkerKind.MONSTER, Vector2(650, 110), "Moorling")
	_map.add_marker(MapRegistry.MarkerKind.MONSTER, Vector2(760, 170), "Moorling")
