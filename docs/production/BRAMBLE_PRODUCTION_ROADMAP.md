# BRAMBLE Production Roadmap

Status: master launch and live-production sequence  
Nature: planning and acceptance gates only; this document authorizes no implementation

## Locked launch canon

- Level cap: 60.
- World: 5 regions and 25 maps.
- Player: 4 classes and 8 Mantles/SPs.
- Instanced PvE: 6 dungeons and 3 raids.
- Enemies: 50 field enemies plus 14 bosses.
- Social/progression cast: 35 NPCs, 8 pets, 4 partners, and 6 fairies.
- PvP: 3 modes.

Counts are launch content, not aspirational stretch goals. A reused enemy with only a tint/stat change is not a new enemy identity. A boss included in the 14-boss total is not also counted among the 50 field enemies. The 25-map total means persistent world maps only; six dungeon and three raid instance spaces are tracked separately.

## Governing gates

Every phase has seven required views: system, content, art, mobile, dependencies, playable result, and exit gate. A phase closes only with runtime play evidence, catalog/provenance integrity, landscape/portrait evidence, and no regression of authoritative camera-independent state. Production uses the adaptive `ONE/TWO/FOUR/EIGHT/BILLBOARD/CUSTOM` architecture; no phase can convert this into a universal eight-direction quota.

Protected M04.3 WIP remains outside this roadmap's production edits until its owner resolves it. Existing M04.30/M04.31 standards are authority. Visual tests prove presentation; automated tests alone do not approve art.

## Phase 0 — Close the M04 art gap

System:
- Freeze the M04.30 presenter profile/schema and normalized action-marker contract for the pack integration milestone.
- Define validation inputs without changing camera/network authority.

Content:
- One Wayfarer male melee family in the accepted Amberway slice.

Art:
- Produce Batch001, the exact M04.31B pack: 16 transparent PNG keyposes plus one socket JSON.
- Base male `windup/commit` for `front/right/back/left` (8); matching Wayfarer armor overlays (8).
- Preserve 512×512, straight alpha, 24 px minimum padding, pivot `(256,468)`, and `pixel_size=0.0055`.
- Reuse existing helmet, canonical short sword, slash VFX, ready/travel/impact/follow-through/recovery, shadow response, and nearest-cardinal diagonals.

Mobile:
- Validate normal/far zoom readability, transparent layers, atlas memory, and action cadence on one low and one mid Android device.

Dependencies:
- `Batch001 = M04.31B exact authored pack`. Nothing else may be substituted or used to mark this dependency complete.
- Android export preset and real-device access.

Playable result:
- The accepted M04.31A world slice with a genuinely authored equipped cardinal melee windup/commit and aligned armor/helmet/sword.

Exit gate:
- All 17 Batch001 deliverables pass source/hash, pivot, socket, depth, catalog, runtime yaw-bound, landscape/portrait, multiplayer observer, and two-device review.
- The M04.31B decision changes from `PARTIAL` only on visual evidence.

## Phase 1 — Production pipeline and vertical-slice lock

System:
- Lock catalog schema, extraction/atlas recipes, profile inheritance, animation markers, equipment/SP compatibility records, map content ledger, and device budget tiers.

Content:
- One representative class, one SP, two standard enemies, one elite, one boss, three NPC roles, one pet, one partner, one fairy, one dungeon room chain, and representative PvP readability test actors.

Art:
- Prove every matrix category: character, equipment, environment, projectile, VFX, icon, portrait, and responsive UI.
- Certify one-, two-, four-, eight-, billboard-, and custom-direction examples without implying universal coverage.

Mobile:
- Establish low/mid target devices; texture-memory, transparent-overdraw, particles, draw-call, load-time, battery/thermal, touch-safe-area, and portrait/landscape budgets.

Dependencies:
- Phase 0; catalog collision/review-item disposition; named target-device matrix.

Playable result:
- A 20–30 minute end-to-end slice: onboarding, exploration, NPC interaction, class combat, equipment upgrade, SP preview/transform, companion visibility, boss, reward, and reconnect.

Exit gate:
- Art pipeline can ingest a fresh family reproducibly; no source sheet at runtime; all six direction modes resolve honestly; save/network payloads contain no camera state; two-device session stays within locked budgets.

## Phase 2 — Region 1 and level 1–12 alpha

System:
- Stabilize quest flow, inventory/equipment, class progression, SP unlock framework, party basics, dungeon entry, persistence, telemetry, and accessibility baseline.

Content:
- Region 1 maps and its allocated share of the 25-map ledger.
- Level 1–12 progression; starter content for all 4 classes.
- First launch allocations of enemies, bosses, NPCs, pets/partner/fairy, and one dungeon according to the content ledger.

Art:
- Complete Region 1 biome kit, landmarks, paths/transitions, props/vegetation, NPC portraits, class starter actions, enemy tiers, dungeon kit, icons/UI, and VFX language.

Mobile:
- Touch combat/camera tuning, safe-area coverage, interrupted download/resume, cold/warm load, 30-minute thermal soak, and low-memory recovery.

Dependencies:
- Phase 1 pipeline lock; final Region 1 map/encounter ledger; narrative and class skill lists.

Playable result:
- New account to level 12 across all four classes, with one completed dungeon and visible equipment/companion progression.

Exit gate:
- No progression blocker or placeholder critical art; all Region 1 maps meet route/combat/occlusion/readability gates; save/reconnect works; representative four-player mobile session passes budgets.

## Phase 3 — Regions 2–3 and level 13–36 content alpha

System:
- Expand party finder, guild/social foundation, crafting/economy loops, status/element interactions, companion progression, SP progression, and dungeon difficulty variants.

Content:
- Regions 2–3 and their map ledger allocations.
- Level 13–36 progression.
- Cumulative content reaches the planned midgame share of 50 field enemies, 14 bosses, 35 NPCs, 8 SPs, 8 pets, 4 partners, 6 fairies, and 6 dungeons without exceeding launch totals.

Art:
- Two biome families with transition kits; midgame class/equipment tiers; SP action sets; richer important-enemy coverage; dungeon identities; economy/crafting icons and portraits.

Mobile:
- Four-player dungeon soak, content-streaming and patch-size review, crowded-hub overdraw, network loss/recovery, background/resume, and storage pressure.

Dependencies:
- Region 1 retention/combat evidence; economy tables; social safety requirements; final Region 2–3 encounter ledgers.

Playable result:
- Continuous level 1–36 journey with multiple viable build paths, companions, SP progression, and cumulative dungeon loop.

Exit gate:
- Progression/economy telemetry is sane; no mandatory class/SP lacks action readability; all authored counts reconcile with catalog outputs; low/mid mobile four-player sessions pass.

## Phase 4 — Regions 4–5, level 37–60, and PvE content complete

System:
- Endgame gearing, full class/SP progression, raid party/lockout/reward framework, endgame matchmaking, boss phase recovery, and content completion tracking.

Content:
- Complete all 5 regions, 25 maps, level 1–60 path, 6 dungeons, 3 raids, 50 field enemies, 14 bosses, 35 NPCs, 8 pets, 4 partners, and 6 fairies.
- Lock where every count appears in the world/instance ledger.

Art:
- Complete remaining biome and transition families, endgame equipment and rarity language, all boss/raid phase art and telegraphs, all SP/companion sets, credits/endgame UI, and reward effects.

Mobile:
- Full raid actor/effect load, longest-map memory/load, two-hour thermal/battery soak, low-quality VFX parity, patch/install size, and crash recovery.

Dependencies:
- Phase 3; raid encounter specifications; complete loot/economy tables; final VO/text scope; target concurrency assumptions.

Playable result:
- Complete level 1–60 PvE journey and all launch dungeons/raids with final rewards.

Exit gate:
- Content ledger reconciles exactly to locked canon; every boss attack has gameplay-matched telegraph; no source-only or experimental launch dependency; full-raid low/mid mobile sessions remain readable and within budgets.

## Phase 5 — Three-mode PvP alpha

System:
- Authoritative PvP rules, matchmaking/rating as applicable, anti-cheat/abuse controls, spectator/reconnect policy, normalization rules, reporting/moderation hooks, and deterministic round results.

Content:
- Exactly 3 launch PvP modes, each with named maps/rules/rewards/tutorial entry and no unledgered fourth mode.

Art:
- Team/readability language, target/telegraph variants, objective art, round/result UI, status clarity, reduced-clutter VFX, portraits/icons, and accessibility-safe color/shape pairing.

Mobile:
- Touch targeting under player density, network latency/loss tests, thermal soak across repeated matches, low-quality clarity, safe-area/result UI, and device fairness review.

Dependencies:
- Stable level-60 combat; class/SP roster lock; security/moderation policy; mode specifications and map allocation in the 25-map ledger.

Playable result:
- Queue, play, reconnect where policy allows, complete, reward, and requeue in all three modes.

Exit gate:
- No class/SP/effect becomes unreadable at PvP density; result authority and rewards are abuse-tested; mobile control and frame pacing pass; each mode has balance telemetry and accessibility validation.

## Phase 6 — Feature/content complete beta

System:
- Freeze launch schemas/APIs, migration tools, analytics, support diagnostics, localization pipeline, account recovery, commerce if applicable, privacy/consent, moderation, and live configuration.

Content:
- All locked canon playable; tutorial, achievements, collections, help, accessibility, localization, legal, credits, and support flows complete.

Art:
- Replace every launch placeholder; consistency pass across scale, pivots, sockets, portraits, icons, UI states, rarity, regions, cutscenes, and credits.
- Reconcile authored-output counts separately from extracted/runtime/packing artifacts.

Mobile:
- Full certification matrix across supported OS/device tiers; install/update/uninstall, offline/error states, permissions, notches/foldables/tablets where supported, memory pressure, battery, thermal, and store assets.

Dependencies:
- PvE complete; three PvP modes; final text/legal/store requirements; support and operations runbooks.

Playable result:
- External beta account can experience the complete launch game from onboarding through level 60, raids, companions, and all PvP modes.

Exit gate:
- Zero P0; tightly owned P1 list; crash-free/session, ANR, frame-time, memory, network, economy, progression, and retention thresholds meet signed targets; exact content counts and catalog state pass audit.

## Phase 7 — Release candidate and launch readiness

System:
- Code/content freeze, release branching, migration rehearsal, rollback/kill switches, capacity/load tests, incident command, customer support, exploit response, and disaster recovery.

Content:
- Final balance, drop, schedule, onboarding, raid/PvP availability, and live calendar configuration; no new launch scope.

Art:
- Only approved blocker fixes; final store/campaign captures must reflect actual runtime and supported devices.

Mobile:
- Signed release builds, store validation, staged-rollout controls, telemetry dashboards, CDN/patch rehearsal, and final low/mid/high smoke.

Dependencies:
- Beta gate; platform approval; launch operations staffing; legal/localization sign-off.

Playable result:
- Production-candidate build and backend that can launch, update, roll back, and recover without losing authoritative progression.

Exit gate:
- Go/no-go checklist signed by product, engineering, art, QA, mobile, security, operations, support, and legal; rollback and capacity drills pass; no unowned blocker.

## Phase 8 — Launch stabilization

System:
- Staged rollout, incident response, hotfix/rollback, fraud/abuse monitoring, economy and progression observation, crash/ANR/network triage.

Content:
- Launch calendar only; defer unplanned feature content while stability gates are active.

Art:
- Correct only severe readability, clipping, wrong provenance, device-compatibility, or misleading store/runtime issues.

Mobile:
- Monitor by device/OS/render tier; dynamically reduce optional VFX only through prevalidated profiles; protect telegraph/gameplay parity.

Dependencies:
- Release candidate approval and staffed operations.

Playable result:
- Stable live service with complete locked launch canon available according to the launch schedule.

Exit gate:
- Stabilization thresholds hold for the agreed observation window; no P0 incident; economy and progression remain within intervention bands; support backlog is controlled.

## Phase 9 — Live seasons and sustainable production

System:
- Versioned content/profile schemas, backward-compatible saves, live-event scheduling, experimentation guardrails, archive/restore, and seasonal migration policy.

Content:
- New seasons/events use explicit incremental ledgers. Launch counts remain historical baseline and are never rewritten to include post-launch content.

Art:
- Reuse locked bibles, adaptive direction evidence, catalog provenance, authored-output counting, and mobile fallback. New art never silently downgrades launch assets or overwrites source.

Mobile:
- Re-certify after engine/renderer/OS changes; track install growth, atlas residency, old-device floor, thermal regressions, and patch delta.

Dependencies:
- Launch stabilization exit; approved seasonal strategy and capacity.

Playable result:
- Repeatable live update that adds content while preserving old characters, maps, equipment, companions, PvE, and PvP.

Exit gate:
- Each season passes content, art, economy, compatibility, rollback, operations, and two-tier device gates; postmortems feed the next season without changing launch history.

## Cross-phase production ledgers

Maintain these as controlled planning records before broad production:

- Content ledger: every region/map/class/SP/dungeon/raid/enemy/boss/NPC/pet/partner/fairy/PvP mode with owner, phase, dependencies, and acceptance state.
- Art output ledger: unique authored outputs, extracted/derived runtime files, and packed/config artifacts reported separately.
- Animation coverage ledger: actual state/direction files, generic clips, mirrored fallbacks, nearest fallbacks, procedural augmentation, and gaps.
- Device budget ledger: actor/material/transparent-layer/particle/texture-memory/load/frame-time budgets by map/encounter and device tier.
- Provenance ledger: immutable source, license, hashes, extraction recipes, semantic overrides, catalog status, and runtime evidence.

## Unresolved decisions

1. Lock low/mid Android and iOS target devices, minimum OS versions, frame-time, memory, thermal, install and patch budgets.
2. Resolve the Android export preset and real-device availability before the Phase 0 device gate; this blueprint does not implement that infrastructure.
3. Disposition catalog review items: existing collisions, historical masters, merchant directory split, source-only vegetation/props, and experimental Wayfarer assets.
4. Approve the general production player pivot `(256,464)` while preserving `(256,468)` exclusively for the M04.31B Wayfarer melee family.
5. Validate each non-Wayfarer attack family at normal zoom before choosing eight authored directions over evidence-approved cardinal keyposes.
6. Define signed numerical launch gates for crash-free sessions, ANR, frame time, memory, load, network, battery/thermal, progression, economy, and live capacity.
