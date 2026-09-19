# BRAMBLE Animation Bible

Status: launch production contract  
Applies to: player, classes, Mantles/SPs, NPCs, monsters, bosses, companions, equipment, projectiles, and world VFX

## Runtime model

Gameplay owns state, world facing, movement, authoritative timing, hit resolution, and replicated events. The presenter consumes state plus normalized state time `[0,1]`, resolves camera-relative art locally, and drives body, equipment, shadow, and VFX. Camera yaw, chosen sprite direction, interpolation, procedural offsets, and presentation clocks are never saved or replicated.

All clips declare:

- stable clip/state ID, entity quality tier, direction mode, authored bearings, and fallback;
- source frames/keyposes, nominal FPS, duration, loop mode, and transition policy;
- normalized markers and gameplay-event bindings;
- invariant pivot, sockets, layer/depth changes, body-hide mask, and equipment compatibility;
- allowed procedural profile, VFX/audio bindings, mobile fallback, and provenance.

Normalized markers are authoritative semantic positions; frame indexes are derived. Marker ordering must survive a lower-mobile frame-rate/atlas variant. Gameplay does not infer events by checking a displayed frame.

## Timing and cadence

- Simulation and network timing remain independent of rendered FPS.
- Authored 2D cadence defaults: idle 6–8 fps, walk 8–10 fps, run 10–12 fps, routine action 10–14 fps, signature/player/boss action 12–16 fps, VFX 12–24 fps.
- Frame holds may vary to emphasize anticipation/contact. Duplicate raster frames used only as holds are timing data and do not count as new authored outputs.
- One-shot duration targets: routine attack `0.45–0.80 s`; heavy attack `0.80–1.35 s`; cast `0.60–1.50 s`; routine hit `0.20–0.45 s`; heavy hit/stagger `0.45–0.90 s`; ordinary defeat `0.75–1.50 s`; boss defeat `1.50–4.00 s`.
- Locomotion speed is gameplay-owned. Visual cycle rate may track speed inside a declared range but cannot alter displacement.
- A one-shot reaches exactly normalized 1.0 before completion. Loops wrap `[loop_start,loop_end)` without firing one-shot markers repeatedly unless marked `each_loop`.

## Universal normalized markers

Every clip includes `enter=0.00` and `complete=1.00`. Use only applicable markers:

- Locomotion: `contact_l=0.00`, `pass_l=0.25`, `contact_r=0.50`, `pass_r=0.75`.
- Attack: `anticipation_start=0.00`, `telegraph_on=0.05`, `aim_lock=0.25`, `commit=0.32`, `hit_active_start=0.42`, `impact=0.50`, `hit_active_end=0.56`, `followthrough=0.62`, `recovery_start=0.72`, `cancel_safe=0.86`, `complete=1.00`.
- Cast: `gather=0.00`, `telegraph_on=0.08`, `aim_lock=0.30`, `channel_start=0.36`, `release=0.56`, `channel_end=0.64`, `recovery_start=0.70`, `cancel_safe=0.88`, `complete=1.00`.
- Hit: `reaction=0.00`, `flash_on=0.00`, `recoil_peak=0.32`, `flash_off=0.45`, `recovery_start=0.55`, `complete=1.00`.
- Defeat: `defeat_start=0.00`, `control_lost=0.00`, `ground_contact=0.58`, `loot_spawn=0.72`, `corpse_stable=0.86`, `complete=1.00`.

These are default semantic positions. An attack family may override numeric values in data to match gameplay, but it must retain names, monotonic ordering, and documented visual rationale. `impact` is audiovisual emphasis; damage authority uses `hit_active_*` or an explicit gameplay marker.

## State standards

### Idle

Loop target `1.5–3.0 s`; seamless position, pivot, socket, and lighting at wrap. Motion is restrained: body bob no more than 1.0% player height and scale squash no more than 0.8%. Optional idle variants enter only at a loop boundary and return to the same baseline sockets.

### Move

Walk/run loops are foot-contact driven. Planted foot stays within 3 px at master resolution during contact. Visual cadence scales within ±20% before switching walk/run. Start/stop poses are required for player, SP, partner, and bosses when direct loop entry produces skating; standard monsters may use bounded acceleration lean.

### Attack

Anticipation communicates direction and weight before hit activation. Commit cannot be canceled unless gameplay explicitly permits it. Weapon/body trajectory, telegraph, active window, impact VFX/audio, and recovery use the common markers. Equipment depth changes only on a named marker. Combo branches occur at explicit `combo_open`/`combo_close`, never inferred from normalized-time ranges hidden in code.

M04.31B remains an exact partial gap: Batch001 supplies cardinal Wayfarer body and armor `windup/commit` keyposes plus socket JSON. Existing ready, procedural travel, impact, follow-through, recovery, helmet, sword, slash VFX, and diagonal nearest-cardinal behavior remain reused and do not become new authored frames.

### Cast/channel

Gather establishes source; channel can loop only between declared `channel_start` and `channel_end`; release fires the gameplay spawn event once. Sustained effects receive authoritative continuation/cancel state and use a presentation loop without accumulating transform. Interrupt transitions immediately to `interrupt`, terminates attached VFX, and cannot emit `release`.

### Hit

Hit reaction begins on the replicated damage event. Hit-stop is presentation-only unless gameplay time explicitly owns it; default local visual hit-stop is `35–65 ms` for routine and `70–110 ms` for heavy impacts. Knockback displacement is gameplay-owned; presenter recoil is additive, bounded, and returns to zero.

### Defeat/death

Defeat is non-looping until `corpse_stable`; an optional corpse hold then loops/freeze-holds. Gameplay loss of control is immediate and does not wait for art. Loot, XP, and despawn fire from authoritative events; visual markers align feedback. Revive transitions from `downed/corpse_stable` through authored `revive/getup`, never reverse-plays death.

## Loops, transitions, and interruption

- Loop modes: `NONE`, `WHOLE`, `RANGE`, or `HOLD_LAST`.
- Crossfade is not assumed for raster sprites. Transition uses a shared keypose, a 1–2 frame blend derivative, or an intentional snap on an impact/teleport marker.
- Default priority: death/defeat > knockdown/stagger > hit > attack/cast > interact > move > idle. Gameplay may define super-armor exceptions.
- Direction changes preserve normalized time. A new directional frame must represent the same phase and compatible sockets.
- Equipment or SP swaps occur at `swap_safe`; absent that marker, use state completion or an authored transform effect. Mid-state swap retains normalized action time.
- Fallback transitions are explicit and logged. Missing art never silently returns to idle during an active gameplay window.

## Root motion and procedural motion

Root motion is visual only. The authoritative entity transform always comes from gameplay. Artist-provided root curves may drive a presentation offset for anticipation/follow-through, but:

- offset begins and ends at zero;
- maximum routine player/monster horizontal offset is `0.18` player heights; heavy/signature `0.30`; boss is attack-profile specific;
- vertical offset for grounded entities is at most `0.04` player heights except an authored jump;
- rotation is at most 8° routine, 14° heavy; squash/stretch is at most 3% routine, 6% stylized creature;
- ground pivot and gameplay collision do not move;
- interruption blends offset to zero within `0.08–0.16 s`;
- no cumulative transform drift is permitted.

Allowed augmentation includes bob, squash/stretch, anticipation, lunge, recoil, landing compression, small rotation, hit flash, knockback response, accessory secondary motion, and position arc. It cannot replace anatomy, weapon grip, directional overlap, signature acting, or authored danger telegraph.

## Weapon and equipment synchronization

All attached layers sample one state, facing, normalized time, pivot, scale, and root offset. Armor pose index equals body pose index. Headgear follows authored head socket. Main/offhand use pose/direction sockets and deterministic depth.

Weapons define:

- rest and active grips, optional auxiliary grip, local pivot, base rotation/scale;
- trajectory samples or authored frame sequence;
- `trail_on`, `hit_active_start`, `impact`, `trail_off`, and depth-switch markers;
- projectile/muzzle origin where applicable;
- low-mobile trail/VFX fallback.

No armor/headgear inherits weapon swing transforms. No per-layer animation clock or random depth is allowed. Missing alignment is `PARTIAL`, not repaired with arbitrary scale.

## VFX and gameplay events

Named presentation bindings include `telegraph_on/off`, `trail_on/off`, `cast_seed`, `projectile_spawn`, `impact`, `hit_confirm`, `status_apply/remove`, `loot_spawn`, `phase_enter`, and `despawn`. The authoritative event ID is deduplicated so rollback, reconnect, or late snapshots cannot replay one-shot rewards/damage.

VFX can prewarm visually only if it does not disclose hidden gameplay state. Telegraph starts from gameplay timing. Particle reduction may lower count, trails, distortion, and light, but cannot remove danger shape, impact position, element identity, or hit confirmation.

Audio timing uses the same markers. Camera shake and hit-stop are local accessibility-aware presentation outputs and never change authoritative state.

## Quality tiers

### Tier S — player, 8 SPs, signature partners, raid bosses

- Eight-direction idle/move target; actions use eight or evidence-approved cardinal keyposes with explicit fallback.
- Authored anatomy for signature attacks/casts, full equipment/socket/depth data, start/stop, strong hits, defeat/revive or phase transitions.
- 12–16 fps action cadence, bespoke VFX/audio markers, landscape/portrait and low/mid mobile validation.

### Tier A — class actions, 14 bosses, important monsters, 4 partners

- Four directions minimum; eight/custom where silhouette and targeting demand it.
- Authored locomotion and every gameplay-critical anticipation/contact; bespoke hit, defeat, telegraphs, and phase events.
- 10–16 fps actions and complete socket/depth metadata.

### Tier B — standard combat monsters and combat pets

- One/two/four adaptive identity directions under certified yaw.
- Readable move, attack, hit, defeated; generic action cels allowed when labeled; procedural locomotion allowed.
- 8–12 fps cadence, explicit target/hit/attack sockets, mobile fallback.

### Tier C — service/background NPCs, ambient entities

- One/two/four directions according to movement/camera needs.
- Idle and interaction; move only if mobile. Combat states only if gameplay uses them.
- 6–10 fps, minimal approved secondary motion, explicit ground/interaction/nameplate anchors.

Direction count never upgrades a tier by itself. Runtime evidence can require more bearings for any tier or approve fewer for a state.

## Nonhumanoid adaptations

- Quadruped: contact markers identify fore/hind pair phases; spine compression follows gait; attack origins are jaw/horn/paw specific.
- Serpentine: use head-leading spline/segment motion; ground contact becomes support span; do not squash the whole raster around a humanoid foot pivot.
- Flying: `hover_origin` replaces planted feet, while `ground` remains the projected shadow/target point. Wing loops and body action can use separate synchronized phase tracks.
- Multi-limbed/insect: declare limb contact groups; avoid mirror when leg order or markings differ.
- Amorphous: center/core and footprint are stable; squash may reach 8% only if silhouette language is intentional; attack still needs a readable directional origin.
- Stationary plant/turret: ground pivot fixed; `CUSTOM` attack bearings or geometry forward axis; turn/aim is separate from base idle.
- Huge boss/set piece: body parts may be synchronized presenters with one authoritative state/time and named local sockets. Telegraph and collision remain gameplay geometry.
- Fairy/orb: billboard hover loop with owner-independent world anchor, explicit orbit phase, core/hit center, and projected shadow if grounded readability needs it.

## Animation acceptance

Review contact sheets first, then runtime at center/left/right yaw, movement speeds, all transition/interrupt paths, landscape/portrait, far/near approved zoom, equipment loadouts, SP swap, network observer yaw differences, and low/mid mobile. Reject if marker order differs from gameplay, foot/root drifts, direction change changes phase, equipment detaches, depth pops without marker, VFX danger disagrees with collision, generic cels are counted as directional, fallback is silent, or reduced-mobile art removes essential combat information.
