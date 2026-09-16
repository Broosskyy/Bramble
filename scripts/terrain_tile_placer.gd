class_name BrambleTerrainTilePlacer
extends RefCounted

enum Layer { GROUND, ROAD, WATER, OVERLAY }

static func place(
	parent: Node2D,
	path: String,
	pos: Vector2,
	scale_value: float,
	layer: Layer = Layer.GROUND,
	z_bias: int = 0,
	extra_bleed_px: float = -1.0
) -> Sprite2D:
	var tex := BrambleWorldPresentationConfig.game_tex(path)
	var sp := Sprite2D.new()
	sp.texture = tex
	if tex == null:
		push_warning("BRAMBLE terrain: missing %s" % path)
		parent.add_child(sp)
		return sp

	var bleed := extra_bleed_px if extra_bleed_px >= 0.0 else BrambleWorldPresentationConfig.TILE_BLEED_PX
	var tex_w := maxf(tex.get_size().x, 1.0)
	var final_scale := scale_value * (1.0 + (bleed * 2.0) / (tex_w * scale_value))
	sp.position = Vector2(snapped(pos.x, 1.0), snapped(pos.y, 1.0))
	sp.scale = Vector2.ONE * final_scale
	sp.centered = true
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sp.z_as_relative = false
	sp.z_index = _layer_z(layer) + z_bias
	parent.add_child(sp)
	return sp

static func fill_grid(
	parent: Node2D,
	path: String,
	origin: Vector2,
	cols: int,
	rows: int,
	scale_value: float,
	layer: Layer = Layer.GROUND
) -> void:
	var step := BrambleWorldPresentationConfig.tile_step(path, scale_value)
	var snapped_origin := Vector2(snapped(origin.x, 1.0), snapped(origin.y, 1.0))
	for x in range(cols):
		for y in range(rows):
			place(parent, path, snapped_origin + Vector2(x * step, y * step), scale_value, layer)

static func tile_step(path: String, scale_value: float) -> float:
	return BrambleWorldPresentationConfig.tile_step(path, scale_value)

static func _layer_z(layer: Layer) -> int:
	match layer:
		Layer.GROUND:
			return -4090
		Layer.ROAD:
			return -4080
		Layer.WATER:
			return -4070
		Layer.OVERLAY:
			return -4060
	return -4050
