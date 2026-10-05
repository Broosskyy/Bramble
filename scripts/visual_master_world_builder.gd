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

const FOUNTAIN_POS := Vector2(-20, 70)
const LINA_POS := Vector2(155, 78)
const FERRO_POS := Vector2(-185, 72)
const PORTAL_POS := Vector2(735, 120)
const PORTAL_LANDING := Vector2(760, 205)
const MOORLING_POSITIONS := [
	Vector2(1030, 80),
	Vector2(1210, 150),
	Vector2(1080, 280),
]

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
	for pos in [Vector2(-610, 240), Vector2(280, 260), Vector2(1180, 330)]:
		TilePlacer.place(ground, "world/terrain/overlays/overlay_grass_clumps_256.png", pos, sc * 0.62, TilePlacer.Layer.OVERLAY)
	for pos in [Vector2(840, -80), Vector2(-540, -390)]:
		TilePlacer.place(ground, "world/terrain/overlays/overlay_grass_clumps_256.png", pos, sc * 0.58, TilePlacer.Layer.OVERLAY)
	for x in range(650, 1400, 220):
		for y in range(-100, 400, 180):
			TilePlacer.place(ground, "world/terrain/overlays/overlay_fallen_leaves_256.png", Vector2(x, y), sc * 0.38, TilePlacer.Layer.OVERLAY)
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
	var horizontal := "world/roads/road_horizontal.png"
	var horizontal_step := TilePlacer.tile_step(horizontal, sc) * 0.90
	var y_main := 140.0
	for i in range(7):
		var pos := Vector2(-650 + i * horizontal_step, y_main)
		_paint_road(pos, sc, horizontal)
	_paint_road(Vector2(-20, y_main), sc, "world/roads/road_cross.png")
	var vertical := "world/roads/road_vertical.png"
	var vertical_step := TilePlacer.tile_step(vertical, sc) * 0.86
	for i in range(3):
		var pos := Vector2(-180, 40 - i * vertical_step)
		_paint_road(pos, sc * 0.92, vertical)
	_paint_road(Vector2(540, 145), sc * 0.94, "world/roads/road_bend.png")
	_paint_road(Vector2(770, 155), sc * 0.92, "world/roads/road_cobble.png")

func _build_river() -> void:
	var sc_w := BrambleWorldPresentationConfig.SCALE_WATER
	var sc_r := BrambleWorldPresentationConfig.SCALE_ROAD
	var river_y := 420.0
	var water_step := TilePlacer.tile_step("world/terrain/materials/water_repeat_256.png", sc_w)
	var bank_scale := sc_r * 0.92
	var start_x := -760.0
	var cols := 12
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
	_place(objects, "world/buildings/stream_bridge.png", Vector2(260, river_y - 8), BrambleWorldPresentationConfig.SCALE_PROP_LARGE, 22.0)

func _build_village() -> void:
	var bl := BrambleWorldPresentationConfig.SCALE_BUILDING_LARGE
	var bs := BrambleWorldPresentationConfig.SCALE_BUILDING_SMALL
	var tr := BrambleWorldPresentationConfig.SCALE_TREE
	var ps := BrambleWorldPresentationConfig.SCALE_PROP_SMALL
	var pl := BrambleWorldPresentationConfig.SCALE_PROP_LARGE
	var sh := BrambleWorldPresentationConfig.SCALE_SHRUB

	_place(objects, "world/buildings/inn.png", Vector2(-500, -105), bl, 68.0, false, 0, 88.0, 150.0)
	_solid_rect(Vector2(-500, -26), Vector2(190, 108))
	_place(objects, "world/buildings/workshop.png", Vector2(-180, -130), bs * 1.08, 58.0, false, 0, 76.0, 120.0)
	_solid_rect(Vector2(-180, -64), Vector2(172, 94))
	_place(objects, "world/buildings/cottage.png", Vector2(220, -105), bs * 0.92, 54.0, false, 0, 66.0, 112.0)
	_solid_rect(Vector2(220, -44), Vector2(146, 94))
	_place(objects, "world/buildings/town_fountain.png", FOUNTAIN_POS, pl, 28.0)
	_place(objects, "world/buildings/village_well.png", Vector2(-365, 190), ps, 18.0)
	_place(objects, "world/buildings/garden.png", Vector2(-610, 160), ps * 1.12, 10.0)
	_place(objects, "world/buildings/flower_bed.png", Vector2(355, 205), sh * 0.82, 6.0)
	_place(objects, "world/buildings/hay_bales.png", Vector2(455, 255), ps, 8.0)
	_place(objects, "world/buildings/produce_cart.png", Vector2(-415, 270), ps, 12.0)
	_place(objects, "world/buildings/lantern_post.png", Vector2(85, 145), ps, 18.0)
	_place(objects, "world/buildings/bench_crates.png", Vector2(-585, 265), ps, 8.0)
	_place(objects, "world/buildings/blank_signpost.png", Vector2(475, 128), ps, 16.0)

	for x in [-700, -610, -520]:
		_place(objects, "world/buildings/fence_straight.png", Vector2(x, 325), ps * 0.95, 10.0)
	_place(objects, "world/buildings/fence_corner.png", Vector2(-735, 325), ps * 0.95, 10.0)
	_place(objects, "world/buildings/gate_fence.png", Vector2(500, 155), ps, 14.0)

	_place(objects, "world/buildings/red_oak.png", Vector2(-735, -90), tr, 68.0, true, 0, 42.0, 116.0)
	_solid_circle(Vector2(-735, -22), 28.0)
	_place(objects, "world/buildings/apple_tree.png", Vector2(465, -190), tr * 0.90, 60.0, true, 0, 38.0, 102.0)
	_solid_circle(Vector2(465, -130), 24.0)
	_place(objects, "world/buildings/golden_shrubs.png", Vector2(-680, 230), sh * 0.88, 6.0)
	_place(objects, "world/buildings/golden_shrubs.png", Vector2(430, 300), sh * 0.78, 6.0)

func _build_elevation() -> void:
	var sc := BrambleWorldPresentationConfig.SCALE_ELEVATION
	var base := Vector2(-650, -360)
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
	_place(objects, "world/buildings/market_stall.png", Vector2(500, 275), BrambleWorldPresentationConfig.SCALE_PROP_LARGE * 0.90, 26.0)
	_place(objects, "world/buildings/town_gate.png", Vector2(585, 95), BrambleWorldPresentationConfig.SCALE_PROP_LARGE * 1.08, 34.0)
	_place(objects, "world/buildings/blank_sign.png", Vector2(630, 245), BrambleWorldPresentationConfig.SCALE_PROP_SMALL, 12.0)
	var transition_oak := Vector2(620, -175)
	_place(objects, "world/buildings/red_oak.png", transition_oak, tr * 0.92, 64.0, true, 0, 40.0, 110.0)
	_solid_circle(transition_oak + Vector2(0, 60), 25.0)
	_paint_map(transition_oak, MapRegistry.Cell.WILDS)
	for pos in [Vector2(650, 315), Vector2(760, 300)]:
		_place(objects, "world/buildings/golden_shrubs.png", pos, sh * 0.78, 6.0)

func _build_wilds() -> void:
	var tr := BrambleWorldPresentationConfig.SCALE_TREE
	_place(objects, "world/buildings/ruined_arch.png", Vector2(1110, -185), BrambleWorldPresentationConfig.SCALE_PROP_LARGE * 0.92, 38.0, false, 0, 52.0, 100.0)
	for pos in [Vector2(935, -190), Vector2(1320, 15), Vector2(1280, 345)]:
		var half_w := 52.0
		var canopy := 150.0
		var sp := _place(objects, "world/buildings/red_oak.png", pos, tr * 0.92, 68.0, true, 0, half_w, canopy)
		if sp:
			sp.set_meta("occlusion_fade_radius", half_w * 3.2)
		_solid_circle(pos + Vector2(0, 62), 26.0)
		_paint_map(pos, MapRegistry.Cell.WILDS)
	for pos in [Vector2(920, 335), Vector2(1210, -115)]:
		_place(objects, "world/buildings/golden_shrubs.png", pos, BrambleWorldPresentationConfig.SCALE_SHRUB * 0.72, 6.0)

func _add_npc(id: String, name_text: String, role_text: String, pos: Vector2, production_path: String, scale_multiplier := 1.0) -> void:
	var n := BrambleNpc.new()
	n.npc_id = id
	n.npc_name = name_text
	n.npc_role = role_text
	n.use_production_assets = true
	n.production_texture_path = production_path
	n.presentation_scale = scale_multiplier
	n.position = pos
	npcs.add_child(n)

func _build_npcs() -> void:
	_add_npc("lina", "Lina", "Questgeberin", LINA_POS, "npcs/merchant/directions/front.png")
	_add_npc("ferro", "Ferro", "Schmied", FERRO_POS, "npcs/blacksmith/directions/front.png", 1.08)

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
	for pos in MOORLING_POSITIONS:
		_add_enemy(pos)

func _build_portals() -> void:
	_place(objects, "world/portals/portal_arch_active.png", PORTAL_POS, BrambleWorldPresentationConfig.SCALE_PORTAL, 40.0)
	var p := BramblePortal.new()
	p.portal_name = "Nebelbruch"
	p.destination = PORTAL_LANDING
	p.show_marker_visual = false
	p.position = PORTAL_POS
	portals.add_child(p)

func _register_map_markers() -> void:
	_map.add_marker(MapRegistry.MarkerKind.NPC, LINA_POS, "Lina")
	_map.add_marker(MapRegistry.MarkerKind.NPC, FERRO_POS, "Ferro")
	_map.add_marker(MapRegistry.MarkerKind.PORTAL, PORTAL_POS, "Nebelbruch")
	for pos in MOORLING_POSITIONS:
		_map.add_marker(MapRegistry.MarkerKind.MONSTER, pos, "Moorling")
