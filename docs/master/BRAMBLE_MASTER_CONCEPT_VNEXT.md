# BRAMBLE Master Concept vNext

Status: **PRODUCTION AUTHORITY — LAUNCH CANON**  
Engine: **Godot 4.7.2**  
Product: **original mobile-first anime/chibi spatial 2.5D MMORPG**  
Authority rule: this document governs product identity and launch quantities. Evidence labels govern what exists today; a launch commitment is not an implementation claim.

## 1. Product identity

BRAMBLE is a shared-world action MMORPG about restoring five blighted regions by mastering a class, forming bonds with companions, and awakening two class-specific specialist transformations called **Mantles**. Short, readable mobile sessions feed a persistent journey from level 1 to 60; field exploration, authored quests, social hubs, dungeons, raids, PvP, collection, and visible equipment growth form one connected game.

Presentation is painterly anime/chibi in spatial 2.5D: authoritative entities move in a 3D world while authored directional art, equipment layers, companions, contact shadows, VFX, and local camera framing preserve sprite clarity. Landscape and portrait show the same world state and geometry.

## 2. Product pillars

1. **Readable action anywhere.** One-second player recognition, open combat pockets, clear targets, danger telegraphs, hit confirmation, and touch-first controls.
2. **Progress you can see and feel.** Equipment, Mantles, fairies, pets, partners, skills, VFX, and access visibly change the avatar and mechanically change viable challenges.
3. **A connected world with reasons to return.** Routes, landmarks, encounters, recovery points, NPCs, hubs, group content, and regional stories replace disconnected menus and farming rooms.
4. **Class identity with transformative mastery.** Four readable base classes support immediate roles; two Mantles per class create major visual and mechanical specialization rather than recolors.
5. **Social without coercion.** Parties, guilds, hubs, matchmaking, trade, raids, and PvP deepen play; core story progression remains practical without forced spending or permanent group dependence.
6. **Trustworthy persistence.** The client sends intent; server authority validates combat, rewards, inventory, trade, progression, and competitive outcomes.

## 3. Launch canon

### World and progression

- Level cap: **60**
- Regions: **5** (`R01`–`R05`)
- World maps: **25**, exactly five per region, including one hub per region
- Hubs: **5**
- Instanced PvE: **6 dungeons**, **3 raids**
- Bands: `1–12 R01 Amberway Vale`; `13–24 R02 Briarwood Reach`; `25–36 R03 Sunmere Coast`; `37–48 R04 Cinderpeak March`; `49–60 R05 Starfall Fen`

### Playable identities

| ID | Class | Mantle 1 | Mantle 2 |
|---|---|---|---|
| `CLS_01` | Briar Vanguard | `SP_C01_01` Thorn Bastion | `SP_C01_02` Sunsteel Duelist |
| `CLS_02` | Gale Strider | `SP_C02_01` Tempest Ranger | `SP_C02_02` Veilrunner |
| `CLS_03` | Ember Arcanist | `SP_C03_01` Cinder Sage | `SP_C03_02` Tideshaper |
| `CLS_04` | Bloom Warden | `SP_C04_01` Grovekeeper | `SP_C04_02` Starcaller |

**Mantle** is the only player-facing fiction term. `SP_*` remains the stable data-ID family. Mantles replace the active body/animation profile while preserving authoritative character identity, transform, collision, combat state, and normalized action time.

### Content quantities

| Family | Launch quantity |
|---|---:|
| Field enemies | 50: 40 standard + 10 elite |
| Open-world minibosses | 5 |
| Dungeon bosses | 6 |
| Raid bosses | 3 |
| NPCs | 35 |
| Equipment tiers | 6 |
| Pets | 8 |
| Partners | 4 |
| Fairies | 6 |
| PvP modes | 3 |
| Main quests | 90 |
| Side quests | 60 |
| Repeatable quests | 25 |

Counts are distinct launch catalog entries, not palette swaps presented as new content. Boss counts are exclusive by category. A dungeon or raid may include non-boss encounters without increasing these boss counts.

## 4. Connected core loop

`choose goal → travel from hub → explore/read route → quest or encounter → target and execute class combat → earn authoritative rewards → equip/upgrade/craft/bond → visibly increase capability → unlock harder map, Mantle, dungeon, PvP, or raid → regroup/socialize → choose next goal`

Every feature must connect to at least two adjacent parts of this loop:

- Quests introduce places, enemies, systems, NPCs, and group objectives.
- Field combat supplies XP, materials, equipment, fairy/pet bond progress, and regional reputation.
- Hubs concentrate recovery, crafting, trade, guild, matchmaking, and narrative handoff.
- Dungeons test role execution and award tier/crafting progression.
- Raids test coordinated mechanics and award aspirational horizontal and prestige goals.
- PvP uses normalized competitive rules and rewards status/cosmetics, not mandatory PvE power.
- Collection changes world presence or tactical options; it is never a disconnected checklist only.

## 5. Combat and session contract

Combat is approachable action-RPG play: movement plus target selection/assist, basic chain, four active skill slots, one contextual action, defensive/mobility action, potion, and Mantle action when unlocked. Attacks show anticipation, commit, impact, and recovery. Ordinary enemies teach one readable behavior; elites combine behaviors; bosses test telegraphs, positioning, interrupts/defense, adds, and role coordination.

| Session intent | Target duration | Valid completion |
|---|---:|---|
| Check-in / claim / market | 1–3 min | one useful account action |
| Field objective / repeatable | 5–10 min | one quest step or reward packet |
| Story segment / crafting plan | 10–20 min | checkpointed objective |
| Dungeon | 12–20 min | checkpoint/rejoin protected |
| PvP match | 5–10 min | complete scored match |
| Raid | 20–35 min | encounter checkpoints and reconnect |

No session may require an uninterrupted hour. Long narrative sequences need skip, replay, and checkpoint support. Auto-pickup may reduce touch burden; unattended combat, autoplay progression, and offline power farming are outside the product identity.

## 6. Launch versus post-launch

### Launch commitment

The complete quantities in section 3, level 1–60 journey, all four classes and eight Mantles, six equipment tiers, companion families, crafting/economy, social foundations, three PvP modes, daily/weekly endgame, accessibility, mobile performance qualification, reconnect, telemetry, moderation, customer support, and live-operations controls.

### Post-launch direction

- New story chapters, maps, encounters, cosmetics, collection goals, guild activities, and seasonal rule sets.
- Cap increases only with a new progression band, catch-up path, upgraded equipment path, and retained relevance for prior endgame.
- Additional classes or Mantles require full animation, balance, server, UI, audio, accessibility, and device certification; they are not launch dependencies.
- Existing launch regions remain useful through scaling events, materials, collections, social goals, and rotating objectives.

Post-launch plans have no committed count or date until separately approved. Launch scope may not be deferred and still represented as launch-complete.

## 7. Monetization boundary

Allowed: direct-purchase cosmetics, cosmetic bundles, account-service conveniences with safeguards, optional seasonal cosmetic track, and transparent non-power collection presentation. Purchases must show exact contents and local price, support parental/platform controls, and never obscure refund or probability information.

Forbidden:

- selling combat stats, equipment tiers, Mantle power, raid eligibility, PvP advantage, or exclusive best-in-slot power;
- paid random loot boxes or disguised gacha;
- paid energy, death penalties, inventory pressure engineered to interrupt play, or monetized reconnect;
- cash-to-player currency conversion that compromises the economy;
- purchasable quest skips that invalidate progression learning;
- manipulative countdowns, false discounts, dark patterns, or targeting minors by spend behavior.

Earned and paid cosmetics must remain visually readable and cannot imitate hostile telegraphs, class/Mantle silhouettes, or moderation badges.

## 8. System dependency matrix

| System | Hard dependencies | Produces / feeds | Launch gate |
|---|---|---|---|
| Identity/session | authentication, character repository, reconnect token | character access, moderation identity | reconnect and duplicate-login tests |
| Spatial world | map data, collision, portals, spawn service, local camera | exploration, combat spaces, hubs | 25 maps validated both orientations |
| Character/classes | class catalog, stats, skills, animation profiles | combat role and progression | all four classes 1–60 viable |
| Combat | movement, target/range checks, skill/status services, enemy AI | XP/reward events, durability-free challenge | server validation and readable telegraphs |
| Mantles | class/quest gates, skill loadouts, body profiles, VFX/audio | specialization and endgame builds | eight complete forms, no recolor-only form |
| Questing | NPC/map/enemy catalogs, flags, reward transactions | guided progression and unlocks | 175 quests validated and recoverable |
| Rewards/progression | combat/quest events, transaction service, catalogs | levels, currency, items, reputation | idempotent grant and rollback |
| Inventory/equipment | item instances, repository, equipment rig | visible/mechanical power | six tiers; ownership and socket integrity |
| Crafting/upgrades | recipes, materials, item instances, economy | deterministic item improvement | preview, atomic consume/grant, no client prices |
| Pets/partners/fairies | collection, bond state, spatial presenter, combat rules | companionship and tactical options | ownership, summon, dismissal, recovery |
| Party/guild/social | identity, presence, chat/moderation, matchmaking | group formation, hubs, raids | block/report/mute and disconnect handling |
| Dungeons/raids | instances, party, boss AI, loot lockouts | group mastery and endgame rewards | 6/3 complete; checkpoint/rejoin |
| PvP | matchmaking, normalized rules, anti-cheat, result service | ranked/unranked competition | three modes, authoritative scoring |
| Economy/trade/shop | server catalog, transactions, item instances, audit/outbox | exchange and sinks | atomic PostgreSQL-backed production path |
| UI/accessibility | every player-facing domain, input abstraction, localization | control and comprehension | touch, controller, safe-area, screen-reader review |
| Live operations | config, telemetry, entitlements, moderation, rollback | events, support, safe changes | staged rollout and audit trail |

No content-production multiplier begins until its shared dependency is proven in a representative vertical slice.

## 9. Server-authority matrix

| Domain | Client may send | Server owns and validates | Client-local only |
|---|---|---|---|
| Session | authenticate/select/resume intent | identity, character binding, token validity | remembered UI tab |
| Movement | timestamped input/world movement intent | speed, collision, position acceptance, correction | joystick placement, camera-relative conversion |
| Camera/presentation | none authoritative | no camera state | yaw, pitch, zoom, orientation layout, fades, sprite direction |
| Combat | target/attack/skill intent | range, target, resources, cooldowns, damage, status, death | anticipation feel, hit presentation after event |
| Enemy/boss | none beyond legal interaction | AI state, aggro, attacks, HP, defeat | interpolation and cosmetic secondary motion |
| Quest | accept/advance/turn-in intent | prerequisites, flags, counters, rewards | tracking/pinning |
| Progression | allocation/claim intent | XP, level, unlocks, reputation, cap | celebration presentation |
| Inventory/equipment | move/equip/use intent | ownership, stack/instance identity, slot legality, consumption | sorting and filters |
| Crafting/upgrades | recipe/instance intent | recipe, costs, outcome, atomic transaction | preview animation |
| Loot/rewards | pickup/claim intent | eligibility, rolls, lockouts, idempotent grant | beam, sound, notification |
| Shops/trade | offer/lock/confirm/buy/sell intent | catalog prices, ownership, locks, atomic commit, audit | comparison layout |
| Companion | summon/command intent | ownership, cooldown, position, combat contribution | local flourish |
| Party/guild/chat | invite/join/message/admin intent | membership, permissions, filtering, sanctions | panel placement |
| Dungeon/raid | queue/ready/leave intent | instance, checkpoint, encounter, lockout, result | spectator framing |
| PvP | queue/input intent | match, normalization, score, result, rating | reticle and feedback |
| Entitlements | purchase/restore request via platform | verified receipt and entitlement ledger | storefront presentation |

Production persistence is dedicated-server infrastructure. Database credentials, admin secrets, catalog authority, and economy logic never ship in Android/iOS clients.

## 10. UI screen inventory

### Entry and account

Boot/update; age/region and legal consent; sign-in/account link; server/region status; character list/create/delete; reconnect/conflict recovery; settings; accessibility; support/status.

### In-world HUD

Player status; target status; movement; attack/skills/defense/potion/Mantle; contextual interaction/hold; quest tracker; minimap/map access; party; chat collapsed state; loot/reward notifications; danger/network/reconnect state; boss/raid mechanics; PvP score/objective.

### Progression and collection

Character stats; class/skills/loadout; Mantles; inventory; equipment/compare; upgrade; crafting/recipes; fairies; pets; partners; quest journal; world map/region completion; achievements/collections; mail/reward claim.

### Social and activities

Friends/block list; party finder; party detail; guild roster/management; chat channels/report; dungeon/raid finder; ready check; encounter summary; PvP modes/queue/rank/history; player inspect; secure trade.

### Economy and service

NPC shop; sell/repurchase; marketplace only if separately approved; currency ledger; cosmetic store; purchase confirmation; restore purchases; wardrobe; season/event page; announcements; customer support and account management.

Every screen requires loading, empty, success, recoverable error, offline/reconnect, and restricted-account states. Destructive and paid actions require explicit confirmation.

## 11. Audio plan

| Layer | Requirement |
|---|---|
| Music | one identity theme per region and hub family; dungeon/raid/PvP escalation; seamless low/high intensity stems where practical |
| Ambience | region biomes, hub life, interiors, weather, landmarks; sparse enough to preserve cues |
| Combat | class-specific anticipation/impact/recovery, enemy windups, hits, guard, defeat, status and boss mechanics |
| Progression | distinct hierarchy for pickup, quest step, equipment upgrade, level, Mantle, rare item and major unlock |
| Companions | restrained identity, command, bond and warning cues; no constant vocal spam |
| UI | consistent navigation, confirm, deny, cooldown-ready, queue, trade lock, purchase and error vocabulary |
| Voice | effort barks and selected narrative moments; text remains complete without voice |
| Accessibility | independent music/SFX/voice/UI sliders, mono compatibility, captions for meaningful non-speech cues, vibration alternatives |

Audio events consume authoritative gameplay events but do not determine outcomes. Critical danger must have visual and haptic equivalents. Mobile memory/voice limits require streaming policy, concurrency caps, priority ducking, and device profiling.

## 12. Evidence status classification

These labels are mandatory in plans, reports, dashboards, and acceptance:

| Label | Meaning |
|---|---|
| **PRODUCTION PROVEN** | Runs end-to-end in the intended production topology and target devices, with current runtime evidence, acceptance tests, and approved quality/performance. |
| **IMPLEMENTED** | Complete in code/content for stated scope and passes local/automated checks, but lacks one or more production-topology, device, scale, or final-quality proofs. |
| **PARTIAL** | A meaningful path exists, but required wiring, content, quality, persistence, or coverage is incomplete. |
| **EXPERIMENTAL** | Deliberate spike or temporary asset/path used to answer a question; not approved for broad production. |
| **PLANNED** | Approved product/design commitment with no sufficient implementation evidence. |
| **MISSING** | Required capability or evidence does not exist. |
| **SUPERSEDED** | Historical work replaced by a named newer authority; retained only for traceability. |

Current baseline:

- M04.31A spatial world-art slice: **IMPLEMENTED** desktop evidence; not broad zone proof.
- M04.31B starter authored attack: **IMPLEMENTED**; equipped Wayfarer directional action pack: **PARTIAL**.
- Spatial entity presentation/limited-yaw camera contract: **IMPLEMENTED** in the slice.
- Two-process ENet movement/reconnect/combat sanity: **IMPLEMENTED**, not production-scale proven.
- Server authority domains and transaction foundations: **PARTIAL** end-to-end.
- PostgreSQL runtime adapter: **MISSING**.
- Android export preset/build and real-device evidence: **MISSING**.
- Full launch catalog in section 3: **PLANNED** except demonstrated slice content.
- Protected M04.3 work: outside this authority and untouched.

Only **PRODUCTION PROVEN** supports a ship claim. Reports must name scope, platform, topology, date, and evidence; “working” without those qualifiers is invalid.

## 13. Modernized inspiration principles

BRAMBLE may learn from durable social MMORPG principles associated with games such as NosTale without copying names, lore, characters, maps, art, UI, quests, skills, balance, code, data, or progression tables:

- welcoming base classes that grow into collectible specialist identities;
- visible companions and equipment as social expression;
- compact hubs feeding field routes and instanced group challenges;
- long-lived collection, trade, and community goals;
- readable low-friction combat with meaningful build choice.

BRAMBLE modernizes them through original Mantle fiction and designs, touch-first active combat, server-authoritative transactions, transparent deterministic progression, reconnectable short sessions, accessibility, fair monetization, portrait/landscape parity, and spatial 2.5D presentation. Inspiration is structural; all player-facing expression and implementation must be original.

## 14. Acceptance authority

A launch feature is accepted only when product quantity, gameplay connection, original presentation, server authority, persistence, UI states, audio/haptics, accessibility, mobile performance, reconnect behavior, analytics, moderation/support, and runtime evidence agree. Screenshots outrank code claims for presentation; device traces outrank desktop estimates for mobile performance; authoritative transaction logs outrank client UI for value changes.
