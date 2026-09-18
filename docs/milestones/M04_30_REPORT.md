# BRAMBLE M04.30 — Spatial Gameplay Production Convergence

Date: 2026-09-18
Engine: Godot 4.7.2
Status: **PARTIAL**
Production decision: **C — PRESENTATION STILL NEEDS ANOTHER CONVERGENCE PASS**

## Repository and safety

- Starting `HEAD`: `743c71e0bc9038a669d1a950c32d596b8db012cf`
- Starting `origin/main`: `743c71e0bc9038a669d1a950c32d596b8db012cf`
- Branch: `main`
- Implementation commit: `4df681f2a6e9c58409b303410899ba5b7f3e5c81`
- M04.3 WIP: preserved, uncommitted, and excluded from M04.30 staging
- M04.30 was added as `scenes/world/amberway_moor_m04_30.tscn`; the protected
  2D `main.tscn` route was not replaced.

Protected M04.3 tracked changes remain in `artifacts/live/latest_*.png`,
`scenes/main.tscn`, `scripts/bootstrap.gd`, `scripts/npc.gd`,
`scripts/visual_master_world_builder.gd`,
`scripts/world_presentation_config.gd`, and `tools/bramble_delivery.py`.
The 29 `artifacts/m04_3/` captures and associated untracked script UID files
also remain uncommitted.

## What was implemented

`SpatialEntityPresenter` is a reusable `Node3D` presentation boundary. It
consumes camera-independent world facing, gameplay state, normalized time,
body replacement/companion slots, and equipment IDs/visibility. Local camera
yaw is supplied separately and never enters the authoritative snapshot.

The data profile supports `ONE_DIRECTION`, `TWO_DIRECTION`,
`FOUR_DIRECTION`, `EIGHT_DIRECTION`, `CAMERA_BILLBOARD`, and `CUSTOM`.
States independently select direction mode, authored direction frames, cel
sequences, generic keyposes, nearest-direction fallback, explicit mirroring,
fallback state, and procedural motion. Exact/cel/generic resolution resets
mirroring, empty custom direction sets are guarded, and equipment texture
types clear stale atlas frame state.

The Amberway Moor scene provides:

- camera-relative world movement on a spatial `CharacterBody3D`;
- constrained orbit from -10° to 80° absolute (±45° around the 35° authored
  center), 34°–48° pitch, and 10–18 orthographic zoom;
- one entrance/route, detailed Wayfarer Hall, waystone landmark, NPC pocket,
  three-Moorling combat clearing, vegetation, props, and perimeter framing;
- target ring and target HP panel;
- player anticipation, slash impact, damage, recovery, Moorling hit/defeat,
  leaf-mote drop/pickup, XP/level, and visible equipment reward;
- compact responsive landscape/portrait HUD;
- camera-line canopy and roof fades.

## Moorling

Canonical Kit60 cardinal direction assets provide identity and direction.
Kit70-derived attack cels and Kit71-derived hit/defeated cels provide generic
actions. Movement uses spatial displacement, four-direction view resolution,
and restrained bob/squash. No Kit21 content, generated art, silent mirroring,
or false diagonal claims are present.

Runtime evidence shows four directions plus generic action cels are sufficient
for this limited-yaw standard-monster slice. Authored locomotion would improve
quality but is not a P0 blocker. Direction-bound attacks remain a P1 need if
future camera range or monster prominence increases.

## Player and equipment

The player uses eight canonical body directions. The authoritative local slice
changes from `starter_clothes` (ATK 8, DEF 3, zero equipment layers) to
`wayfarer_set` (ATK 14, DEF 9, helmet + armor + weapon). The three layers share
direction, state, normalized action time, pivot, scale, and explicit depth.
Weapon front/behind priority and directional sockets are profile data.

Helmet and armor use the explicitly experimental M04.26 Wayfarer directional
atlases; the sword is canonical BRAMBLE equipment. Idle, movement, attack
anticipation, impact, and recovery are captured. Authored body/equipment
movement and attack pose atlases remain a quality gap; procedural motion does
not claim those missing frames.

## Visual findings

Compared with M04.26, the new slice removes the exposed rectangular world edge,
replaces full-width diagnostic HUD bars with compact panels, adds a denser
coherent route composition, reduces nameplate clutter, improves Hall
multi-angle detail, makes equipment progression visible, and clarifies the
combat/reward chain.

The player is readable and spatially grounded in both orientations. Supported
camera bounds preserve the building/tree illusion. The canonical Moorling
identity survives direction changes and action cels.

The result remains below the Visual Masters in painterly building finish,
organic terrain/path edges, layered distance scenery, bespoke player attack
poses, premium touch controls, and overall environmental richness. It is a
playable small MMORPG slice, but not yet strong enough to approve broad zone
production.

## Performance

M04.26 completion baseline:

- 261 nodes
- about 282 draw calls
- 45 unique materials
- 24 transparent geometry instances
- 92 shadow casters

M04.30 desktop automated profile:

- 148 nodes
- 130 average draw calls
- 31 unique materials
- 43 transparent instances
- 63 shadow casters
- 73 mesh instances / 36 Sprite3D instances
- 5 collision shapes / 4 animated entities
- 1161.89 unthrottled process-frame iterations per second
- 0.861 ms measured wall-clock per automated process frame
- Godot `Performance.TIME_PROCESS`: 243.099 ms in the headless capture profile

The M04.26 and M04.30 scenes differ in content and are not an apples-to-apples
optimization benchmark. The headless throughput and Godot process monitor use
different timing semantics. Neither is a mobile performance claim. Transparent
overdraw and 63 shadow casters require device profiling.

## Mobile

- Desktop landscape runtime/capture: PASS
- Desktop portrait runtime/capture: PASS
- Safe-world camera drag ownership concept: PASS
- Android templates: PRESENT
- Android export preset: MISSING
- Android build: BLOCKED
- ADB/real device: MISSING
- Real-device test: BLOCKED

## Multiplayer and authority

The existing two-process ENet E2E passed host/client movement, remote entity
creation/removal, disconnect cleanup, reconnect, screenshots, and combat
sanity. Existing snapshots contain no camera state.

M04.30 smoke asserts that camera yaw/pitch are absent from the spatial slice's
authoritative snapshot. World facing, state, target, equipment IDs/stats,
position, XP, level, and Moorling HP are camera-independent. Camera-relative
input is converted to a world vector before movement.

## Asset pipeline

`m04_30_entity_profiles.json` records canonical Kit60/70/71, player, NPC, and
experimental Wayfarer provenance. The existing catalog remains the source of
truth. `tools/validate_asset_catalog.py` passes with 16 overrides and 24
Moorling runtime assets; 12 pre-existing collisions, 27 historical masters,
and the merchant directory split remain `REVIEW_REQUIRED`.

## Art-gap report

### P0

- None for this constrained M04.30 slice.

### P1

- Authored player/body + helmet/armor/weapon movement and attack pose atlases.
- Painterly multi-angle Wayfarer Hall materials/detail matching BRAMBLE masters.
- Direction-bound Moorling attacks if camera range or encounter prominence
  expands.

### P2

- Organic path-edge modules and richer depth/backdrop composition.
- Lower-cost shadow policy and transparent-overdraw pass after device evidence.
- Premium touch-control artwork and final safe-area tuning.
- More distinctive loot rarity/pickup VFX and audio.

### NOT REQUIRED

- Universal eight-direction Moorling idle/action generation for the certified
  ±45° slice.
- Mirrored Moorling art.
- Camera yaw in network/save state.
- Full SP implementation in M04.30.

## Tests and gates

- Project parses: PASS
- Main scene boots/smoke: PASS
- M04.30 scene boots/smoke: PASS (`nodes=151` during assertions)
- Player movement: PASS
- Camera follow/yaw/pitch/zoom: PASS
- Landscape/portrait framing: PASS
- Moorling idle/move/direction/attack/hit/defeated: PASS
- Target selection and HP feedback: PASS
- Loot drop/pickup and XP/level: PASS
- Equipment stats and visible 0→3 layer change: PASS
- Equipment idle/move/attack synchronization: PASS, final pose art PARTIAL
- NPC approach/dialogue: PASS
- Canopy/roof occlusion: PASS
- Broken asset references: PASS
- Kit21/Moorling regression: PASS
- Asset catalog integrity: PASS with documented pre-existing review items
- Multiplayer E2E: PASS
- Camera state client-local: PASS
- Android build: BLOCKED
- Real device: BLOCKED
- M04.3 WIP preserved/uncommitted: PASS
- Screenshot inspection and iteration: PASS

## Fresh screenshots

All captures are under `artifacts/m04_30/`:

1. `01_entrance_route_landscape.png`
2. `02_entrance_route_portrait.png`
3. `03_camera_left_bound.png`
4. `04_camera_center.png`
5. `05_camera_right_bound.png`
6. `06_equipment_idle_front.png`
7. `07_equipment_move_side.png`
8. `08_equipment_attack_anticipation.png`
9. `09_equipment_attack_impact.png`
10. `10_equipment_attack_recovery.png`
11. `11_equipment_after_upgrade.png`
12. `12_npc_approach.png`
13. `13_npc_interaction.png`
14. `14_moorling_target_cardinal.png`
15. `15_moorling_attack_anticipation.png`
16. `16_moorling_attack_keypose.png`
17. `17_moorling_hit.png`
18. `18_moorling_defeated_loot.png`
19. `19_loot_pickup_feedback.png`
20. `20_canopy_occlusion_fade.png`
21. `21_roof_occlusion_fade.png`
22. `22_waystone_landmark.png`
23. `23_area_overview_left.png`
24. `24_area_overview_right.png`
25. `25_combat_clearing_portrait.png`
26. `26_final_progression_portrait.png`
27. `27_final_playable_landscape.png`
28. `28_moorling_idle_landscape.png`
29. `29_moorling_movement_landscape.png`
30. `30_npc_interaction_portrait.png`
31. `31_camera_right_bound_portrait.png`
32. `32_final_combat_portrait.png`

## Files

- `scenes/world/amberway_moor_m04_30.tscn`
- `scripts/world/amberway_moor_m04_30.gd` and UID
- `scripts/spatial/spatial_entity_presenter.gd` and UID
- `data/spatial/m04_30_entity_profiles.json`
- `docs/world/BRAMBLE_SPATIAL_ENTITY_PRESENTATION_STANDARD.md`
- `docs/art/BRAMBLE_ANIMATION_PRODUCTION_STANDARD.md`
- `docs/art/BRAMBLE_ROTATION_READY_ASSET_STANDARD.md`
- `references/.gdignore`
- `artifacts/m04_30/performance.txt`
- `artifacts/m04_30/*.png`
- `docs/milestones/M04_30_REPORT.md`
- `artifacts/live/LIVE_BUILD.md`

## Next recommended milestone

Run one focused **M04.31 painterly environment and authored player-action
convergence** pass on this same scene: replace the Hall/material and
player/equipment attack P1 gaps, then profile the unchanged slice on one low
and one mid Android device before approving zone production.
