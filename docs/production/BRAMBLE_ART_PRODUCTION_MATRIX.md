# BRAMBLE Art Production Matrix

Status: launch production contract  
Authority: M04.30 standards, `SpatialEntityPresenter`, M04.31A/B evidence, and the canonical asset catalog  
Scope lock: cap 60; 5 regions; 25 maps; 4 classes; 8 Mantles/SPs; 6 dungeons; 3 raids; 50 field enemies plus 14 bosses; 35 NPCs; 8 pets; 4 partners; 6 fairies; 3 PvP modes

## Non-negotiable architecture

Direction coverage is adaptive per entity and per state. The only valid modes are `ONE_DIRECTION`, `TWO_DIRECTION`, `FOUR_DIRECTION`, `EIGHT_DIRECTION`, `CAMERA_BILLBOARD`, and `CUSTOM`. World facing is authoritative; displayed facing is resolved locally from `world_facing_angle - camera_yaw`. Exact authored art wins, then an explicitly allowed nearest direction, then an explicitly named fallback state, then a development-only reported placeholder. Generic cels are generic actions and never directional coverage. Mirroring is forbidden unless a state records explicit approval.

Every runtime asset must map to a catalog record, immutable source, source hash, extraction recipe, author/reviewer, license/provenance, representation, rotation certification, scale profile, pivot, alpha mode, import preset, mobile tier, and validation evidence. Valid provenance classes are `SOURCE_SHEET`, `EXTRACTED_ASSET`, `DERIVED_ASSET`, `RUNTIME_ASSET`, `REFERENCE`, and `EXPERIMENTAL`. References and source sheets are not runtime art.

## Shared image and import contract

- Color: sRGB RGBA PNG, straight alpha. Masks/data: linear. No premultiplied-alpha fringe.
- Padding: at least 8 px for icons and UI slices, 16 px for world/VFX sprites, 24 px for animated characters and equipment. Padding is transparent and excluded from logical bounds.
- Pivot: explicit ground contact for grounded world art; explicit geometric/emit center for airborne effects; UI uses optical center or documented nine-slice margins.
- Canvas: keep every frame in a state/direction family on one canonical canvas with an invariant pivot. Tight crops are derivatives only and retain trim offsets.
- Import: lossless source; lossless or visually lossless runtime compression; mipmaps on world sprites whose screen size varies; no filter on pixel-locked masks; filtering follows the approved painterly preset; repeat only on seamless ground/path textures.
- Maximum texture: 4096×4096 desktop source atlas, 2048×2048 mobile runtime atlas. Split before downscaling if readability would be lost.
- Atlas population: maximum 64 cells or 75% occupied pixel area, whichever occurs first. Character/equipment action sheets: maximum 32 frames. VFX sheets: maximum 64 frames. Icon sheets: maximum 128 icons only when each icon is at most 128×128; otherwise 64. Mixed pivots, scales, alpha modes, categories, or import presets never share a sheet.
- Extraction: preserve source unchanged; write source rectangle, canvas, pivot, trim offset, hash, output hash, and extractor version. Reject overlaps, clipped alpha, duplicate semantic names, inconsistent frame extents, and unreviewed blank cells.
- Naming: lowercase snake case. Runtime path pattern is `<category>/<identity>/<state>/<direction>/<identity>_<state>_<direction>_<frame:02>.png`; omit inapplicable segments. Stable IDs never contain kit numbers.
- Catalog state: `MISSING`, `SOURCE_ONLY`, `EXTRACTED`, `PARTIAL`, `RUNTIME_READY`, `CERTIFIED`. Only the last two may ship, and `CERTIFIED` additionally has runtime captures at supported yaw bounds.

## Category authoring standards

### Player base

- Representation/source/runtime: `DIRECTIONAL_SPRITE`; layered canonical body exports; camera-facing `Sprite3D` under the spatial presenter.
- Camera/facing: target `EIGHT_DIRECTION`; each state may declare less only as a recorded gap. Eight order is `front, front_right, right, back_right, back, back_left, left, front_left`.
- Scale/canvas/pivot: scale reference 1.00; use the Scale Bible. Shared body canvas, ground pivot, contact line, and logical bounds across sex/body options.
- States/poses: idle, walk, run, basic attacks, class attacks, cast/channel, hit, knockdown/get-up where used, defeated/death, interact, emote. Gameplay-critical anatomy changes are authored.
- Layers/sockets: body below outfit/armor; headgear, main hand, offhand, back, cast origin, foot, center, hit, nameplate, shadow, status, and VFX anchors are metadata.
- Mirror/shadow/VFX: no mirroring for launch bodies; one contact shadow; VFX separate from body PNG.
- Mobile: body plus visible equipment targets no more than 6 transparent layers and 2 atlas materials at normal gameplay zoom.

### Classes

- Four classes are gameplay/animation profiles, not duplicate bodies. Each supplies weapon stance, attack and cast pose families, class VFX language, socket overrides, and equipment compatibility.
- Baseline output per class is authored keyposes for every launch skill family that changes anatomy or weapon handling. Reuse is allowed only when marker timing, silhouette, grip, and class identity remain correct.
- Class identity cannot be baked into the base body unless the frame is cataloged as a class-specific body replacement.

### Mantles / SPs

- Eight launch Mantles/SPs are complete visual body replacements, never recolors.
- Representation is normally `EIGHT_DIRECTION DIRECTIONAL_SPRITE`; `CUSTOM` or spatial geometry requires turntable evidence.
- Preserve entity ID, authority, collision contract, state, facing, and normalized action time during swap.
- Each SP declares body-hide rules, compatible/hidden/replaced equipment layers, all sockets, footprint, scale, skill VFX, shadow, and transition effect.
- Minimum states: idle, move, signature attack, signature cast, hit, defeated, transform-in/out. Every signature state needs authored anatomy.

### NPCs

- Thirty-five launch NPC identities. Stationary background NPCs may use `ONE_DIRECTION`/`TWO_DIRECTION`; turning interactables use four or eight; mobile/story NPCs use four minimum, eight for close-up prominence.
- Mandatory idle and interaction pose; movement only for mobile NPCs; combat states only when gameplay uses them.
- Metadata includes interaction, quest indicator, nameplate, look-at, hand/prop, hit, ground, and shadow anchors. Interaction range/collision never derives from pixels.
- Portraits are separately authored or approved crops; world sprites are not enlarged into dialogue portraits.

### Field monsters

- Fifty launch enemies, assigned standard or important tier by encounter prominence.
- Standard: one to four authored identity directions under certified yaw; authored or approved generic attack/hit/defeated cels; procedural locomotion permitted with honest `PARTIAL` state.
- Important/elite: four minimum, eight when silhouette or attacks fail at yaw bounds; authored locomotion, anticipation, contact, hit, and defeat.
- Required metadata: target-ring radius, footprint, collision profile, ground pivot, center/hit/status/VFX sockets, attack origins, telegraph extent, and loot origin.
- Moorling remains exactly Kit60 cardinal identity plus Kit70/71 generic action cels; no Kit21, diagonal claim, or silent mirror.

### Bosses

- Fourteen launch bosses, including dungeon/raid bosses. Use `EIGHT_DIRECTION`, `CUSTOM`, or spatial geometry according to silhouette evidence.
- Authored phase idles/transitions, locomotion, every attack anticipation/contact/recovery, cast/channel/interrupt, hit or armor response, stagger where used, defeat, and enrage.
- Telegraph art is authored to gameplay geometry and must remain readable below the boss, at camera bounds, and in portrait.
- Boss texture/material/VFX budgets are declared per encounter and validated with full add waves; “hero asset” does not waive mobile limits.

### Pets, partners, fairies

- Eight pets: independent entities; four directions for grounded pets unless evidence supports two; idle, follow/move, celebrate, hit/defeat if targetable, and attack if combat-capable.
- Four partners: character-grade, normally eight directions; idle, move, attacks/casts, hit, defeated/revive; equipment contract when visible.
- Six fairies: `CAMERA_BILLBOARD`, `CUSTOM`, shallow geometry, particles, or hybrid. Declare follow/orbit anchor, emit center, element, trail, occlusion, overdraw, and fallback static sprite.
- Companion camera state is never serialized. Follow offsets and collision belong to gameplay data, not the image.

### Equipment

- Independent body-synchronized layers: outfit/armor, headgear, main hand, offhand, back, cosmetic, and status.
- Every visible layer records direction, state/pose index, pixel or normalized socket, rotation, scale, render priority/depth, body-hide mask, and fallback.
- Armor overlays use the exact body canvas and pivot and contain no body, helmet, weapon, shadow, or VFX. Weapons use their own logical pivot but attach to hand sockets.
- Idle and movement are mandatory. Combat weapons require anticipation/contact/recovery alignment; caster implements require cast/channel alignment. Asymmetric items are not mirrored.
- M04.31B's Wayfarer attack pack is an exact exception family governed below; it is not a universal canvas rule.

### Environment: buildings, dungeons, ground, paths, props, vegetation

- Buildings/landmarks: `SPATIAL_GEOMETRY` or authored `SHALLOW_25D`; intentionally author every side visible inside certified yaw. Record footprint, door/interaction sockets, collision, navigation blockers, roof/canopy fade group, shadow and LOD. Fixed facades may not be stretched over sides.
- Dungeons/raids: modular floors/walls/doors/occluders share world-unit grid, material set, seam guards, collision edges, navigation boundaries, and encounter sockets. Six dungeons and three raids each require a distinct landmark and readability palette.
- Ground/path: seamless spatial ground in world units. Ground, road, water, transition, decal, and obstruction layers remain separate. Path modules include straight, bend, junction, endpoint, shoulder, and biome transition. No rectangular overlay edges or scale discontinuity.
- Props: spatial or shallow volume if collision/semantic orientation matters; billboard only if camera-facing behavior is visually neutral. Record footprint, orientation, interaction and VFX sockets.
- Vegetation: small neutral plants may billboard; medium plants use clustered cards/shallow geometry; large trees use spatial trunks plus canopy clusters. Record ground pivot, trunk collision, wind group, canopy fade, LOD, shadow and overdraw.
- World sheets: one biome/material family per atlas, maximum 64 modules. Repeat tiles include 4 px internal bleed in the authored source and a verified seamless opposite edge; extraction must not bake neighboring tiles.

### Projectiles and VFX

- Projectile representation is geometry, directional sprite, or billboard according to travel silhouette. Declare gameplay origin, visual origin, forward axis, speed-independent trail, impact center, collision relation, world size, and despawn.
- VFX declares world/screen space, origin socket, facing mode, blend mode, color space, frame rate, lifetime, loop, depth/occlusion, light use, particle cap, overdraw area, and low-mobile fallback.
- Telegraph, release, contact, damage, and lingering area are separate semantic events even if they share textures. VFX cannot conceal an unreadable attack pose.
- A sheet uses equal cells and one pivot convention; maximum 64 frames, 2048 mobile dimension, and 50% transparent-area target. Long effects split into anticipation/impact/loop atlases.

### Icons, portraits, and UI

- Icons: authored masters at 256×256; ship 128×128 and 64×64 derivatives where required. Safe silhouette inside the central 80%; 8 px minimum runtime padding; no text baked into gameplay icons. Variants use one semantic ID plus state suffix.
- Portraits: 1024×1024 master, 512×512 runtime; head/shoulder safe area is central 70%, eyes in the upper 45–55% band, 10% edge safety. NPC/player/SP portraits record identity, expression, outfit, and crop; do not infer equipment state unless the portrait is explicitly dynamic.
- UI: design on 4 px grid; components use nine-slice/vector where suitable; state set is normal, hover/focus where applicable, pressed, disabled, selected, alert. Respect device safe area, localization expansion of 35%, minimum 44×44 dp touch target, contrast/readability, and landscape/portrait anchors.
- UI atlases group one density and theme only. Maximum 64 large components or 128 icons. Nine-slice margins and optical bounds are metadata; sheets are never used directly as modal overlays.

## Authoritative adaptive animation matrix

The entries below are launch targets, not claims that current assets already meet them.

- Player: idle/move `EIGHT_DIRECTION`; basic attack/cast `EIGHT_DIRECTION` or four authored cardinals with explicit nearest-cardinal fallback only after normal-zoom acceptance; hit/defeated four or eight; signature class actions eight when equipment overlap changes.
- SP: idle/move/signature attack/signature cast `EIGHT_DIRECTION`; hit/defeated four minimum; transform may be generic `ONE_DIRECTION` only when it is camera-facing VFX rather than body art.
- Partner: idle/move/combat eight; generic hit/defeated four minimum.
- Boss: idle/move four, eight, or `CUSTOM`; every attack uses the bearings demanded by its targeting geometry; phase transition may be generic; no automatic mirror.
- Important monster/pet: idle/move four minimum; action directions follow evidence; generic hit/defeat allowed only when silhouette remains truthful.
- Standard field monster: idle/move one, two, or four; attack/hit/defeated may be generic. Certification must state supported yaw and fallback.
- NPC: stationary one/two; turning four/eight; mobile four minimum; interaction may be generic.
- Fairy/VFX/projectile: billboard/one/custom according to forward-axis needs.

## Actual authored output counting rules

Count deliverables, not matrix cells:

1. One unique PNG file is one authored raster output. Reuse in multiple states/directions does not multiply the count.
2. One atlas containing N genuinely distinct approved cells counts as N authored outputs plus one packing artifact; blank, duplicate, mirrored, recolored, or padding cells count as zero new authored outputs.
3. One layered body pose and one armor overlay are two outputs. Socket JSON, extraction manifest, atlas, portrait crop, and each resolution derivative are production deliverables but not authored-art outputs.
4. A generic action sequence of N cels counts as N generic outputs, never `N × directions`.
5. Explicit left/right mirrors count as one authored output plus one approved runtime transform and must be reported as mirrored coverage.
6. Procedural transforms, particles, shaders, engine tweens, tint variants, and material variants count as implementation/configuration, not authored frames.
7. A source sheet is not counted as runtime output. Each verified extraction counts as an extracted output and retains the source rectangle/hash.
8. Directional coverage is counted per unique identity/state/direction file. Nearest-cardinal fallback adds zero coverage.
9. Catalog reports show three totals separately: authored raster/vector outputs, extracted/derived runtime files, and packed/import/configuration artifacts.
10. Production estimates must enumerate identities × required unique states × required unique directions × unique frames, then subtract only documented reuse. Never multiply generic clips or mirrored fallbacks.

## M04.31B exact open gap

Batch001 remains the M04.31B authored pack: exactly 16 transparent PNG keyposes plus one socket JSON. Male base body `windup` and `commit` for `front/right/back/left` are 8 PNGs; matching Wayfarer armor overlays are 8 PNGs; metadata is `data/spatial/player_actions/wayfarer_melee_attack.json`. Each is 512×512 RGBA straight alpha, at least 24 px padding, invariant pivot `(256,468)`, and authored for `pixel_size=0.0055`. The JSON records hand and helmet `(x,y)`, sword and helmet angle, body/weapon depth, and ground pivot per direction/pose. Existing helmet, sword, slash VFX, ready, travel, impact, follow-through, recovery, diagonal fallback, shadow response, and rendering are not new art. Mirroring is forbidden.

## Production acceptance

Every family passes source/hash and catalog validation, image technical review, scale/pivot/socket overlay review, animation marker review, supported-yaw runtime captures at center and limits, landscape/portrait gameplay-scale review, equipment/occlusion review where applicable, and low/mid mobile memory/overdraw/frame-time review. A passing parser, complete spreadsheet, or filename is not visual approval.
