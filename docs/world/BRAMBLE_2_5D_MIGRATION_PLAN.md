# BRAMBLE Rotatable 2.5D Migration Plan

Status: plan only; **do not execute during M04.25**
Trigger: M04.25 decision C — hybrid / limited camera rotation

## Migration principle

Keep authoritative gameplay and account/RPG state stable. Introduce a spatial
presentation boundary, migrate one disposable validation map first, and keep
the current production Village available until every acceptance gate passes.
Camera orientation is always local presentation data.

## System map

| Current system | Keep | Adapt | Replace | Migration risk |
|---|---|---|---|---|
| Player movement | Input intents, speed, authority, reconciliation | Map horizontal `Vector2(x,y)` to spatial `Vector3(x,height,z)`; camera-relative input resolves to world intent before validation | `CharacterBody2D` and 2D collision movement | HIGH: deterministic coordinate and collision parity |
| Camera | Follow smoothing and orientation profiles | Portrait/landscape framing, anchor bias, safe touch regions | `Camera2D` with constrained orbit `Camera3D` | MEDIUM: comfort and combat readability |
| World builder | Semantic anchors, density rules, map markers | New data-driven placement records and asset representation class | CanvasItem/Y-sort output from `visual_master_world_builder.gd` | HIGH: map/content pipeline |
| Collision | Layer meanings and authoritative validation policy | Shared footprint metadata and 2D↔3D test fixtures during transition | `CollisionShape2D`, 2D point/shape queries | HIGH: exploits and stuck states |
| Elevation | h0/h1/h2 gameplay semantics if still useful | Convert tiers to spatial Y, ramps, stairs, navigation links | Sprite Y offsets and elevation-only sort bias | HIGH: navigation and authority |
| Occlusion | Player/target readability rule and fade constants | Camera ray/volume detection, separate roof/canopy materials | Screen-Y canopy tests | MEDIUM: transparency/overdraw |
| NPCs | IDs, dialogue, quest state, interaction semantics | Spatial entity adapter, 3D trigger/range, camera-relative direction | Node2D visual host | MEDIUM |
| Enemies | AI, HP, rewards, aggro/range semantics, authority | Spatial body, navigation, facing and visual event adapter | CharacterBody2D visual/physics host | HIGH: combat parity |
| Combat | Authoritative resolution, cooldowns, damage, skills | Spatial range helpers, world-facing events, VFX anchors | 2D-only queries/indicators | HIGH |
| Equipment visuals | Equipment state and content lookup | Eight-direction pose/frame attachment schema shared with body/SP | Fixed screen offsets and single-angle overlay | HIGH: current assets incomplete |
| Targeting | Entity identity, range, cycling, validity | Camera ray to ground/entity, 3D target ring, touch priority | PhysicsPointQueryParameters2D | MEDIUM |
| Minimap | Registry, marker semantics, refresh policy | Read spatial `x,z`, height/level annotations | Direct assumptions that world Y is map Y | LOW |
| Portals | IDs, destination semantics, authority | Area3D triggers and spatial destination transforms | Area2D/canvas arch placement | MEDIUM |
| Quests | All state, rules, rewards, persistence | Spatial interaction presentation only | Nothing authoritative | LOW |
| Multiplayer | Session, peer IDs, snapshots, server authority | Coordinate codec/version, replicated world-facing, remote Sprite3D adapter | Node2D remote presentation | HIGH; never replicate camera |
| Snapshots | Tick rate, entity IDs, HP/state payload | Versioned `x,z,height/facing`; backward compatibility during proof | Interpretation of `x,y` as Canvas coordinates | HIGH |
| Save state | Character/RPG state | Version map location only if spatial coordinates differ | Nothing else | MEDIUM |
| UI | Data sources, inventory, skills, target state, dialogue | Project 3D anchors for labels/VFX; safe camera gesture regions | 2D world indicators only | MEDIUM |
| Landscape | Same-world rule, HUD profile | Orbit distance/FOV/anchor profile | Camera2D zoom constants | LOW |
| Portrait | Same-world rule, HUD profile | Wider distance, anchor bias, target framing, touch ownership | Camera2D zoom constants | MEDIUM |
| Asset pipeline | Canonical manifest and provenance | Representation class, pivots, units, turntables, LOD, collision, directional matrix | Fixed-oblique readiness as rotation readiness | HIGH |

## Proposed boundaries

### Authoritative world model

Use a camera-independent horizontal coordinate contract. During transition,
preserve current serialized field meaning where possible:

- Domain position: horizontal `x,z`, explicit height/tier.
- Domain facing: normalized world direction or quantized world angle.
- Presentation position: `Vector3(x, resolved_height, z)`.
- Local view direction: derived from world facing and camera yaw.

If wire compatibility requires existing `x,y` keys temporarily, document that
wire `y` maps to spatial `z`; do not silently mix height into that field.

### Presentation adapter

Create a spatial entity presenter that consumes:

- entity ID and type
- world transform/facing
- animation state and time
- equipment/SP appearance state
- target/status/VFX events

It owns Sprite3D selection and attachments but cannot mutate authoritative
combat, inventory, equipment, or progression.

### Asset representation metadata

Every world asset declares one representation:

- `SPATIAL_GEOMETRY`
- `SHALLOW_25D`
- `CROSS_PLANE`
- `BILLBOARD`
- `DIRECTIONAL_SPRITE`

Metadata also records unit scale, ground pivot, footprint/collision, visible
yaw range, LOD, shadow policy, fade group, and mobile budget.

## Staged delivery

### Phase 1 — production rules before map work

1. Lock coordinate/facing contracts and camera exclusion from snapshots.
2. Define directional animation/equipment matrix.
3. Define building, vegetation, material, collision, and LOD standards.
4. Create automated turntable and portrait/landscape capture tests.
5. Budget draw calls, transparent pixels, texture memory, and shadow casters.

Exit: one building, one large tree, player equipment, NPC, and monster pass
the M04.25 multi-angle captures without lab-only exceptions.

### Phase 2 — adapter proof on a disposable map

1. Add spatial entity presentation adapters.
2. Bridge movement, targeting, combat visual events, interaction, and minimap.
3. Add constrained yaw (approximately ±45 degrees), zoom, and pitch profiles.
4. Validate local and two-peer host/client play.
5. Validate low/mid mobile landscape and portrait.

Exit: gameplay parity, authority parity, device performance, and visual
acceptance. The production Village remains unchanged.

### Phase 3 — one production micro-zone

Build a new small zone using the spatial pipeline. Do not convert Hainweiler
in place. Include a portal, NPC, combat pocket, elevation connector, occluder,
and representative density bands. Run save/snapshot compatibility tests.

Exit: content production time and quality are predictable.

### Phase 4 — migration decision checkpoint

Choose one:

- Keep limited rotation permanently.
- Expand yaw only for zones/assets certified for wider rotation.
- Approve full rotation after all asset categories pass.
- Stop migration and retain fixed 2.5D.

Only after this checkpoint may a production Village migration be planned.

## Character and equipment production rules

- Eight directions for idle, walk/run, attack, cast, hit, defeated, and
  interaction-critical poses.
- Body, class, SP, armor, helmet, weapon/offhand, cosmetic, and status layers
  share direction and normalized frame time.
- Each layer supplies attachment/depth data for every direction and pose.
- Weapons may cross in front of or behind the body by direction.
- Missing directions are build errors, not mirrored silently where asymmetry
  matters.
- SP forms replace the base animation set and declare compatible equipment.

## Companion compatibility

Pets and partners use the same spatial entity presenter with their own
collision/navigation policy. Partners may use the character-grade equipment
schema. Fairies use spatial anchors plus billboard/effect rendering. Mounts
later replace or augment the rider pose set while preserving one authoritative
movement entity.

## Building production rules

- Spatial silhouette and roof must read from the supported yaw range.
- Every visible side is intentionally authored.
- Roof/canopy is a separate fadeable mesh/material group.
- Door, interaction point, footprint, collision, and navigation blockers share
  one local coordinate origin.
- Painted facade cards are allowed only when their supported yaw range is
  explicit and no paper edge becomes visible.
- Turntable captures are required before catalog status becomes
  `ROTATION_READY`.

## Vegetation production rules

- Large collision-critical trees: spatial/shallow trunk plus clustered canopy
  cards or full stylized geometry.
- Medium plants: cross-plane clusters with randomized but controlled yaw.
- Small decoration: billboards where silhouette does not imply world-facing.
- Supply conservative collision, fade volume, LOD, and shadow policy.
- Measure transparent overdraw in portrait as well as landscape.

## Mobile and performance gates

Test at minimum one low and one mid target device:

- sustained FPS and frame-time percentiles
- draw calls and material count
- texture memory and atlas behavior
- transparent overdraw
- shadow cost
- physics/navigation cost with representative entity count
- thermal behavior over a sustained session
- touch conflict between camera, movement, targeting, and skills

The desktop lab's 60 FPS / 90 draw calls is architecture evidence, not a
mobile performance approval.

## Multiplayer safety gates

- Server simulation produces the same result regardless of camera yaw.
- No camera fields appear in movement intents, snapshots, saves, or replay.
- Client camera-relative input is converted to world intent before sending.
- Remote view directions are derived locally from replicated world-facing.
- Host/client tests cover different camera yaws observing the same action.
- Snapshot payload growth is measured after any facing/height schema change.

## Rollback strategy

Keep spatial scenes and adapters additive until the micro-zone passes.
Production `scenes/main.tscn`, the current world builder, and 2D map remain the
fallback. Do not delete 2D assets or convert save data destructively. Gate any
future route switch behind a scene/map version rather than replacing current
resources in place.
