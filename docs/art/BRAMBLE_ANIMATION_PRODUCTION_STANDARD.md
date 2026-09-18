# BRAMBLE Animation Production Standard

Status: M04.30 production contract

## Direction count follows gameplay evidence

Direction count is chosen per entity and per state. It is not a universal
content matrix.

- One direction: screen-facing effects, silhouette-neutral interactables, and
  entities that intentionally face the camera.
- Two directions: symmetric or side-on secondary actors where explicit mirror
  approval exists.
- Four directions: economical monsters/NPCs inside a certified limited camera
  range when runtime snapping remains unobtrusive.
- Eight directions: player, SP, signature partner, boss, or other prominent
  actors when turning quality and equipment alignment justify the cost.
- Custom: non-uniform authored bearings or spatial models with a documented
  resolver.

Adding directions is justified only when runtime yaw, action readability, or
silhouette continuity exposes a visible gap. Do not mass-generate speculative
frames to fill a matrix.

## Authored art versus engine motion

Authored frames are required when identity, anatomy, silhouette, contact,
weapon handling, spell language, or emotional acting changes materially.
Important attacks, casts, reactions, defeat poses, and player/SP signatures
normally require authored keyposes or cels.

Engine motion may augment authored art with restrained bob, anticipation,
lunge, recoil, squash/stretch, landing compression, knockback, hit flash,
small rotation, secondary accessory motion, position arcs, and tweened
recovery. It is appropriate when the painted silhouette remains intact and
stable ground contact is preserved.

Engine motion is not a substitute for a pose that needs different anatomy,
directional equipment overlap, or bespoke acting. If deformation makes the
painted character look like a rubber puppet, use authored art.

## State capability record

Every animation state records:

- authored directions and source paths
- cel sequence or keypose
- frames per second and loop policy
- nearest-direction fallback permission
- mirror permission and restrictions
- fallback state
- permitted procedural motion profile
- VFX and audio anchors
- ground pivot, hit anchor, and equipment sockets
- provenance and runtime classification

Generic cels remain generic. They must never be counted as directional cels.

## Quality tiers

### Standard monster or NPC

Use one to four authored directions where the certified camera range permits,
subtle procedural locomotion, and authored keyposes for gameplay-critical
actions. Idle, movement readability, attack, hit, and defeated behavior remain
mandatory even when some are engine-augmented.

### Important monster, pet, or partner

Use richer directional/state coverage, more cel frames, stronger bespoke
reactions, and explicit follow/combat pivots. Partners approach character-grade
coverage when equipment or class identity is visible.

### Player and SP

Use the highest authored direction and state quality. Body, armor, helmet,
weapon, offhand, cosmetics, and VFX synchronize direction, normalized time,
pivot, and depth. An SP is a replacement visual set with compatible sockets,
not a recolor.

### Signature boss

Prioritize authored anticipation, attack arcs, danger telegraph, hit response,
phase transitions, defeat, and camera-scale readability. Bespoke spatial
geometry or rigging is allowed when it better preserves the design.

## Moorling production contract

Canonical identity comes from Kit60. Kit70 continues idle/attack animation and
Kit71 continues hit/defeated animation. Kit21 is vegetation provenance and must
never be used as Moorling art.

For limited camera rotation, Kit60 cardinal direction art may use explicit
nearest-cardinal fallback. Kit70/71 generic action cels may be used for their
named actions with restrained motion/VFX augmentation. They do not provide
diagonal or direction-bound combat coverage. Additional authored art is
requested only after runtime evidence shows a visible failure.

## Equipment animation

Equipment follows the body presentation pivot and shares direction, state,
normalized animation time, scale, and attachment origin. Each direction/state
defines deterministic socket and depth data. Asymmetric layers default to no
mirroring. Attack poses must be judged at anticipation, contact, and recovery,
not from idle alignment alone.

## Art-gap classification

- `P0`: gameplay or identity is visibly broken without authored art.
- `P1`: major visual improvement needed for production quality.
- `P2`: polish that does not block the playable slice.
- `NOT REQUIRED`: the presenter/engine solution is visually sufficient in the
  supported context.

Every gap cites fresh runtime evidence, supported camera range, affected state,
and current fallback. Missing cells in an abstract matrix are not evidence.

## Provenance

Preserve the catalog distinction between `SOURCE_SHEET`, `EXTRACTED_ASSET`,
`DERIVED_ASSET`, `RUNTIME_ASSET`, `REFERENCE`, and `EXPERIMENTAL`.

- Source sheets establish provenance and are not runtime identity.
- Runtime identity requires semantic and visual verification.
- Every runtime frame maps to its canonical source record and hash.
- File or kit names never override visual/hash evidence.
- Different assets must not share misleading canonical names.
- Experimental/generated candidates remain experimental until explicitly
  reviewed and promoted.
- Run `py -3 tools/validate_asset_catalog.py` after catalog changes.

## Runtime acceptance

Capture landscape and portrait evidence for supported yaw bounds, idle,
movement, attack/cast as applicable, hit, defeated, equipment before/after,
occlusion, and gameplay scale. Inspect motion cadence, foot stability,
silhouette, facing continuity, equipment depth, VFX timing, and mobile
readability. Tests prove correctness; screenshots and play prove quality.
