# BRAMBLE Asset Scale Bible

Status: launch production contract  
Reference unit: an adult player at normal gameplay scale equals `1.00`

## Authority and conversion

This document defines visual ratios, not collision or balance. Gameplay collision, navigation, reach, and interaction ranges are authored independently. The runtime presenter applies one profile scale to body and synchronized equipment; artists do not compensate per frame or direction.

Canonical adult player visual height is `1.80 world units` from ground contact to top-of-head logical bound. Therefore:

`world_visual_height = scale_ratio × 1.80`

Texture import scale is derived from the approved logical pixel height:

`pixel_size = world_visual_height / logical_pixel_height`

Transparent padding is excluded from logical height. Existing certified assets may retain their cataloged pixel size. A new ratio never silently overrides M04.30 evidence (`wayfarer 0.0055`, Moorling `0.0058`) or the M04.26 experimental records; migration requires side-by-side runtime approval.

## Canonical player canvas

- General player, class, equipment, partner, and humanoid SP production family: 512×512 RGBA master canvas.
- General ground pivot: `(256, 464)`. Contact line is y=464. The pivot is the midpoint between planted foot contacts, not canvas center.
- Logical standing center: `(256, 278)`. Nominal logical body bounds: x=104..408, y=56..464.
- Ground-safe band: y=448..472. No opaque body/equipment pixels below y=472 except explicitly approved trailing cloth; shadow is never baked into a body frame.
- Head-safe area: x=144..368, y=40..176. Hands/weapons may leave body bounds but remain inside x=24..488 and y=24..488.
- Animation motion safe area: 24 px on every edge. No family frame may clip alpha at that boundary.
- Equipment alignment area: armor shares the complete canvas and pivot; helmet uses the same canvas or an exact trim offset; held equipment can use a separate canvas only with a declared local pivot/socket.
- Logical bounds, contact line, and pivot are invariant across direction and frames. Airborne frames retain the ground pivot and encode visual displacement relative to it.

The preceding canvas is the general launch standard. The only locked exception is the M04.31B Wayfarer melee attack family: its 16 body/armor PNGs remain exactly 512×512 with pivot `(256,468)`, at least 24 px transparent padding, and `pixel_size=0.0055`. Do not normalize those files to y=464 and do not propagate y=468 to unrelated player families.

## Ratio ranges

Select one identity ratio inside its category and lock it in catalog metadata. Animation may change silhouette but not the identity ratio.

### Characters and companions

- Adult player body, all four classes: canonical `1.00`; permitted body-option range `0.94–1.06`.
- Mantle/SP humanoid: target `1.00`; permitted `0.90–1.18`.
- Mantle/SP large/nonhumanoid: `1.10–1.45`; anything larger requires boss-camera and collision review.
- Adult NPC: `0.90–1.05`; canonical service NPC `0.96`.
- Child/small folk NPC: `0.62–0.82`.
- Partner: `0.92–1.08`; signature large partner `1.09–1.20`.
- Ground pet small: `0.28–0.45`; medium `0.46–0.68`; large combat pet `0.69–0.90`.
- Fairy core silhouette: `0.14–0.26`; aura inclusive visual diameter `0.30–0.55`.

### Monsters

- Tiny ambient/weak enemy: `0.25–0.45`.
- Small field enemy: `0.46–0.72`.
- Standard field enemy: `0.73–1.10`.
- Large field enemy/elite: `1.11–1.55`.
- Miniboss: `1.40–2.10`.
- Field/dungeon boss: `1.80–3.20`.
- Raid boss normal gameplay silhouette: `2.50–5.00`; larger set pieces use encounter framing rather than increasing ordinary sprite scale.

Boss ratios describe readable visual height, not hitbox. Telegraph and target ring use gameplay geometry and remain visible outside the silhouette.

### Equipment

- Armor/outfit and helmet: exactly `1.00` relative to the active compatible body canvas/profile.
- Main-hand short/one-hand weapon length: `0.28–0.52` player heights.
- Two-hand weapon: `0.48–0.82`.
- Offhand/shield: `0.24–0.48`.
- Back item: `0.30–0.75`.
- Equipment VFX may reach `1.25` of weapon length during anticipation and `2.00` at impact; persistent idle VFX stays within `0.35` player heights from the body.

No equipment texture is scaled to repair a bad socket. Any state scale other than 1.00 is an explicit effect and must return to 1.00 without drift.

### World

- Door clear visual height: `1.25–1.55` player heights.
- One-storey building eave: `2.2–3.2`; ridge: `3.0–4.8`.
- Two-storey landmark ridge: `4.5–7.0`.
- Small prop: `0.10–0.45`; human-use prop: `0.46–1.10`; landmark prop: `1.11–3.00`.
- Shrub/flower mass: `0.18–0.65`.
- Young tree: `1.8–3.0`; standard tree: `3.0–5.5`; hero tree: `5.5–8.0`.
- Grass/ground-cover height: `0.03–0.18`. It must not hide player contact.
- Fence/low blocker: `0.45–0.80`; full wall: `1.15–2.50`.
- Path readable width: solo `1.8–2.5` player widths; social/town `3.0–5.0`; combat route opening at least `4.0`.
- Dungeon corridor visible width: `3.0–5.0`; boss arena clear diameter: boss telegraph diameter plus `4.0` player heights of escape margin.

Ground and paths are measured in world units. Texture density is fixed per material family; world geometry is never resized to hide texture seams.

### Projectiles and effects

- Arrow/bolt readable length: `0.16–0.34` player heights.
- Orb/projectile diameter: `0.10–0.30`; boss projectile `0.20–0.55`.
- Routine melee impact diameter: `0.35–0.75`.
- Player skill impact: `0.60–1.40`.
- Boss impact/telegraph: gameplay radius plus only `0.10` player heights of visual feather.
- Status effect icon above entity: `0.10–0.16`; world pickup: `0.14–0.28`.
- Contact shadow: player ellipse width `0.42–0.58`, depth `0.14–0.24`; derive other entities from footprint, capped inside collision footprint unless flight is intentional.

VFX scale is authored in world units and cannot vary with camera zoom to imply a different danger radius. Screen-space minimum-readability fallback may alter opacity/detail, never gameplay extent.

## Texture density and canvas families

- Player/humanoid animated master: 512×512 per frame.
- Small companion/standard monster: 256×256 or 384×384 when logical height remains at least 128 px.
- Important monster/SP/partner: 512×512.
- Boss: 512×512 or 1024×1024 frame; split attachments/VFX before exceeding 2048 mobile atlas dimension.
- World prop/vegetation: choose 128, 256, 512, or 1024 square envelope; retain 24 px world-sprite padding.
- Building facade/shallow asset: up to 2048 in either mobile dimension; larger structures are modular.
- VFX: 256 or 512 cell; 1024 only for boss/set-piece effects after device evidence.
- Icons: 256 master, 128/64 runtime. Portraits: 1024 master, 512 runtime.

Changing canvas size does not change world scale. The import conversion uses logical height and catalog ratio.

## Pivot, center, bounds, and sockets

Every world-sprite record contains:

- `canvas_px`, `logical_bounds_px`, `opaque_bounds_px`, and `trim_offset_px`;
- `ground_pivot_px`, `contact_left_px`, `contact_right_px`, and `visual_center_px`;
- `world_height`, `scale_ratio`, `pixel_size`, footprint, and collision profile ID;
- direction/state-specific socket map and render-depth map;
- shadow center/size and target-ring center/radius;
- safe-area violation count, expected zero.

Grounded frames keep feet within 4 px of the contact line at planted markers. Idle drift is at most 2 px vertically. Walk/run planted foot drift is at most 3 px during its contact window. Large procedural squash cannot move the ground pivot.

Visual center is used for camera/nameplate/hit feedback only when the relevant explicit socket is absent; it is never a substitute for a hand, cast, mouth, muzzle, or impact socket.

## Screen readability and safe framing

At the farthest supported normal zoom:

- Player logical body height: minimum 72 physical pixels in landscape and 80 in portrait.
- Standard field enemy: minimum 52 px; small hostile minimum 40 px.
- NPC interaction silhouette: minimum 56 px.
- Fairy core or critical projectile: minimum 14 px.
- Item/skill icon: 44 dp touch target with at least 24 px meaningful glyph at 1×.
- Routine telegraph border: minimum 3 physical px; lethal/boss border minimum 5 px.

The player and current target must each retain at least 0.50 player heights of visible ground around contact during ordinary combat. UI safe areas come from device insets. World framing reserves an additional 24 dp from inset edges for critical targets and telegraphs. Landscape and portrait use identical world scale and geometry; only camera framing/zoom within the approved profile may differ.

## Scale validation gate

Validate a neutral lineup containing player, NPC, each monster tier, pet, partner, fairy, door, standard tree, human-use prop, projectile, impact, shadow, target ring, and one UI icon. Capture center/left/right yaw, nearest/farthest zoom, landscape/portrait, and low/mid mobile. Reject scale if contact is hidden, target/telegraph geometry disagrees, equipment drifts, alpha is clipped, an identity changes category between directions, or readability requires one-off runtime compensation.
