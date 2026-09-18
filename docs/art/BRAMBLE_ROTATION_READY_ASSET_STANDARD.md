# BRAMBLE Rotation-Ready Asset Standard

Status: M04.26 certification contract; direction requirements refined by M04.30
Applies to: spatial 2.5D world presentation

Direction coverage is now adaptive per
`BRAMBLE_ANIMATION_PRODUCTION_STANDARD.md`. Certification records the art that
actually exists per state; it does not force every entity into an
eight-direction matrix.

## Certification

Every spatial asset declares one certification state:

- `FIXED_VIEW_ONLY`: valid only at its authored camera bearing.
- `LIMITED_ROTATION_READY`: accepted within an explicit yaw interval.
- `WIDE_ROTATION_READY`: accepted across a broad interval but not a turntable.
- `FULL_ROTATION_READY`: accepted through a complete 360-degree turntable.

Certification is evidence, not intent. It requires runtime captures at the
declared yaw limits, correct scale/pivot/collision, and mobile-budget review.
A category may legitimately remain fixed-view.

## Required metadata

Use the canonical asset catalog when the schema is extended. Experimental
proofs may use a versioned spatial metadata file such as
`data/spatial/rotation_certified_assets_m04_26.json`.

Each entry records:

- representation type: `SPATIAL_GEOMETRY`, `SHALLOW_25D`, `CROSS_PLANE`,
  `BILLBOARD`, or `DIRECTIONAL_SPRITE`
- certification and supported yaw interval
- ground pivot and canonical world scale
- footprint and collision representation
- occlusion group and fade behavior
- shadow policy and LOD policy
- mobile draw/transparent-layer budget
- source provenance and import settings

## Shared import requirements

- Preserve source files and provenance.
- Alpha edges must not fringe against bright or dark backgrounds.
- Generate mipmaps for world sprites that change screen size.
- Use atlases for directional layers where it reduces material changes without
  wasting excessive transparent texture area.
- Use sRGB for color art and linear data for masks.
- Name pivots, sockets, collision, fade groups, and LODs consistently.
- Reject unbounded texture sizes or one-off scale compensation.

## Character contract

Representation: camera-facing `DIRECTIONAL_SPRITE`.

- Player and SP profiles normally justify eight-direction idle coverage, but
  each state declares its authored coverage and explicit fallback policy.
- Required baseline capabilities are idle, movement, attack, cast when used,
  hit, and defeated; a capability may combine authored art and approved
  procedural augmentation without claiming nonexistent directional frames.
- World facing is authoritative; displayed direction is world facing minus
  local camera yaw.
- Ground pivot is the center between the feet and remains stable across frames.
- Scale is shared across body, class, SP, and equipment layers.
- Turntable validation includes idle and movement at supported yaw limits.
- Mobile review covers transparent overdraw, atlas memory, and minimum readable
  on-screen height.

## Equipment contract

Representation: directional sprite layers synchronized with the character.

- Helmet/hat, armor/outfit, weapon/offhand, and cosmetics are independent
  layers.
- Every visible layer supplies direction, pose/frame, attachment point, and
  depth rule.
- Weapon depth may move behind or in front of the body by direction.
- Asymmetric equipment must not be mirrored blindly.
- Required baseline states are idle and movement. Combat-capable weapons also
  require attack alignment.
- Missing direction/pose coverage is `PARTIAL`, never silently certified.
- The M04.26 Wayfarer set demonstrates the eight-direction idle/movement
  contract; its attack animation remains a limited proof rather than a final
  production animation set.

## SP contract

An SP is a complete directional appearance/animation set, not a recolor.

- It replaces the active visual body set without replacing authoritative
  character identity.
- It declares class compatibility, skills/VFX identity, equipment
  compatibility, sockets, scale, and collision assumptions.
- It follows the same direction, pivot, turntable, and mobile requirements as
  base characters.

## NPC contract

Representation: directional sprite unless a specific NPC is spatial geometry.

- Eight directions for NPCs that can turn under camera yaw.
- Idle is mandatory; movement is mandatory for mobile NPCs.
- Ground pivot, interaction anchor, nameplate anchor, and quest indicator
  anchor are explicit.
- Interaction range and collision are gameplay data, not inferred from pixels.

## Monster contract

Representation: directional sprite or spatial geometry per creature.

- Required directions follow visual importance, supported camera range, and
  runtime evidence. Standard monsters may use one, two, or four authored
  directions with explicit nearest-direction fallback.
- Required states: idle, movement, attack, hit, defeated/death.
- Target-ring radius, hit/VFX anchor, collision, and ground pivot are explicit.
- Four-direction sets may be certified only for a camera range where snapping
  remains acceptable.
- Moorling Kit60 plus Kit70/71 remains `PARTIAL`: it has four directional
  identity sprites and generic action cels but no authored movement cycle.

## Pets and partners

- Pets use the monster/companion directional contract and explicit follow,
  combat, and ground pivots.
- Partners use character-grade directions and may later use the equipment
  contract.
- Both are independent spatial entities whose camera-relative direction is
  derived locally.

## Fairies

Representation may be billboard, shallow geometry, particles, or a hybrid.

- Declare character/partner attachment or independent follow anchor.
- Elemental/VFX art must remain readable against varied ground and camera yaw.
- Particle count, transparent overdraw, and texture memory require mobile
  budgets.
- Camera state is never authoritative fairy state.

## Buildings

Preferred representation: `SPATIAL_GEOMETRY` or authored `SHALLOW_25D`.

- All sides visible within the certified yaw range are intentionally authored.
- Roof silhouette, eaves, facade, and depth must remain coherent.
- Door/interaction anchor, footprint, collision, and navigation blockers share
  one local origin.
- Roof/canopy is a separate fadeable group where it can cover gameplay.
- Baked single-angle facade art cannot be stretched across side/rear faces.
- Required captures: left limit, center, right limit, and player scale.
- Full rotation requires a complete turntable and coherent rear treatment.

## Trees

Large trees should use spatial trunks with stylized canopy geometry or
purpose-authored clustered cards.

- Avoid duplicating a complete painted tree on perpendicular cross-planes.
- Trunk collision is conservative and independent of canopy silhouette.
- Canopy fade group and line-of-sight behavior are explicit.
- Required captures: left, center, right, and player occlusion.
- LOD should reduce canopy clusters before falling back to an impostor.

## Vegetation

- Small silhouette-neutral plants may billboard.
- Medium plants use clustered cards or shallow geometry.
- World-facing plants, hedges, and rows require explicit orientation.
- Ground pivot, wind behavior, shadow policy, and overdraw budget are required.
- Decoration cannot obstruct traversal or interaction pockets.

## Props

- Collision-critical props use spatial geometry or authored shallow volume.
- Decorative billboards are allowed only when camera-facing behavior is not
  semantically wrong.
- Declare footprint, interaction socket, orientation, and supported yaw.
- Landmark props require multi-angle readability and stronger silhouette
  review.

## Ground and roads

- Ground is spatial geometry with seamless materials and explicit world units.
- Roads share the ground plane but require edge/transition treatment that
  survives the certified yaw range.
- Avoid visible rectangular overlays and texture scale discontinuities.
- Collision/navigation derives from world data, not painted pixels.
- Landscape and portrait use identical geometry and coordinates.

## VFX

- World effects declare origin, facing behavior, size in world units, depth
  interaction, and whether they billboard.
- Combat VFX must preserve self, target, attack direction, and danger.
- Screen-space reward/UI feedback complements but cannot replace world VFX.
- Particle count, blend mode, overdraw, and lifetime require mobile budgets.

## Turntable validation

Certification captures must:

1. Use the real Godot runtime and target camera profile.
2. Include player scale where relevant.
3. Show left limit, center, and right limit; wide/full states add intermediate
   and rear views.
4. Exercise occlusion, collision, and interaction anchors where applicable.
5. Be inspected against BRAMBLE Visual Masters.
6. Record failures honestly as `PARTIAL` or `FAIL`.

Code completion and catalog labels do not override visual evidence.
