# BRAMBLE M04.31B — Player + Equipment Action Convergence

Date: 2026-09-18  
Engine: Godot 4.7.2  
Status: **PARTIAL**  
Decision: **B — EXACT AUTHORED ART PACK REQUIRED**

## Repository

- Start HEAD / origin/main: `aadfdb522e0dd0ba860f4fa2def397bd0296c304`
- End implementation HEAD: `ae5a633cf3e768c82d6ee580af3d77a3a5847bac`
- Branch: `main`
- Push: PASS; `origin/main` contains the implementation and evidence report

## Existing action art found

- Kit88 provides four production male melee poses: ready, windup, swing,
  recovery. It is one front/side-ish unarmed view, not directional and not
  compatible with the Wayfarer armor silhouette.
- Kit91 provides the existing production slash sequence.
- Canonical eight-direction base poses, experimental Wayfarer armor/helmet
  atlases, and the canonical short sword remain the equipped visual source.

Kit88 is now consumed for `starter_clothes`; it cannot honestly solve equipped
front/side/rear attacks.

## Implementation

- Fixed cel playback caching so normalized-time frame changes update textures.
- Added equipment-state-specific body cel sequences; starter attacks use Kit88.
- Unified lunge/compression motion across body, armor, helmet, and weapon.
- Prevented armor and helmet from inheriting the weapon swing.
- Added reusable data-driven weapon trajectory offsets and direction signs.
- Added ready, anticipation, commit, impact, follow-through, recovery, cardinal
  view, context, landscape, and portrait capture evidence.
- Authority, SP body replacement, camera-local direction, and network payloads
  are unchanged.

## Equipment and visual result

- Helmet/armor remain attached through idle, move, and all attack phases.
- Weapon depth remains front for front/side and behind for rear directions.
- Anticipation, trajectory, impact and recovery are clearer at gameplay zoom.
- Starter clothes now have a genuinely authored four-pose melee action.
- Equipped Wayfarer attacks remain limited by the unchanged idle body/armor
  silhouette. More procedural lean would distort painted art rather than fix
  the missing arm/torso action.

## Exact minimum authored pack

### REQUIRED

Create **16 transparent PNG keyposes plus one socket JSON**:

1. Male base body: `windup` and `commit` for `front`, `right`, `back`, `left`
   (8 PNGs).
2. Wayfarer armor overlays matching those exact eight body poses (8 PNGs).
3. Socket metadata for the existing helmet and short sword (no new helmet or
   sword texture).

Paths:

- `characters/base/male/actions/melee/<direction>/<windup|commit>.png`
- `characters/equipment/armor/wayfarer/actions/melee/<direction>/<windup|commit>.png`
- `data/spatial/player_actions/wayfarer_melee_attack.json`

Art contract:

- Character/base: canonical male base used by the current Wayfarer profile.
- Equipment compatibility: current Wayfarer armor, helmet, canonical short
  sword; future body-replacement profiles may provide their own keyposes.
- Direction coverage: four cardinals only. Diagonals use nearest cardinal plus
  the existing restrained engine motion.
- Windup: planted wide stance, torso compressed opposite strike direction,
  both hands gathered near the rear shoulder.
- Commit: torso and lead leg drive toward target; hands cross forward with a
  clear short-sword line and unobstructed face silhouette.
- Arm/armor: sleeves, shoulders, chest and belt must match body limbs exactly;
  armor PNGs contain no body, helmet, weapon, shadow, or VFX.
- Socket JSON per direction/pose: hand attachment pixel `(x,y)`, sword angle,
  helmet anchor `(x,y)`, helmet angle, body/weapon depth, and ground pivot.
- Bounds: 512×512 RGBA, straight alpha, at least 24 px transparent silhouette
  padding.
- Ground pivot: identical `(256, 468)` in every body and armor frame.
- Runtime scale: authored for `pixel_size=0.0055`.
- Depth: front/right weapon crosses in front at commit; back weapon starts
  behind torso and may cross front only after impact; armor follows body;
  helmet stays above body.
- Mirroring: forbidden by default because handedness and armor asymmetry are
  gameplay-visible.
- Godot consumption: normalized time selects idle → windup → commit → held
  follow-through → idle recovery; body and armor use the same pose index;
  existing helmet and sword use socket metadata; existing slash remains VFX.

Ready, anticipation travel, impact, follow-through, recovery, shadow response,
diagonal interpolation, helmet rendering, sword rendering, and slash VFX are
**NOT REQUIRED as new art**.

### OPTIONAL QUALITY UPGRADE

- One `followthrough` body + armor overlay per cardinal direction.
- Explicit four diagonal keyposes only if later normal-zoom tests expose
  cardinal fallback snapping.

## Tests

- Project parse: PASS
- M04.31B scene/smoke: PASS (`nodes=104`)
- Player movement/facing/camera-relative resolution: PASS
- Equipment idle/move/attack synchronization: PASS
- Starter authored sequence playback: PASS
- Attack phases and combat hit feedback: PASS
- M04.31A world and Moorling combat sanity: PASS
- Asset catalog integrity: PASS with pre-existing review items
- Multiplayer E2E after shared presenter change: PASS
- Lints: PASS

## Screenshots and performance

- Fresh evidence: `artifacts/m04_31b/01_...png` through
  `artifacts/m04_31b/15_...png`.
- Final landscape: `14_final_action_landscape.png`
- Final portrait: `15_final_action_portrait.png`
- 101 nodes, 46 draw calls, 17 materials, 57 transparent instances,
  3 shadow casters, 4 animated entities: no count regression from M04.31A.

## M04.3 safety

Protected tracked files, 29 M04.3 captures, and untracked UID files remain
preserved and uncommitted. None were staged.
