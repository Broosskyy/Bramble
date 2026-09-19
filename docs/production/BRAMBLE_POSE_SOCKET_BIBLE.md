# BRAMBLE Pose, Socket, Layer, and Depth Bible

Status: launch production contract  
Runtime authority: `SpatialEntityPresenter`

## Coordinate and direction contract

Authoritative horizontal facing is normalized world `(x,z)`. Local display angle is:

`relative_angle = wrap(atan2(world_facing.x, world_facing.z) - camera_yaw, -180°, +180°)`

Zero degrees faces the camera-visible `front` bearing in the current presenter convention; positive angles advance toward screen/right-facing bearings. Angles exactly on a boundary resolve by nearest-sector rounding in the runtime. Art review must avoid holding a character on boundaries; runtime profiles should add 4° hysteresis without changing sector centers.

Eight-direction sectors:

- `front`: center 0°; `[-22.5°, +22.5°)`.
- `front_right`: center +45°; `[+22.5°, +67.5°)`.
- `right`: center +90°; `[+67.5°, +112.5°)`.
- `back_right`: center +135°; `[+112.5°, +157.5°)`.
- `back`: center ±180°; `[+157.5°, +180°]` and `[-180°, -157.5°)`.
- `back_left`: center -135°; `[-157.5°, -112.5°)`.
- `left`: center -90°; `[-112.5°, -67.5°)`.
- `front_left`: center -45°; `[-67.5°, -22.5°)`.

Four-direction projection uses those same sectors and maps `front_right/front_left → front`, `back_right/back_left → back`; `right` and `left` remain themselves. Effective cardinal regions are front `[-67.5°, +67.5°)`, right `[+67.5°, +112.5°)`, back `[+112.5°,180°] ∪ [-180°,-112.5°)`, and left `[-112.5°,-67.5°)`.

The current two-direction resolver is a three-label projection: indices `front_right/right/back_right → right`, `back_left/left/front_left → left`, while exact `front` and exact `back` resolve to `front`. A two-direction profile must therefore provide `front`, `left`, and `right` or an explicit fallback. It must not be described as a conventional left/right-only resolver until runtime behavior changes.

`ONE_DIRECTION` and `CAMERA_BILLBOARD` resolve `front`. `CUSTOM` divides 360° evenly by the declared ordered bearing list in the current runtime; an empty set guards to `front`. If non-uniform sectors are needed, metadata must provide explicit centers/boundaries and runtime support before certification.

## Pose vocabulary

Pose IDs are lowercase and semantic. A frame may be reused, but its marker and socket record remains state-specific.

- Locomotion: `idle`, `idle_alt`, `walk_contact_l`, `walk_pass_l`, `walk_contact_r`, `walk_pass_r`, `run_contact_l`, `run_air_l`, `run_contact_r`, `run_air_r`, `turn`, `start`, `stop`.
- Melee: `ready`, `windup`, `commit`, `contact`, `followthrough`, `recovery`.
- Ranged: `ready`, `draw`, `aim`, `release`, `recoil`, `recovery`, `reload`.
- Magic: `ready`, `gather`, `channel`, `release`, `sustain`, `recovery`, `interrupt`.
- Reaction: `hit_light`, `hit_heavy`, `stagger`, `knockdown`, `downed`, `getup`, `defeated`, `death`, `revive`.
- Interaction/social: `interact`, `use`, `pickup`, `talk`, `greet`, `celebrate`, `emote_<id>`.
- Boss: `phase_enter`, `phase_loop`, `enrage`, plus attack-family semantic names with the standard phases.

`attack_01` is allowed only as a stable attack-family ID, never as a pose-phase name. `death` is final/nonrecoverable; `defeated` is gameplay incapacity and may transition to revive/despawn.

## Canonical sockets

Socket values are authored per direction and pose. Pixel coordinates use top-left canvas origin, +x right, +y down. Runtime local world offsets use +x right, +y up, and presentation depth z; converters must record the transform.

Required humanoid sockets:

- `ground`: invariant body ground pivot.
- `contact_l`, `contact_r`: sole contacts used for foot-lock review.
- `center`: stable torso/visual center.
- `head`: headgear root; `face` and `mouth` when used.
- `hand_l`, `hand_r`: grip roots; `hand_l_aux`, `hand_r_aux` for two-hand orientation.
- `weapon_main`, `weapon_tip`, `weapon_trail`; `weapon_off`, `shield_center`.
- `back`, `waist`, `chest`, `shoulder_l`, `shoulder_r`.
- `cast_origin`, `projectile_origin`, `interact`, `nameplate`, `quest`, `status`, `hit`, `shadow`, and `loot`.

Required creature additions as applicable: `jaw`, `horn`, `claw_l/r`, `tail_base`, `tail_tip`, `wing_l/r`, `muzzle`, `core`, `telegraph_center`, and named attack origins. Nonexistent anatomy sockets are omitted, not placed at `(0,0)`.

Each socket record contains `(x,y)`, rotation degrees, optional local scale, depth band, enabled flag, and confidence `AUTHORED`, `DERIVED`, or `FALLBACK`. A missing required socket is a reported art/metadata gap.

## Layer and depth contract

Back-to-front semantic bands are:

1. `ground_decal` and telegraph below-character components.
2. `shadow`.
3. `back_fx` and behind-body weapon/cosmetic.
4. `body_back` appendages.
5. `body`.
6. `outfit_armor`.
7. `body_front` appendages.
8. `headgear`.
9. `front_weapon_offhand`.
10. `front_fx`, status, selection, and hit feedback.
11. World-space nameplate/quest marker where used; HUD remains screen-space.

Numeric render priorities are profile data and may differ, but ordering must preserve these semantics. Direction/pose can move a weapon or appendage between behind/front bands. A depth change happens only at a normalized marker and is deterministic. Tiny z offsets are not a substitute for render priority.

Body, armor, headgear, weapon, offhand, cosmetic, and attached VFX share facing, state, normalized time, presentation pivot, scale, and ground origin. Procedural motion is applied to their common parent. No attached layer runs an unsynchronized private attack clock.

## Body-hide and SP rules

Body-hide masks are semantic regions: `hair`, `head`, `face`, `neck`, `torso`, `arm_l`, `arm_r`, `hand_l`, `hand_r`, `hips`, `leg_l`, `leg_r`, `foot_l`, `foot_r`, `back`, `tail`, and `wings`. Equipment declares only regions it fully replaces. Alpha holes are not inferred automatically.

An SP swaps the active body/animation profile while preserving authoritative entity ID, transform, facing, collision contract, combat state, and normalized action time. Its profile declares:

- replaced and retained body regions;
- allowed, hidden, remapped, or replaced equipment slots;
- complete socket remap and scale ratio;
- depth bands, shadow/footprint, hit/target/nameplate anchors;
- transform-in/out and bespoke VFX;
- explicit fallback if the swap occurs during an unsupported state.

SPs do not inherit humanoid sockets by coordinate coincidence. Incompatible equipment is hidden with a recorded rule, never left floating.

## Equipment melee visual standard

- `ready`: stable grip and readable weapon silhouette.
- `windup`: center of mass shifts opposite attack; grip, shoulders, sleeves, and armor agree.
- `commit`: lead limb/torso drives toward target; weapon trajectory clears face and body.
- `contact`: weapon tip/trail intersects the gameplay contact line at `hit_active`; depth crossing has already occurred or is marked here.
- `followthrough`: momentum remains readable without changing gameplay reach.
- `recovery`: returns to exact stance/socket baseline without drift or snap.

Two-hand weapons use both hand sockets and derive angle from grip-to-aux vector. One-hand weapons attach to the active hand and can use an authored angle. Shields preserve defense-facing depth. Weapon scale cannot animate merely to fake reach.

For the M04.31B Wayfarer melee family only, body and armor use 512×512, pivot `(256,468)`, and cardinal `windup/commit`; JSON supplies hand/helmet anchors, angles, body/weapon depth, and ground pivot. Front/right commit crosses in front; back starts behind and may cross only after impact. Existing diagonals use nearest cardinal plus restrained engine motion. No mirroring.

## Cast visual standard

- `gather`: hands/implement move to cast sockets; effect seed appears at `cast_origin`.
- `channel`: pose and loop are stable; hands, implement, and persistent VFX share one anchor with bounded secondary motion.
- `release`: projectile/area effect spawns at `release`; recoil begins after spawn.
- `sustain`: body loop cannot move the gameplay origin; beam endpoints follow gameplay target data.
- `interrupt`: effect terminates at the authoritative interrupt event and uses an authored or approved reaction.
- `recovery`: sockets return to idle/ready before locomotion blend completes.

Muzzle, hand, staff tip, mouth, ground rune, and target origins are distinct. VFX cannot be baked into equipment PNGs.

## Hit, defeat, follower, and boss standards

Hit:

- `hit` socket is near the mass center but attack-specific weak points are named separately.
- Routine hit keeps ground contact unless gameplay applies knockback. Flash, recoil, damage text, and sound all use the same replicated hit event.
- Directional hit art is required when anatomy/depth materially changes; otherwise an approved generic clip is honest generic coverage.

Defeat:

- Defeat keeps the invariant ground pivot and transitions silhouette toward the ground without clipping.
- Shadow compresses/fades from the same normalized state time. Loot spawns from `loot`, not image center.
- Corpse/debris depth is deterministic. Despawn VFX cannot hide an incomplete frame before the gameplay defeat marker.

Followers:

- Pets/partners are independent entities. `follow_anchor` belongs to the owner profile; follower `ground`, `center`, `look`, and `teleport_fx` belong to the follower.
- Follow pose faces world movement, not camera. Idle/follow/teleport transitions preserve ground contact.
- Fairies may orbit an explicit owner anchor but remain camera-local in presentation only; authority never serializes camera yaw.

Boss telegraphs:

- `telegraph_center` and each attack origin are explicit and mapped to gameplay shapes: circle radius, cone angle/range, line width/range, ring inner/outer radius, or polygon.
- Telegraph lies below actors but above ground decoration and is never hidden by boss body, shadows, or foliage.
- Anticipation silhouette, telegraph onset, lock, active damage, and fade use normalized markers. Visual bounds may feather outside gameplay bounds by no more than the Scale Bible allowance.
- Phase and raid effects define low-mobile fallback and preserve danger color/shape when particles are reduced.

## Pose/socket acceptance

Overlay body, armor, headgear, both hands, weapon trajectory, cast origin, ground contacts, shadow, hit, target ring, and VFX at every authored pose/direction. Validate front, side, rear, yaw boundaries, landscape/portrait, normal/far zoom, and low/mid mobile. Fail on foot slide, floating equipment, hidden face without intent, grip separation over 3 px at master resolution, unmarked depth pop, clipped alpha, mirrored handedness, socket `(0,0)` fallback, or mismatch between telegraph and gameplay shape.
