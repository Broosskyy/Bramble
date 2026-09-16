# World Presentation Standard

**Status:** `VISUAL_FOUNDATION_LOCKED = FALSE`  
**Reason:** Runtime-Screenshots zeigen weiterhin Fluss-Nähte, sichtbares Grass-Repeat-Muster und harte Baum-Occlusion in Combat-Framing. Dorf-Komposition und Minimap-Pipeline sind stabil genug als Basis, aber nicht final abgenommen.

**Project:** `BRAMBLE_GAME/`  
**Effective:** M02.2 (2026-09-16)

---

## Camera / Projection

- Fixed oblique 2.5D presentation per `assets/game/references/WORLD_CAMERA_SPEC.md`
- No free camera rotation in M02.x
- `CAMERA_OFFSET = (0, -64)`
- `CAMERA_SMOOTH_SPEED = 7.0`
- Limits: `Rect2(-1600, -1100, 3200, 2200)`

| Mode | Zoom constant |
|------|----------------|
| Landscape | `CAMERA_ZOOM_LANDSCAPE = 0.94` |
| Portrait | `CAMERA_ZOOM_PORTRAIT = 1.06` |

Same world geometry, collision, entities, and minimap data in both orientations — only presentation layout/zoom changes.

---

## Scale Categories

Defined in `scripts/world_presentation_config.gd`:

| Category | Value | Usage |
|----------|-------|--------|
| `SCALE_PLAYER` | 0.58 | Player visual |
| `SCALE_NPC` | 0.46 | NPCs |
| `SCALE_MONSTER_SMALL` | 0.52 | Moorling |
| `SCALE_BUILDING_SMALL` | 0.92 | Workshop, cottage, watchtower |
| `SCALE_BUILDING_LARGE` | 1.08 | Inn |
| `SCALE_TREE` | 0.82 | Red oak, apple tree |
| `SCALE_SHRUB` | 0.58 | Shrubs, flower beds |
| `SCALE_PROP_SMALL` | 0.50 | Signs, fences, crates |
| `SCALE_PROP_LARGE` | 0.64 | Fountain, bridge, stall |
| `SCALE_TERRAIN` | 0.68 | Ground repeat tiles |
| `SCALE_ROAD` | 0.74 | Cobble, banks |
| `SCALE_WATER` | 0.70 | River tiles |
| `SCALE_ELEVATION` | 0.78 | Cliff, ramp, stairs |
| `SCALE_PORTAL` | 0.80 | Portal arch |

Do not invent per-map scales outside these categories without updating this standard.

---

## Terrain Rules

**Pipeline:** `scripts/terrain_tile_placer.gd`

- Integer pixel snapping on placement
- Subpixel bleed via `TILE_BLEED_PX = 2.0` (water may use +4px)
- `TILE_OVERLAP = 1.015` in step calculation
- Layer z-indices: Ground < Road < Water < Overlay
- Base fill: `grass_repeat_256.png` only (no tiled meadow overlay grid)
- Roads use `tile_step()` spacing, not hardcoded pixel offsets
- Transitions: dirt shoulders on cobble, `river_edge` / `pond_edge_endcap`, fallen-leaves band village→wilds

**Do not:** scale tiles up arbitrarily to hide seams; use bleed/overlap + repeat singles.

---

## Footpoint Convention

- Component: `scripts/footpoint_sort.gd`
- Sort key: `sort_key(global_foot_y, height_level)`
- `SORT_HEIGHT_BIAS = 512` per height level
- `z_as_relative = false` for stable world layering
- Buildings/trees: explicit foot_y offset per asset in world builder

---

## Elevation Convention

- h0 = default ground
- h1 = `HEIGHT_H1_OFFSET = 56` via `BrambleElevationZone`
- Elevated visuals on `Elevated` node; ramps/stairs connect h0→h1
- Sorting includes `height_level` in footpoint component

---

## Occlusion Convention

- Manager: `scripts/occlusion_manager.gd`
- Only nodes in group `occluder` with metadata:
  - `occlusion_foot_y`
  - `occlusion_half_w`
  - `occlusion_height`
- Fade when player is behind canopy (lower screen Y than foot, above canopy top, within half-width)
- Smooth fade: `OCCLUSION_FADE = 0.52`, speed `8.0`
- No global/random fading

---

## Map Composition Rules

- Canonical zone: Village → Transition → Wilds in `visual_master_world_builder.gd`
- Full canvas fill via `WORLD_FILL_*` constants
- Semantic map bounds: `WORLD_MAP_BOUNDS`
- Markers registered for NPC, portal, monster spawn

---

## Minimap Pipeline

- Registry: `scripts/world_map_registry.gd` (painted during world build)
- Renderer: `scripts/runtime_minimap.gd` in production HUD
- Derived from world data — no hand-painted fake minimap
- Shows: meadow/road/water/wilds cells, player dot, NPC/portal/monster markers
- Refresh ~8 Hz

---

## Portrait / Landscape HUD

- `scripts/production_hud.gd` + `orientation_service.gd`
- Landscape: status top-left, quest below, minimap top-right, joystick bottom-left (below quest), combat bottom-right
- Portrait: adjusted vertical spacing; same data sources
- Fixed widget sizes with `EXPAND_IGNORE_SIZE`

---

## Asset Selection Rules

- Use production singles from `assets/game/_catalog/ASSET_MANIFEST.csv`
- Never use modal UI sheets (`kit78`, `world_map_frame`) as HUD overlays
- Do not use SOURCE_SHEET directly at runtime when a production single exists
- Slicing allowed only with catalog documentation; originals unchanged

---

## Runtime Capture (QA)

```powershell
& "C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe" `
  --path "BRAMBLE_GAME" res://scenes/main.tscn --m02_2-capture
```

Output: `artifacts/m02_2/*.png` (6 shots)
