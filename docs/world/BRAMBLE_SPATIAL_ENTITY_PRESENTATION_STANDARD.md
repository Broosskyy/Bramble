# BRAMBLE Spatial Entity Presentation Standard

Status: M04.30 production contract
Engine: Godot 4.7.2

## Authority boundary

An authoritative entity owns identity, world position, world facing, gameplay
state, combat state, equipment/state IDs, and normalized action time. A spatial
presenter consumes those values and may not rewrite them.

Camera yaw, pitch, zoom, selected sprite direction, billboard orientation,
procedural offsets, fades, and presentation-only timers are client-local. They
must not appear in movement intents, authoritative simulation, snapshots,
saves, replays, or persistence. Camera-relative input is converted to a world
movement vector before it reaches authority.

## Presenter contract

The presenter is a `Node3D` attached to, or following, the authoritative world
entity. It receives:

- entity and visual-profile IDs
- world transform and normalized horizontal facing
- animation state and normalized state time
- equipment, SP, cosmetic, and status IDs
- target, hit, reward, and VFX presentation events
- the observing client's camera yaw

It outputs only visual layers, contact shadow, secondary motion, VFX, and
feedback. Replacing a profile must not replace the authoritative entity.

## Camera-relative direction

Displayed direction is derived locally:

`relative_angle = world_facing_angle - local_camera_yaw`

The result is resolved against the directions authored for the active state,
not against a global eight-direction requirement. Direction changes should use
stable angular sectors; hysteresis is recommended when camera motion causes
visible boundary chatter.

## Adaptive direction capability

Profiles declare one mode:

- `ONE_DIRECTION`
- `TWO_DIRECTION`
- `FOUR_DIRECTION`
- `EIGHT_DIRECTION`
- `CAMERA_BILLBOARD`
- `CUSTOM`

Each state independently declares its authored directional textures, cel
sequence or keypose, frame timing, fallback state, nearest-direction policy,
mirror policy, procedural motion profile, and VFX augmentation.

The resolver first requests the active state and view direction. It then:

1. uses the exact authored direction when present;
2. uses the nearest authored direction only when explicitly allowed;
3. uses an explicitly named fallback state when configured;
4. uses a profile placeholder only in development and reports the gap.

It never invents art. A generic attack, hit, or defeated clip is a valid
generic action, not directional coverage.

## Mirror policy

Mirroring defaults to forbidden. A state may opt in only when the art director
has confirmed that silhouette, handedness, weapon, markings, lighting, and
accessories remain correct. The presenter records that a mirrored fallback was
used so validation can distinguish it from authored coverage.

## Procedural motion

Profiles may opt into restrained bob, squash/stretch, anticipation, lunge,
recoil, landing compression, knockback, hit flash, small rotation, position
arc, and recovery. Motion operates on a presentation pivot below equipment and
VFX layers so synchronized layers remain attached.

Procedural motion must:

- preserve the painted silhouette and stable foot contact;
- stay subordinate to authored poses;
- have bounded amplitude, duration, and recovery;
- stop or switch cleanly with state transitions;
- avoid cumulative transform drift;
- be disabled per state or profile when it harms the art.

It cannot be used to claim missing authored directional coverage.

## Equipment attachment and depth

The equipment rig contains body, armor/outfit, helmet/headgear, weapon,
offhand, cosmetic, and status layers. Every visible layer shares facing,
state, normalized state time, presentation pivot, scale, and ground origin.

Attachment records are keyed by direction and state. They define socket
offset, rotation, scale, render priority/depth, and optional authored frame.
Weapon depth changes are deterministic profile data; they are not random
offsets. Missing attachment data is reported and falls back only through an
explicit contract.

## SP compatibility

An SP swaps the active body/animation profile while entity ID, world transform,
facing, collision, authority, combat state, and normalized action time remain
unchanged. The SP profile declares compatible equipment sockets, hidden or
replaced layers, scale, and bespoke VFX. M04.30 does not implement the full SP
system.

## Companion compatibility

Pets and partners are independent authoritative spatial entities using the same
presenter contract. Partners may use character-grade equipment profiles.
Fairies may use billboard or VFX profiles attached to explicit spatial anchors.
No companion presentation may depend on serialized camera state.

## Multiplayer rules

- Replicate entity ID, world position, world facing, gameplay/combat state,
  equipment/state IDs, and authoritative timing where required.
- Derive view direction independently on every client.
- Keep presentation impulses local unless the underlying gameplay event is
  replicated.
- Convert camera-relative controls to world intent before sending.
- Test observers at different camera yaws against the same authoritative event.
- Reject camera keys in snapshot/save schema tests.

## Acceptance

A profile is production-ready only after runtime validation at supported yaw
bounds in landscape and portrait. Validate idle, movement, relevant actions,
equipment, target feedback, occlusion, minimum readable size, frame stability,
transparent overdraw, and asset provenance. Code coverage without visual
evidence is not production approval.
