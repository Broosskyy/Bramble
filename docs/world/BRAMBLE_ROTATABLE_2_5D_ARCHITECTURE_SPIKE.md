# BRAMBLE M04.25 — Rotatable Spatial 2.5D Architecture Spike

Status: validated architecture spike; no production migration performed
Engine: Godot 4.7.2, Compatibility renderer
Decision: **C — HYBRID / LIMITED CAMERA ROTATION**

## Executive result

BRAMBLE can technically place directional sprites inside a genuine `Node3D`
world, keep the player grounded with 3D collision, orbit a camera around
authoritative world coordinates, and preserve readable world-space NPCs and
monsters. The lab proves that the presentation architecture is viable.

It does **not** prove that the current asset library can support unrestricted
360-degree rotation at production quality. Character and NPC base art have
eight directions, but combat animation and equipment coverage do not.
Buildings, fences, and trees are predominantly authored as single oblique
views. Full rotation exposes missing backs, sides, roof treatment, and
directional equipment. The experimental spatial cottage remains coherent but
is visibly below BRAMBLE's Visual Masters.

The evidence therefore supports a limited yaw window around authored views
while a rotation-safe content pipeline is established. Camera yaw remains
client presentation only. Do not migrate the production Village from this
spike.

## Repository recovery

- Verified spike-start `HEAD`: `0bdd722f55899b660d234bdeda461550684f7804`
- Verified spike-start `origin/main`: `0bdd722f55899b660d234bdeda461550684f7804`
- Verified clean pre-M04.3 baseline: the same SHA.
- M04.3 production changes were already uncommitted when this spike began.
- Preserved modified files:
  - `artifacts/live/latest_gameplay.png`
  - `artifacts/live/latest_landscape.png`
  - `artifacts/live/latest_portrait.png`
  - `scenes/main.tscn`
  - `scripts/bootstrap.gd`
  - `scripts/npc.gd`
  - `scripts/visual_master_world_builder.gd`
  - `scripts/world_presentation_config.gd`
  - `tools/bramble_delivery.py`
- Preserved untracked `artifacts/m04_3/` with all 29 planned PNG captures.

### Interrupted M04.3 classification

- Scale implementation and shared world anchors: **COMPLETE in code**, not
  delivered.
- Village, transition, wilds, and combat-space recomposition: **PARTIAL**;
  runtime evidence retains rectangular terrain boundaries, crowding, and
  overlap.
- NPC scale and label adaptation: **COMPLETE in code**.
- M04.3 automated capture path: **COMPLETE in code**.
- Required M04.3 screenshot filenames: **COMPLETE as files**, but capture
  quality is **PARTIAL**. Five groups are byte-identical rather than
  independent evidence: `01/03/05`, `02/04/06`, `19/21`, `26/28`, and
  `27/29`.
- Canopy behavior: **COMPLETE** in the available normal/faded/combat evidence.
- NPC interaction verification: **NOT STARTED**; the captures move near Lina
  and Ferro but do not invoke interaction or show dialogue.
- Final visual acceptance: **BROKEN**; final portrait evidence retains abrupt
  terrain seams, and the final captures duplicate earlier states.
- Production smoke: **PARTIAL**; runtime reached the world, HUD, authority,
  and snapshot loop without script errors, but dedicated bootstrap did not
  honor the requested automatic shutdown.
- Snapshot/E2E delivery evidence: **NOT STARTED**; `snapshot_payload.txt` and a
  retained M03.1 E2E result are absent.
- M04.3 milestone documentation: **NOT STARTED**.
- Commit/push/remote delivery: **NOT STARTED**.
- Overall M04.3 WIP: **PARTIAL**, not safe to include in an M04.25 commit.

## Architecture audit

### Reusable as-is

- Authoritative RPG/domain state and persistence services in `scenes/main.tscn`.
- Equipment, inventory, quests, progression, loot, and save-state data.
- Network session, authority, entity IDs, snapshot cadence, and combat state.
- `scripts/orientation_service.gd` concept: one world, two presentation profiles.
- Content database and asset registry concepts.
- Screen-space HUD data sources and most responsive UI logic.

These systems do not intrinsically depend on camera yaw.

### Reusable with an adapter

- `scripts/player_controller.gd`: retain intent, speed, authority, and action
  semantics; adapt `Vector2` presentation coordinates to ground-plane `Vector3`
  (`x,z`) through a world-coordinate adapter.
- `scripts/player_visual.gd`: retain state/facing concepts; replace
  screen-vector direction selection with world-facing minus camera-yaw
  selection.
- `scripts/npc.gd` and `scripts/enemy.gd`: retain IDs, state, AI, rewards, and
  interaction; attach spatial presentation nodes and 3D bodies.
- `scripts/production_equipment_visual.gd` and `scripts/equipment_rig.gd`:
  retain equipment lookup; replace fixed 2D offsets with
  direction/pose/equipment attachment data.
- `scripts/combat_targeting_service.gd`: retain target identity, range, and
  cycling; replace 2D point queries and ring with ray-to-ground/3D selection
  and a ground-plane indicator.
- `scripts/combat_runtime_service.gd`: retain resolution; adapt visual hooks.
- `scripts/network_world_sync.gd`, remote players, and reconciliation: retain
  protocol semantics; map authoritative horizontal coordinates to the spatial
  ground plane. Camera yaw is never serialized.
- `scripts/runtime_minimap.gd`: retain registry/data flow; map `x,z`.
- Portals and elevation gameplay concepts: retain IDs/transitions; use 3D
  triggers and continuous or tiered world height.

### Needs replacement if migration happens

- `Camera2D` / `scripts/world_camera_controller.gd` with an orbiting `Camera3D`.
- `Node2D` production world root and `YSort`/`z_index` rendering.
- `scripts/visual_master_world_builder.gd` placement output. Its semantic
  composition can inform a new spatial builder, but its CanvasItem nodes,
  footpoint offsets, and collision construction cannot.
- `scripts/footpoint_sort.gd`; hardware depth replaces painter sorting.
- 2D collision/pathing and `PhysicsDirectSpaceState2D` queries.
- `scripts/elevation_service.gd` visual offsets; spatial Y and navigation links
  replace fake height offsets.
- `scripts/occlusion_manager.gd` screen-Y tests; replace with camera/player
  line-of-sight volumes or ray-aware material fading.

### Not relevant to world rendering

Identity, sessions, economy, shop, trade, audit, outbox, idempotency, item
instances, and most progression/quest state are presentation independent.

## Asset audit

| Category | Representative asset | Rotation finding |
|---|---|---|
| Player | `characters/base/male/directions/*.png` | Eight idle directions survive with camera-relative selection. Walk/run and attack coverage is partial. |
| Helmet | `assets/equipment/armor/leather_head.png` | Single-angle legacy overlay; does not survive side/back views. |
| Armor | `characters/equipment/armor/forest_male.png` | Single-angle outfit layer; no eight-direction set. |
| Weapon | `characters/equipment/weapons/melee/short_sword.png` | Readable, but needs per-direction attachment/depth rules. |
| NPC | `npcs/merchant/directions/*.png` | Eight directions survive camera rotation. Animations are missing. |
| Monster | `monsters/moorling/directions/kit60_*.png` | Four directions only; readable but direction changes are coarse. |
| Building | `world/buildings/cottage.png` | Excellent authored front; side/rear information absent. Cannot be used as a 360-degree building. |
| Large tree | `world/buildings/red_oak.png` | Single oblique view; cross-plane removes the paper edge but duplicates perspective cues. |
| Vegetation | `world/buildings/golden_shrubs.png` | Camera-facing billboard is acceptable for low-priority decoration. |
| Fence | `world/buildings/fence_straight.png` | Single oblique view; fixed plane exposes edge, billboard changes world orientation incorrectly. |
| Rock | Procedural lab mesh | No suitable canonical production rock single was found in the audited manifest. |
| Ground | `world/terrain/materials/grass_repeat_256.png` | Works on spatial ground. |
| Road | `world/terrain/materials/cobble_repeat_256.png` | Works on spatial ground, though road edge modules remain desirable. |
| Landmark | Cottage/oak composition | Existing frontal detail is strong but not multi-angle. |

Catalog readiness labels were written for fixed oblique 2.5D and must not be
interpreted as 360-degree readiness.

## Lab architecture

`scenes/labs/rotatable_2_5d_world_lab.tscn` is intentionally isolated. It uses:

- `Node3D` world root, textured `PlaneMesh` ground and paths.
- Spatial cottage shell, roof, collision volume, and canonical front artwork.
- `CharacterBody3D` player with capsule collision and grounded shadow.
- Billboarded world-space player, NPC, monster, and equipment layers.
- Camera-relative eight-direction body/NPC selection.
- Four-direction fallback for the Moorling.
- Cross-plane large oak with spatial trunk and camera-aware fade.
- Billboard shrubs; fixed-plane fence; procedural spatial rocks.
- Follow/orbit/zoom camera with 28–55 degree pitch and 8–19 unit zoom limits.
- Mouse drag/wheel and touch drag/magnify concepts.
- Screen-space HUD kept outside world transforms.

## Directional character model

World facing and view direction are distinct:

`relative_angle = world_character_facing - camera_yaw`

The angle is quantized into:

`front → front_right → right → back_right → back → back_left → left → front_left`

The billboard remains camera-facing; only the selected authored direction
changes. This avoids rotating the character as a cardboard sheet. The lab
proves idle direction selection and movement-facing selection. It does not
prove eight-direction attack because those assets are missing.

## Required decision answers

1. **Can BRAMBLE support this technically?** Yes. Godot's spatial world,
   Sprite3D, 3D physics, camera orbit, and screen HUD are sufficient.
2. **Does it visually improve the game?** Partially. Grounding and depth improve;
   unrestricted views reduce quality when assets lack sides/backs.
3. **Does it preserve BRAMBLE identity?** Character art and palette survive;
   prototype geometry does not yet meet the Visual Masters.
4. **Which systems can remain?** Authoritative state, domains, combat
   resolution, equipment data, networking semantics, persistence, and UI data.
5. **Which require adapters?** Movement, entity presentation, equipment,
   targeting, minimap, portals, snapshots, and orientation framing.
6. **Which world systems need migration?** Camera, builder output, collision,
   navigation, elevation rendering, sorting, and occlusion.
7. **Which current assets survive?** Ground/road textures and directional
   player/NPC bases. Some billboards survive within a limited yaw window.
8. **Which require new rules?** Buildings, trees, fences, large props,
   equipment, animation sets, shadows, and occlusion masks.
9. **How should buildings be produced?** Modular low-poly spatial shells with
   BRAMBLE-authored textures/materials on every visible side, coherent roofs,
   separate fadeable roofs/canopies, authored footprints, and collision.
10. **How should vegetation be produced?** Full/shallow geometry for large
    collision-critical trees; clustered cross-planes or billboards for small
    vegetation; authored pivots, LOD, and fade volumes.
11. **How should characters be rendered?** Camera-facing Sprite3D with
    camera-relative directional animation and world-facing gameplay state.
12. **How should equipment be layered?** The same direction, animation frame,
    attachment metadata, depth ordering, and SP compatibility as the body.
13. **How will SPs work?** Swap the directional body/animation set while
    preserving the spatial entity, facing, collision, authority, and compatible
    equipment sockets.
14. **How will pets work?** Independent spatial entities with authoritative
    ground positions and camera-relative directional presentation.
15. **How will partners work?** The pet model plus character-grade equipment,
    animation, combat, and formation adapters.
16. **How will fairies work?** Billboarded companion/effect nodes attached to
    spatial anchors; gameplay element/progression remains authoritative.
17. **How does landscape work?** Same world, base orbit distance, wider
    horizontal context, screen-space HUD.
18. **How does portrait work?** Same world with a 1.42 lab framing factor,
    protected touch regions, and responsive HUD. No geometry fork.
19. **Performance implications?** More meshes, depth, shadows, culling, and 3D
    physics, offset by eliminating Y-sort and using inexpensive sprites.
20. **Mobile implications?** Compatibility rendering is viable at lab scale;
    touch ownership, texture memory, overdraw, LOD, and device profiling remain
    production gates.
21. **Multiplayer implications?** World facing/position may replicate; camera
    yaw never does. Existing authority can remain if coordinate adapters are
    deterministic.
22. **Content-production implications?** This is the main cost: assets need
    multi-angle or spatial production standards, validation turntables,
    directional equipment matrices, pivots, collision, LODs, and budgets.

## Building validation

The canonical cottage works only at its authored front. The lab adds the
minimum spatial shell needed to test depth, roof, scale, collision, and
player relationship. Front, side, and rear captures prove spatial coherence
but also show the quality gap. The current cottage must not be stretched or
projected onto every side. Production requires authored side/rear materials or
a coherent spatial model that matches the painted front.

## Vegetation validation

- Pure billboard: inexpensive and suitable for small shrubs, but world
  orientation is lost.
- Cross-plane oak: no single paper edge and stable under full orbit, but the
  original oblique trunk/perspective is duplicated and becomes noticeable.
- Spatial trunk plus cross-plane canopy: best lab compromise.
- Large trees should ultimately use shallow/full spatial trunks and clustered
  canopy cards authored for rotation.
- Camera-aware alpha fade restores player readability, but does not repair bad
  placement or single-angle perspective.

## Combat, interaction, and mobile readability

The player, target, target ring, attack facing, NPC nameplate, and world depth
remain readable under orbit in landscape. Portrait remains playable using a
wider camera-distance profile, but close combat crops contextual space and the
production HUD needs explicit safe-area ownership. Camera drag must begin only
in safe world regions; movement joystick, targeting, and skill regions must
consume touches first. Pinch zoom can coexist because it is presentation-only.

The lab uses existing combat semantics only conceptually; it does not rewrite
or claim full integration with production combat.

## Multiplayer and authority safety

- Authoritative coordinates, collision, movement validation, combat, enemies,
  loot, equipment, quest state, and XP are independent of camera yaw.
- World-facing is gameplay/presentation state; view-relative sprite direction
  is derived locally.
- Do not append yaw, pitch, zoom, or selected view sprite to snapshots.
- Remote clients derive each entity's displayed direction from replicated
  world-facing and their own camera.

## Performance evidence

Warm profile on the lab at 1280×720:

- Nodes: 76
- Average FPS: 60.00
- Average draw calls: 90.00
- Sprite3D instances represented by the lab: 17
- Spatial mesh instances represented by the lab: 20
- Renderer/device: Godot Compatibility / NVIDIA GeForce RTX 5060

The lab is not a mobile-device benchmark. Draw count is modest and no obvious
CPU bottleneck appeared. Likely mobile risks are transparent canopy overdraw,
large unatlased character/equipment textures, dynamic shadows, and multiplying
unique materials. Performance feasibility is therefore PARTIAL until low/mid
mobile hardware is measured.

## NosTale principle analysis

Transferable principles demonstrated without copying content:

- A coherent traversable ground plane creates occupancy, not a backdrop.
- Restrained orbit and zoom keep the player as the anchor.
- Large readable sprites can inhabit a deeper world.
- Open traversal lanes, a readable interaction pocket, and a separated combat
  pocket matter more than decoration density.
- Buildings and vegetation frame space.
- Camera freedom must remain subordinate to targeting and touch controls.

The lab matches the spatial/sprite principle, not NosTale's assets, maps,
characters, names, UI, or exact composition.

## Visual Master comparison

- PASS: original BRAMBLE character/NPC/monster art, bright fantasy palette,
  large character scale, and spatial ground contact.
- PARTIAL: environment richness, controlled depth, portrait framing, target
  context, and vegetation.
- FAIL for production acceptance: unrestricted building sides/rears and
  directional equipment. The procedural cottage is evidence of required
  architecture, not a Visual Master-quality asset.

## Gate report

| Gate | Result |
|---|---|
| REPOSITORY_RECOVERY | PASS |
| M04_3_WIP_PRESERVED | PASS |
| ARCHITECTURE_AUDIT | PASS |
| ASSET_AUDIT | PASS |
| SPATIAL_WORLD_LAB | PASS |
| ROTATABLE_CAMERA | PASS |
| ZOOM | PASS |
| PLAYER_GROUNDING | PASS |
| DIRECTIONAL_CHARACTER | PASS |
| EQUIPMENT_DIRECTIONAL_VISUALS | PARTIAL |
| BUILDING_MULTIANGLE | PARTIAL |
| VEGETATION_MULTIANGLE | PARTIAL |
| OCCLUSION | PASS |
| NPC_INTERACTION_READABILITY | PASS |
| COMBAT_READABILITY | PARTIAL |
| LANDSCAPE_PRESENTATION | PASS |
| PORTRAIT_PRESENTATION | PARTIAL |
| MOBILE_FEASIBILITY | PARTIAL |
| PERFORMANCE_FEASIBILITY | PARTIAL |
| MULTIPLAYER_ARCHITECTURE_SAFETY | PASS |
| SP_FUTURE_COMPATIBILITY | PASS |
| PET_FUTURE_COMPATIBILITY | PASS |
| PARTNER_FUTURE_COMPATIBILITY | PASS |
| FAIRY_FUTURE_COMPATIBILITY | PASS |
| BRAMBLE_VISUAL_IDENTITY | PARTIAL |
| NOSTALE_PRINCIPLE_MATCH | PASS |
| VISUAL_MASTER_DIRECTION | PARTIAL |
| ARCHITECTURE_DECISION | PASS |
| SCREENSHOT_INSPECTION | PASS |

## Screenshot evidence

All required runtime captures exist in `artifacts/m04_25/`:

- `01`–`02`: default landscape/portrait.
- `03`–`10`: full eight-angle orbit.
- `11`–`15`: directional player and equipment.
- `16`–`18`: building front/side/rear.
- `19`–`22`: tree angles and occlusion fade.
- `23`–`24`: NPC interaction framing.
- `25`–`26`: combat framing.
- `27`–`29`: near/mid/far zoom.
- `30`–`31`: final landscape/portrait.

The images were generated by the Godot runtime and inspected individually.

## Recommendation

Choose **C — HYBRID / LIMITED CAMERA ROTATION**.

For the next production proof, constrain camera yaw around the authored
oblique view (initially approximately ±45 degrees), retain full zoom and
pitch limits, and produce one turntable-quality spatial building plus one
rotation-safe tree and a complete eight-direction equipment set. Re-run the
same gates on mobile hardware. Expand toward full rotation only when the asset
pipeline, not just the engine architecture, passes.
