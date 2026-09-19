# BRAMBLE Mobile Product Standard

Status: **PRODUCTION AUTHORITY — SHIP GATE**  
Engine: **Godot 4.7.2**  
Applies to: Android and iOS gameplay, menus, dungeons, raids, PvP, account flows, and live operations  
Principle: mobile is the primary product, not a reduced desktop port.

## 1. Supported product modes

- World and simulation state are identical in landscape and portrait; only camera framing, zoom, anchors, density, and navigation presentation change.
- Landscape is the default recommendation for combat, dungeons, raids, and PvP. Portrait remains a supported gameplay mode, not a menu-only claim.
- Orientation changes never reload the map, drop target state, resend authority state, cancel a safe interaction, or move world entities.
- Camera yaw, pitch, zoom, selected sprite direction, occlusion fades, UI layout, and gesture state are client-local.
- Keyboard/controller support may exist, but no required launch action depends on hover, right-click, modifier keys, precision cursor, or hardware keyboard.

## 2. Touch combat and control budget

### Persistent gameplay budget

| Side / zone | Maximum persistent controls | Contents |
|---|---:|---|
| Left thumb | 1 cluster | analog movement joystick; optional tap-to-move mode is mutually exclusive |
| Right thumb | 7 direct actions | primary attack, 4 skills, defense/mobility, target |
| Bottom center | 1 contextual action | interact/hold, talk, gather, revive, enter; changes label/icon by valid context |
| Utility edge | 3 low-frequency actions | potion, Mantle, compact menu/map; never inside primary aim arc |

At most **12 persistent actionable targets** are visible during ordinary combat, including joystick and utility controls. Raid/PvP objective controls may replace a contextual or utility slot; they may not add a second overlapping action bar. Party commands, emotes, consumable wheels, and target lists open from one explicit control and close without covering movement.

### Input behavior

- Minimum touch target: **48×48 dp**; primary combat actions: **56×56 dp** preferred.
- Minimum target separation: **8 dp**; danger/destructive actions need **12 dp** or confirmation.
- Visual response begins on touch-down within one rendered frame; authoritative outcome waits for server validation.
- Input queue: one next basic/skill action, visibly cancelable where the combat design allows. No hidden multi-action queue.
- Sliding off an action cancels before release unless the skill is explicitly hold/aim.
- Hold thresholds: 350–500 ms; radial-menu activation at least 450 ms; all holds show progress.
- Multi-touch must sustain movement plus one right-thumb action plus camera gesture without reassignment.
- Target assist may select a valid nearby target; it cannot attack, navigate encounters, or progress unattended.
- Auto-pickup is allowed for eligible nearby loot. Autoplay, auto-quest combat, and unattended farming are prohibited.
- Haptics use light/medium/strong vocabulary for ready, hit/guard, danger/major reward and respect system settings; every haptic has visual/audio equivalents.

### Gesture ownership

1. System gesture exclusion is used sparingly and never traps navigation.
2. Active joystick/action touches own their contacts until release.
3. World taps select/interact only in unobstructed world space.
4. Camera drag/pinch uses designated safe world space after controls, target cards, chat, and notifications claim touches.
5. Two-finger camera gestures never trigger skills or interactions.

Remapping, left-handed mode, joystick position/size, button scale/opacity, hold/toggle options, and aim sensitivity are available before first combat and from pause/settings.

## 3. Layout, orientation, and safe areas

### Safe-area contract

- Query platform safe insets at runtime; never hardcode a notch model.
- All interactive controls remain inside safe bounds plus **8 dp** internal margin.
- Critical text/status remains inside safe bounds plus **12 dp**.
- Decorative backgrounds may bleed to the physical edge.
- System home/gesture regions cannot contain hold controls, paid/destructive confirms, or raid/PvP objective actions.
- Layout supports aspect ratios from **16:9 through 22:9 landscape** and **9:16 through 9:22 portrait**, plus cutouts, rounded corners, and transient system bars.
- At 200% UI scale, essential gameplay remains operable without overlapping movement, target, or danger information.

### Thumb reach

- Primary movement center sits within the lower-left reachable third; primary attack and defense sit within the lower-right reachable third.
- High-frequency control centers remain approximately **24–72 dp** from the safe bottom and **24–96 dp** from the safe side, adjustable by the player.
- Top corners are glance/status zones, not high-frequency combat zones.
- Bottom center is reserved for context and must not collide with the home indicator.
- Portrait uses vertical stacking and reduced nonessential HUD, not smaller touch targets.

### World visibility

- Player, target, attack direction, immediate danger, and route out of combat remain visible at all supported layouts.
- HUD/control occlusion targets: ordinary play **≤25%** of safe-screen area; raid/PvP peak **≤32%**.
- Controls may be translucent but retain a visible pressed/disabled/cooldown state over bright and dark terrain.
- Dialogue, loot, chat, and notifications do not cover the player’s feet or active danger zone.
- Orientation-specific camera anchor bias may reveal more space toward target/travel direction. It may not alter range, collision, spawns, or authority.

## 4. HUD information priority

Priority 0: platform/legal interruption, disconnect, destructive/paid confirmation.  
Priority 1: player HP/state, immediate lethal danger, target/boss cast, PvP objective.  
Priority 2: skill readiness/resources, party critical state, interaction/revive.  
Priority 3: quest direction, loot/reward, chat mention.  
Priority 4: optional meters, social activity, event promotion.

Lower priorities collapse before higher priorities shrink. Combat text is pooled, capped, and aggregated; it never becomes a wall of overlapping numbers.

## 5. Raid and PvP readability

### Shared rules

- Enemy danger uses shape, motion, position, and timing in addition to color.
- Ground telegraphs have a stable border, fill, direction/origin cue, and final-impact change. Cosmetic VFX cannot imitate them.
- Friendly, hostile, interactable, invulnerable, targeted, and objective states remain distinguishable under color-vision filters.
- Nameplates are distance/importance culled. Never show all labels merely because entities exist.
- Off-screen lethal threats use directional indicators with distance/urgency; indicators are capped and prioritized.
- Camera shake, bloom, hit flash, damage numbers, allied VFX, and haptics have independent intensity controls.

### Raid budget

- At most one primary boss frame, one active cast/mechanic banner, and four compact party-critical alerts are expanded simultaneously.
- Party frames prioritize dead, disconnected, targeted, low-health, cleanse/interrupt need; stable members compress.
- Allied nonessential VFX default to **30% opacity/intensity equivalent** and may be reduced to silhouettes/decals; hostile mechanics never inherit that reduction.
- Boss attacks telegraph for device/network variance and remain readable at minimum supported render scale.
- Revive and encounter objective replace the contextual control; they do not create an extra central button.

### PvP budget

- Silhouette, team, class, Mantle, HP state, target, objective carrier, and crowd-control state are readable without opening a panel.
- Competitive cosmetics cannot hide hitboxes, mimic skills, remove class/Mantle identity, or create misleading afterimages.
- Damage numbers aggregate by short windows; non-target nameplates and pets/companions reduce first.
- Score/objective uses one compact header. Kill feed caps at three entries and collapses automatically.
- Input, simulation, matchmaking, scoring, normalization, result, and rating are server-authoritative; the client never resolves a competitive outcome.

## 6. Performance and thermal budgets

### Device tiers and frame targets

| Tier | Gameplay target | Degradation floor | Requirement |
|---|---:|---:|---|
| Mid/high supported | stable 60 fps | 45 fps transient | default profile; raids/PvP included |
| Minimum supported | stable 30 fps | 25 fps transient | reduced profile; same mechanics/readability |

Frame pacing is the gate, not average FPS. Over a 20-minute representative session after warm-up:

- target-frame delivery: **≥95%**;
- no single avoidable main-thread or render hitch above **100 ms**;
- 99th-percentile frame time: **≤25 ms** on 60-fps profile, **≤40 ms** on 30-fps profile;
- no sustained thermal collapse below the tier floor;
- orientation change, first combat, first skill, and first menu open produce no shader-compilation hitch above 100 ms after installation warm-up.

CPU and GPU should each remain below **14 ms** on the 60-fps profile and **28 ms** on the 30-fps profile in representative gameplay, leaving scheduling margin. Device qualification, not desktop/headless throughput, proves these limits.

### Scene budgets

Budgets are measured at representative worst-case camera framing:

| Metric | 60-fps profile | 30-fps/minimum profile |
|---|---:|---:|
| Draw calls, ordinary field | ≤140 | ≤100 |
| Draw calls, raid/PvP peak | ≤190 | ≤135 |
| Visible transparent instances | ≤70 | ≤45 |
| Real-time shadow casters | ≤8 | ≤3 |
| Simultaneous full-rate animated combat entities | ≤20 | ≤12 |
| Simultaneous important VFX systems | ≤16 | ≤10 |

Exceeding a budget requires a device trace and approved exception; being under budget does not prove performance. M04.31A/B’s 46 desktop draw calls, 57 transparent instances, and 3 shadow casters are useful slice evidence, not mobile certification.

### Memory, loading, and package

- Peak proportional-set/resident memory targets: **≤1.2 GB** mid/high and **≤750 MB** minimum tier.
- Active-region texture residency target: **≤384 MB** mid/high and **≤220 MB** minimum.
- Audio residency target: **≤96 MB**; stream music and long ambience.
- No unbounded caches, combat logs, chat histories, pooled particles, or downloaded asset retention.
- Cold launch to interactive account/character screen: **≤12 s** at device median; warm resume: **≤3 s** when no patch/migration is required.
- Hub-to-field transition: **≤6 s** median; instanced activity load: **≤10 s** median. Show meaningful progress and cancel/retry where safe.
- Delivery size and downloadable packs require a release-specific platform budget; optional voice/high-resolution packs are separable and integrity checked.

## 7. LOD and rendering policy

LOD order preserves gameplay information:

1. cull hidden/off-screen particles and update rates;
2. reduce distant ambience, decorative animation, secondary motion, and vegetation density;
3. reduce allied cosmetic VFX and transparent layering;
4. swap distant props/buildings to approved atlases/impostors;
5. reduce non-target entity animation sampling;
6. reduce render scale within a bounded dynamic-resolution range;
7. never remove hostile telegraphs, collision cues, objective markers, target silhouette, or class/Mantle identity.

Requirements:

- Use pooled VFX and damage text with hard concurrency caps.
- Shader variants are prewarmed per region/activity; runtime shader compilation during combat is a defect.
- Sprite/card overdraw is visualized and budgeted; large transparent quads are tightly trimmed where asset integrity permits.
- Transparent entities sort from stable footpoints; LOD cannot change authoritative collision or targetability.
- Occluders fade only through explicit spatial metadata. Canopy/roof fading cannot expose false paths or hide danger.
- Dynamic resolution scales world rendering, not UI text/touch geometry; text remains native-resolution.
- Quality changes use hysteresis and happen between intensity peaks where possible.

## 8. Network behavior

### Transport experience

- Client sends intents; server validates and replicates authoritative outcomes.
- Local prediction may cover movement and safe presentation. It cannot predict inventory grants, purchases, upgrades, loot ownership, quest completion, raid/PvP results, or rating.
- Snapshot/interpolation rates are activity- and bandwidth-aware. Rate reduction must preserve hostile cast timing and competitive integrity.
- Payloads are versioned, bounded, compressed where useful, and contain no camera state.
- Network indicators distinguish latency, packet loss, server stall, authentication loss, and maintenance; “offline” is not used for every error.

### Degradation

- At elevated latency, preserve input acknowledgement, cast timing, correction clarity, and cancel rules. Never silently extend client range or accept expired actions.
- At packet loss, interpolate bounded motion and show stale-state warning before entities appear trustworthy but outdated.
- On correction, avoid camera teleport where a short visual reconciliation is valid; authoritative world position still wins.
- Chat, telemetry, cosmetics, and noncritical presence degrade before combat/encounter state.

### Reconnect

| State | Required behavior |
|---|---|
| Brief interruption, ≤5 s | retain presentation, buffer only bounded legal input, show reconnect indicator |
| Recoverable disconnect | stop new value-changing actions, authenticate with resume token, request full authoritative resync |
| Field/hub resume | restore safe authoritative position/state; deduplicate rewards and transactions |
| Dungeon/raid resume | reserve party slot for configured grace period; restore checkpoint/encounter state if eligible |
| PvP resume | server rules control grace, bot/idle handling, score, and result; no client-awarded protection |
| Token expired/conflict | return to explicit account/character recovery without deleting local settings |

All reward, shop, trade, craft, upgrade, entitlement, and quest commits use idempotency identifiers. A retry must return the prior result, not grant or consume twice.

## 9. Background, interruption, and lifecycle behavior

- On app pause/background: immediately release held inputs, stop camera gestures/haptics, reduce audio per platform, save only client-local settings, and notify the server of lifecycle change when possible.
- The character does not continue client-driven movement/combat in background.
- Field/hub characters enter the server’s safe disconnect policy. Instanced and PvP activities follow disclosed activity rules.
- On resume within the valid window: revalidate session, time, catalog/config version, party/instance membership, and authoritative state before enabling actions.
- Phone calls, permission prompts, store overlays, account link, and OS low-memory termination follow the same recovery path.
- Never require notification permission to play. Deep links land at a safe screen after authentication, never directly commit or purchase.
- Patching is resumable, checksum verified, bandwidth aware, and clear about download size. Cellular download requires consent above the release-set threshold.
- Local notifications are optional, frequency-capped, quiet-hour aware, and do not use false urgency or punishment language.

## 10. Session design

| Activity | Product target | Mobile requirements |
|---|---:|---|
| Check-in/claim | 1–3 min | one-hand operable; no forced world load |
| Field/RQ | 5–10 min | safe stop after each objective packet |
| Story/SQ | 10–20 min | dialogue skip/replay and checkpoints |
| Dungeon | 12–20 min | ready check, checkpoint, reconnect |
| PvP | 5–10 min | disclosed duration and abandonment rules |
| Raid | 20–35 min | encounter checkpoints, breaks between pulls, rejoin |

No mandatory uninterrupted hour, no loss of earned rewards because the OS paused the app, and no daily streak reset designed to punish absence. Every activity declares expected duration before queue/entry.

## 11. Accessibility standard

### Visual

- UI text supports at least **100–200%** scale; critical combat text meets contrast requirements against dynamic backgrounds.
- Color is never the sole carrier of team, rarity, danger, element, success, or failure.
- Color-vision presets, high-contrast telegraphs, reduced flash, reduced bloom, reduced camera shake, reduced damage numbers, and simplified allied VFX are available.
- Avoid more than three flashes per second and platform-defined seizure-risk patterns; photosensitivity review is a ship gate.
- Captions identify meaningful non-speech audio direction/source when relevant.

### Motor and touch

- Full control remap; left-handed layout; adjustable joystick/button size, spacing, location, opacity, dead zone, and sensitivity.
- Hold/toggle alternatives for sustained actions; repeated taps have alternatives where gameplay permits.
- Aim/target assist settings are disclosed and balanced; PvP applies mode rules consistently.
- Menus are operable with touch, controller, switch access pathways supported by platform, and no time limit unless gameplay-essential.

### Hearing and communication

- Independent master/music/SFX/voice/UI sliders; mono audio option; subtitles with size, background, speaker, and direction options.
- Voice chat is optional, off by default for restricted accounts, and never required for matchmade completion.
- Quick-chat/ping vocabulary covers target, danger, regroup, defend, attack, help, revive, ready, and mechanic assignment.
- Mute, block, report, and chat filters are reachable during and after an encounter.

### Cognitive and language

- Plain objectives, consistent icons/terms, tutorial replay, quest recap, map breadcrumbs, and error recovery steps.
- Cutscenes/dialogue support pause where technically safe, skip, replay/log, and subtitle speed.
- Timed prompts disclose duration and provide extensions when not competitively essential.
- Localization supports text expansion, pluralization, input method, font fallback, and bidirectional layout if a language is approved.

Accessibility settings apply at first boot, sync safely to the account where appropriate, and remain available offline as local preferences. Accessibility does not weaken server authority.

## 12. Privacy, safety, and commerce

- Request only permissions needed at point of use with a plain-language reason.
- Do not collect precise location, contacts, advertising ID, microphone, or notification access by default.
- Telemetry is minimized, documented, retention-limited, and separated from chat/moderation evidence.
- Age/region controls, parental settings, platform purchase flow, restore purchases, receipts, refunds, and spending safeguards are implemented before monetization.
- Paid UI has exact contents and price, no accidental single-tap purchase, no paid random loot boxes, no combat power, and no deceptive urgency.

## 13. Test and release gate

A mobile claim requires physical-device evidence on at least the current minimum, representative mid, and representative high supported devices for both operating systems where shipped. Test:

- fresh install, patch, migration, cold/warm launch, account and character lifecycle;
- landscape/portrait, cutouts, aspect extremes, 100/150/200% UI scale, left-handed mode;
- 30-minute field/hub, 20-minute dungeon, 35-minute raid, and repeated PvP sessions;
- Wi-Fi/cellular handoff, latency/loss, airplane interruption, suspend/resume, call/store overlay, process kill, reconnect and duplicate transaction retry;
- thermal, battery, memory pressure, load times, frame pacing, overdraw, draw calls, shader hitches and crash-free sessions;
- screen reader/platform accessibility inspection, color/flash review, captions, remapping, text expansion and localization;
- entitlement restore, purchase failure, parental restriction, refund state, report/block/mute and account recovery.

Required evidence includes device/OS/build, quality profile, scenario, duration, percentile frame times, thermal state, peak memory, network conditions, failures, screenshots/video, and trace location. Desktop captures, headless process rates, or presence of export templates do not constitute mobile proof.

Current status at authority publication: Android export preset/build and real-device validation are **MISSING**; existing M04.31 desktop landscape/portrait evidence is **IMPLEMENTED** presentation evidence only. No launch feature is **PRODUCTION PROVEN** on mobile until this gate passes.
