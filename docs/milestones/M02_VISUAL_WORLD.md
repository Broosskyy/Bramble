# M02 — Visual Master World + Canonical Assets

**Date:** 2026-09-15  
**Project:** `BRAMBLE_GAME/`  
**Milestone:** Production asset foundation + visual world presentation

## Asset Foundation Deployment

| Item | Status |
|------|--------|
| Source | Pre-built `assets/game/` from Asset Foundation 01 (924 files) |
| Method | Validated + copied from existing foundation output (kits 1–93 via `tools/asset_foundation_01.py`) |
| Location | `BRAMBLE_GAME/assets/game/` |
| Catalog | `assets/game/_catalog/` (ASSET_MANIFEST.csv, WORLD_READINESS.md, etc.) |
| Legacy runtime | **Preserved** — `assets/catalog_legacy/`, `assets/equipment/`, `assets/animation_frames/` unchanged |

### Counts

| Library | Files |
|---------|------:|
| assets/game (total) | 924 |
| world | 114 |
| characters | 308 |
| monsters | 96 |
| npcs | 40 |
| ui | 70 |
| Legacy catalog_legacy PNG | ~80 |

## Production World

| Item | Value |
|------|-------|
| Scene | `scenes/world/visual_master_world.tscn` |
| Builder | `scripts/visual_master_world_builder.gd` |
| Active in main | Yes — `VisualMasterWorld` instanced in `main.tscn` |
| Legacy gallery | `Village` node preserved, hidden (`visible=false`, F9 toggles debug) |

### Composition (Village → Wilds slice)

- Seamless meadow/earth terrain tiles (`world/terrain/seamless/`)
- Main cobble road + side path (`world/roads/`)
- River + riverbank + stream bridge (`world/terrain/seamless/river.png`, `world/buildings/stream_bridge.png`)
- Inn, workshop, cottage, fountain, well, fences, gardens
- Elevated shrine ledge (h1) with earthen ramp + watchtower
- Wilds: ruined arch, market stall, combat zone trees
- Portal arch to wilds (`world/portals/portal_arch_active.png`)

## Production Assets Used (sample)

| Element | Path |
|---------|------|
| Terrain meadow | `world/terrain/seamless/meadow.png` |
| Road | `world/roads/road_cobble.png` |
| Inn | `world/buildings/inn.png` |
| Workshop | `world/buildings/workshop.png` |
| Bridge | `world/buildings/stream_bridge.png` |
| Ramp h0→h1 | `world/elevation/earthen_ramp.png` |
| Player (8-dir) | `characters/base/male/directions/*.png` |
| NPC Lina | `npcs/merchant/directions/front.png` |
| NPC Ferro | `npcs/blacksmith/directions/front.png` |
| Monster | `monsters/moorling/directions/kit60_front.png` |
| HUD panel | `ui/hud/player_status_panel.png` |
| Touch attack | `ui/touch/attack.png` |

## Player Scale

| Setting | Legacy | Production M02 |
|---------|--------|----------------|
| Visual scale | 0.20 | 0.52 (`BrambleWorldPresentationConfig.PLAYER_VISUAL_SCALE`) |
| World sprite scale | ~0.56–0.80 | 0.34 (`WORLD_SPRITE_SCALE`) |
| Spawn | (0, 360) | (-120, 180) |
| Equipment rig | Visible | Hidden in production mode |
| Animation | Registry poses | 8-direction production sprites |

## Footpoint Model

- `BrambleFootpointSort` on player, NPCs, enemies, world sprites
- Sort key: `clamp(int(foot_y) + height_level * 512, -4096, 4096)`
- Sprites offset upward; logical foot at node origin
- y_sort_enabled on WorldObjects, Elevated, NPCs, Monsters layers

## Elevation

| Level | Offset | M02 usage |
|-------|--------|-----------|
| h0 | 0 | Default ground |
| h1 | 56px visual bias | Shrine ledge + `BrambleElevationZone` |
| h2 | 112px (prepared) | Not placed in slice |

Services: `BrambleElevationService` + `BrambleElevationZone`

## Occlusion

- `BrambleOcclusionManager` fades `occluder` group (large trees) to 42% alpha when player behind

## Camera

- `BrambleWorldCameraController` on Player/Camera2D
- Smooth follow, configurable zoom
- Landscape zoom: 0.68 | Portrait zoom: 0.82
- Spec reference: `assets/game/references/WORLD_CAMERA_SPEC.md`

## Orientation

- `BrambleOrientationService` — viewport aspect → portrait/landscape
- Same world state; adjusts camera zoom + HUD layout
- No duplicate scenes or gameplay state

## HUD

| Layer | Role |
|-------|------|
| `ProductionHUD` | Production UI (HP/MP, quest, minimap frame, touch controls) |
| `HUD` (dev_hud) | Legacy debug — asset gallery, dev labels — hidden by default |
| Toggle | F9 switches legacy gallery + debug HUD |

## Missing Assets / Substitutions

| Requested | Resolution |
|-----------|------------|
| `golden_shrub.png` | Corrected to `golden_shrubs.png` |
| Individual tree PRODUCTION_SINGLE | Used `world/buildings/red_oak.png`, `apple_tree.png` (catalog lists some vegetation under buildings) |
| Dedicated vegetation kit singles | Partial — overlays used for grass clumps |
| Moorling 8-dir runtime animation | Static `kit60_front.png` for M02 |

## Known Problems

1. Terrain tiling is grid-based — not yet seamless edge blending
2. Player uses direction stills, not walk cycle per direction
3. Elevation affects sort bias; full collision height separation incomplete
4. Some catalog paths use Windows-style folder names (`monsters\moorling\...`) — runtime uses forward-slash canonical paths
5. Portrait layout needs device safe-area tuning

## Runtime Validation (Godot 4.7.2)

| Test | Result |
|------|--------|
| Project import | PASS (824 new assets) |
| Main scene load | PASS |
| Visual Master World build | PASS |
| Script errors (post-fix) | None in 3s smoke |
| z_index overflow | FIXED (sort bias 512) |
| Production HUD bind | FIXED (TextureButton button_up) |

## Screenshots

Captured via Godot 4.7.2 runtime (`--m02-capture portrait`):

| File | Path |
|------|------|
| Landscape 1920×1080 | `artifacts/m02/landscape_world.png` |
| Portrait 1080×1920 | `artifacts/m02/portrait_world.png` |
