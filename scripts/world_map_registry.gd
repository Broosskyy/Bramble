class_name BrambleWorldMapRegistry
extends Node

enum Cell { MEADOW, ROAD, WATER, DIRT, ELEVATION, WILDS }
enum MarkerKind { PLAYER, NPC, PORTAL, MONSTER }

var map_bounds := Rect2(-520, -320, 1420, 720)
var cell_size := 24.0
var _grid: Dictionary = {}
var _markers: Array[Dictionary] = []
var _player_world_pos := Vector2.ZERO

func _ready() -> void:
	add_to_group("world_map_registry")

func configure(bounds: Rect2, grid_cell_size: float) -> void:
	map_bounds = bounds
	cell_size = grid_cell_size
	_grid.clear()

func clear() -> void:
	_grid.clear()
	_markers.clear()

func paint_cell(world_pos: Vector2, cell_type: int, radius_cells: int = 2) -> void:
	var gx := int(round(world_pos.x / cell_size))
	var gy := int(round(world_pos.y / cell_size))
	for dx in range(-radius_cells, radius_cells + 1):
		for dy in range(-radius_cells, radius_cells + 1):
			_grid["%d,%d" % [gx + dx, gy + dy]] = cell_type

func add_marker(kind: int, world_pos: Vector2, label: String = "") -> void:
	_markers.append({"kind": kind, "pos": world_pos, "label": label})

func set_player_position(world_pos: Vector2) -> void:
	_player_world_pos = world_pos

func world_to_uv(world_pos: Vector2) -> Vector2:
	if map_bounds.size.x <= 1.0 or map_bounds.size.y <= 1.0:
		return Vector2.ZERO
	return Vector2(
		inverse_lerp(map_bounds.position.x, map_bounds.end.x, world_pos.x),
		inverse_lerp(map_bounds.position.y, map_bounds.end.y, world_pos.y)
	)

func render_image(size: Vector2i) -> Image:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(_cell_color(Cell.MEADOW))
	for y in range(size.y):
		for x in range(size.x):
			var uv := Vector2(float(x) / float(max(size.x - 1, 1)), float(y) / float(max(size.y - 1, 1)))
			var world_pos := Vector2(
				lerpf(map_bounds.position.x, map_bounds.end.x, uv.x),
				lerpf(map_bounds.position.y, map_bounds.end.y, uv.y)
			)
			img.set_pixel(x, y, _cell_color(_sample_cell(world_pos)))
	for marker in _markers:
		var kind := int(marker.get("kind", -1))
		if kind == MarkerKind.PLAYER:
			continue
		var pos: Vector2 = marker.get("pos", Vector2.ZERO)
		_draw_marker(img, pos, _marker_color(kind), 2)
	_draw_marker(img, _player_world_pos, _marker_color(MarkerKind.PLAYER), 3)
	return img

func _cell_color(cell_type: int) -> Color:
	match cell_type:
		Cell.ROAD:
			return Color(0.48, 0.44, 0.36)
		Cell.WATER:
			return Color(0.18, 0.34, 0.62)
		Cell.DIRT:
			return Color(0.42, 0.32, 0.22)
		Cell.ELEVATION:
			return Color(0.36, 0.30, 0.24)
		Cell.WILDS:
			return Color(0.16, 0.34, 0.14)
		_:
			return Color(0.22, 0.42, 0.18)

func _marker_color(kind: int) -> Color:
	match kind:
		MarkerKind.NPC:
			return Color(0.45, 0.82, 1.0)
		MarkerKind.PORTAL:
			return Color(0.72, 0.45, 1.0)
		MarkerKind.MONSTER:
			return Color(0.92, 0.35, 0.30)
		_:
			return Color(0.95, 0.85, 0.25)

func _sample_cell(world_pos: Vector2) -> int:
	var gx := int(round(world_pos.x / cell_size))
	var gy := int(round(world_pos.y / cell_size))
	var key := "%d,%d" % [gx, gy]
	if _grid.has(key):
		return int(_grid[key])
	var best: int = Cell.MEADOW
	var best_dist: float = INF
	for grid_key: String in _grid.keys():
		var parts: PackedStringArray = grid_key.split(",")
		if parts.size() != 2:
			continue
		var cell_pos := Vector2(float(parts[0]) * cell_size, float(parts[1]) * cell_size)
		var dist: float = world_pos.distance_squared_to(cell_pos)
		if dist < best_dist:
			best_dist = dist
			best = int(_grid[grid_key])
	return best

func _draw_marker(img: Image, world_pos: Vector2, color: Color, radius: int) -> void:
	var uv := world_to_uv(world_pos)
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return
	var cx := int(round(uv.x * float(img.get_width() - 1)))
	var cy := int(round(uv.y * float(img.get_height() - 1)))
	for y in range(cy - radius, cy + radius + 1):
		for x in range(cx - radius, cx + radius + 1):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			if Vector2(float(x - cx), float(y - cy)).length() <= float(radius) + 0.2:
				img.set_pixel(x, y, color)
