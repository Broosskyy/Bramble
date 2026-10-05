class_name BrambleWorldPresentationConfig
extends RefCounted

const GAME_ROOT := "res://assets/game/"
const LEGACY_CATALOG := "res://assets/catalog_legacy/png/"

# --- Scale Master (M04.3) ---
# Player height is the canonical 1.0 world anchor. Source art has materially
# different native dimensions, so these values intentionally are not equal.
const SCALE_PLAYER := 0.38
const SCALE_NPC := 0.34
const SCALE_NPC_LARGE := 0.38
const SCALE_MONSTER_SMALL := 0.37
const SCALE_BUILDING_SMALL := 1.04
const SCALE_BUILDING_LARGE := 1.30
const SCALE_TREE := 0.70
const SCALE_SHRUB := 0.58
const SCALE_PROP_SMALL := 0.44
const SCALE_PROP_LARGE := 0.58
const SCALE_TERRAIN := 0.68
const SCALE_ROAD := 0.64
const SCALE_WATER := 0.70
const SCALE_ELEVATION := 0.78
const SCALE_PORTAL := 0.72
const TILE_OVERLAP := 1.015
const TILE_BLEED_PX := 3.5

const WORLD_MAP_BOUNDS := Rect2(-800, -460, 2200, 1040)
const WORLD_MAP_CELL_SIZE := 24.0

# Legacy aliases used by entity scripts
const PLAYER_VISUAL_SCALE := SCALE_PLAYER
const NPC_SCALE := SCALE_NPC
const MONSTER_SCALE := SCALE_MONSTER_SMALL
const WORLD_SPRITE_SCALE := SCALE_TERRAIN

# --- World anchors ---
const PLAYER_SPAWN := Vector2(-20, 225)
const VILLAGE_CAMERA_FOCUS := Vector2(-20, 150)
const WILDS_CAMERA_FOCUS := Vector2(820, 150)
const COMBAT_CAMERA_FOCUS := Vector2(1110, 160)
const WORLD_FILL_ORIGIN := Vector2(-980, -680)
const WORLD_FILL_COLS := 15
const WORLD_FILL_ROWS := 10

const HEIGHT_H1_OFFSET := 56.0
const HEIGHT_H2_OFFSET := 112.0
const SORT_HEIGHT_BIAS := 512

const CAMERA_OFFSET := Vector2(0, -64)
const CAMERA_SMOOTH_SPEED := 7.0
const CAMERA_ZOOM_LANDSCAPE := 0.94
const CAMERA_ZOOM_PORTRAIT := 1.06
const CAMERA_LIMITS := Rect2(-920, -620, 2480, 1480)

const OCCLUSION_FADE := 0.16
const OCCLUSION_FADE_SPEED := 9.0
const OCCLUSION_MIN_PLAYER_DEPTH := 8.0

const HUD_SAFE_MARGIN := 16.0
const HUD_JOYSTICK_ZONE_HEIGHT := 200.0

static func game_tex(relative_path: String) -> Texture2D:
	var path := relative_path
	if not path.begins_with("res://"):
		path = GAME_ROOT + relative_path.trim_prefix("/")
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

static func tile_step(path: String, scale_value: float) -> float:
	var tex := game_tex(path)
	if tex == null:
		return 256.0 * scale_value * TILE_OVERLAP
	return tex.get_size().x * scale_value * TILE_OVERLAP

static func sort_key(foot_y: float, height_level: int = 0) -> int:
	return clampi(int(foot_y) + height_level * SORT_HEIGHT_BIAS, -4096, 4096)
