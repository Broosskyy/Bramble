# BRAMBLE PvP, Social and Endgame Masterplan

Status: locked cap-60 product/live-operations contract. Canon: five regions, 25 maps, five hubs, three PvP modes, six dungeons and three raids.

## Product principles

- Endgame is parallel choice, not a mandatory checklist. PvE, PvP, crafting, exploration, collections and social play each advance useful goals.
- Match outcomes, inventory, ratings, rewards and lockouts are server-authoritative. The client sends intents and presentation preferences.
- Competitive power cannot be bought. Matchmaking does not optimize spending or engagement loss. Rewards value mastery and participation without rewarding AFK behavior.
- Touch is a first-class control scheme. Every telegraph, target action and mode objective must remain readable in portrait and landscape.

## Exactly three PvP modes

### PVP_01 — Duel

Format: consensual 1v1, best of three rounds, 90s per round. Available in designated hub rings and private challenge instances. Both players preview rule set, latency region, companion option and accept. Default ranked-season impact: none.

Rules: standardized level 60 template for skills/stats; open-world gear appearance retained. Arena shrinks after 60s. Healing dampening begins at 30s. A draw awards neither win progress. Partners/pets disabled by default; optional companion duel is unranked and mutually accepted.

Rewards: first three completed daily duels grant modest `CU_ARENA_MARK`; no reward for repeated same-account/opponent pair after three. Wins, losses and respectful rematches advance cosmetic duel commendations. No exclusive power.

### PVP_02 — 3v3 Arena

Format: ranked or unranked teams of three, best of five 120s rounds. Solo/duo/team queues are separated where population permits; matchmaking prioritizes region/ping, rating and party size. Respawn occurs next round only.

Objective: defeat opposing team or hold the central bloom at timeout. Role-flex matchmaking avoids hard role locks but prevents extreme template duplication in ranked. Mantle and loadout lock at ready check.

Rewards: personal season rating, Arena Marks, weekly vault choice and cosmetic rank track. Rating rewards are titles, frames, dyes, emotes and mounts/pets without combat stats. Participation requires contribution thresholds based on damage, healing, mitigation, objective time and support, normalized by role.

### PVP_03 — 8v8 Battleground

Format: 16 players, 12-minute target, 15-minute hard cap; unranked core queue with seasonal team rating event. Respawn waves every 15s.

Objective: capture two of three Briar Beacons to generate score; escort a spawned Canopy Wisp for a temporary third route. First to 1,000 points wins. Backdoor protection, visible capture states and three lanes prevent spawn trapping. Mercy rule ends a mathematically unrecoverable match after 8 minutes.

Rewards: Arena Marks, battleground collection progress, first-win bonus and season cosmetics. Win bonus is meaningful, but a verified competitive loss receives at least 70% of base progress to reduce toxicity and queue dodging.

No additional PvP modes are implied. Tournament brackets, guild wars or open-world killing require a future canon change and are not launch modes.

## Touch-native competitive controls

- Left thumb: floating movement joystick with dead zone, sprint edge and accessibility fixed-position option.
- Right thumb: basic attack, dodge, four skill buttons, Mantle utility and contextual objective interaction. Minimum touch target 48dp with configurable spacing/scale.
- `TAP` uses smart target priority; hold opens explicit target selector. `HOLD_AIM` shows direction/range and releases to cast; drag back into cancel zone aborts. `PLACED` clamps reticle to legal ground. `CHANNEL` requires continuous hold or accessibility toggle.
- Target cycle prioritizes player-selected target, enemies threatening self, lowest-health ally for heals and objective actors only when an objective skill is pressed. The server never accepts targets outside legality.
- Camera drag occupies safe world regions only after controls consume touches. Aim assist adjusts direction, never range, timing or unseen targets. Controller/keyboard/touch matchmaking is pooled only after telemetry confirms parity; ranked may separate inputs.
- Haptics, colorblind shapes, telegraph opacity, reduced flashes and screen shake are configurable. Critical enemy casts use shape + sound + edge cue.

## Normalization and balance

All structured PvP scales participants to level 60 and applies a mode template:

- Class/Mantle kit, legal weapon family and selected build nodes remain.
- Gear contributes appearance and a capped distribution choice, not item level. Artifact effects use standardized PvP versions.
- Pets and partners are disabled; fairy choice maps to one normalized utility template.
- Consumables, world buffs, raid set procs and paid conveniences are disabled.
- Crowd control uses categories with diminishing returns: second same-category effect within 12s is 50%, third grants 8s immunity. Break effects have visible cooldowns.
- Separate PvP coefficients cover damage, healing, shields, resource gain, execute thresholds and displacement. PvE tuning never silently changes PvP.

Balance cadence: urgent exploit hotfix anytime; numeric review every two weeks; structural changes only at season midpoint or boundary except critical health. Decisions use pick/win rate by rating/input/party, time-to-defeat, objective contribution and counter-matchups. A 48–52% broad win-rate band is a signal, not an automatic nerf. Patch notes publish intent and offer free build retunes.

## Seasons and rewards

Season length: 12 weeks plus a one-week preseason overlap for rewards and tuning. Placement uses ten matches with confidence bounds; soft reset preserves matchmaking quality. Rank tiers: Seed, Sprout, Briar, Crown, Elder, Canopy. Decay applies only to inactive top 1% after a clear 14-day warning.

Weekly PvP vault: complete any 6 scored matches, 3 wins or 1,200 objective contribution points; choose one of three equivalent-budget rewards. The paths do not stack into triple reward. Season track has free cosmetics/currency only; if a paid cosmetic pass exists, it grants no rating, gear, currencies convertible to power or faster weekly cap.

Anti-abuse:

- Server replay/audit of movement, cooldown, targeting, damage, objective and reward events.
- AFK detection combines input, displacement, combat/support and objective contribution; reconnect grace is 3 minutes.
- Repeated surrender, win trading, same-pair farming, queue synchronization, boosting and account sharing trigger escalating review holds. Automated detection does not issue permanent bans without review.
- Hidden MMR is separate from visible rating. Parties use highest uncertainty-adjusted member rating, never average-only smurf advantage.
- Leavers lose queue access progressively; innocent teammates receive rating-loss protection only when abuse-safe conditions pass.
- Reporting categories are concise; block/mute is immediate; post-match avoids open enemy chat by default.

## Cap-60 PvE endgame

### Six dungeons

1. `DGN_01 Rootbound Cellar` — R01, teaching/level-up and cap challenge.
2. `DGN_02 Thornvault Burrows` — R02, line-of-sight, adds, tether management.
3. `DGN_03 Brineglass Grotto` — R03, reflection lanes and timed movement.
4. `DGN_04 Embervein Foundry` — R04, heat lanes and vent interrupts.
5. `DGN_05 Fallen Star Archive` — R05, route choices and resonance puzzles.
6. `DGN_06 Nightglass Depths` — cap 60, multi-Mantle mastery.

Each supports story and challenge difficulty. Challenge uses fixed weekly affix pairs selected from a tested pool, five keystone steps and deterministic token/pity rewards. Affixes alter decisions, not enemy health alone, and never invalidate a class. Matchmade runs target 20–30 minutes.

### Three raids

1. `RAID_01 The Drowned Orrery` — R03, 8 players, three bosses, entry endgame.
2. `RAID_02 The Caldera Ward` — R04, 8 players, four bosses, advanced elemental coordination.
3. `RAID_03 Heart of Starfall` — R05, 8 players, four bosses, pinnacle cap-60 conclusion.

Story mode is matchmade and preserves narrative. Standard is coordinated but accessible through party finder. Challenge adds prestige cosmetics and faster targeting, never exclusive raw item budget. Personal loot and slot-family tokens prevent loot disputes. Encounter lockouts apply to bonus loot, not practice or helping friends.

## Exact cap-player parallel goals

A cap-60 player sees six lanes. Completing one daily and three weekly lanes earns the universal maximum power-progress allowance; extra lanes remain valuable for cosmetics, reputation, social help and mastery without forcing all content.

### Daily goals (reset 06:00 server-region time)

Choose any 3 of these 6; each takes approximately 10–20 minutes:

1. Adventure: complete 2 public events or 3 regional tasks.
2. Dungeon: complete 1 story/challenge dungeon.
3. Competitive: complete 2 scored PvP matches with contribution.
4. Craft: fulfill 2 work orders or refine 3 requested batches.
5. Explore/collect: discover 1 rotating secret or add 3 collection entries.
6. Social/help: complete 1 mentor queue or guild contract with another player.

The first 3 award full universal daily bundles; goals 4–6 thereafter award 25% soft currency plus lane reputation/cosmetics. Missed daily bundles accrue up to six Rested Petals, consumed automatically on future completions.

### Weekly goals

Choose any 3 of these 6:

1. Complete 4 dungeon objectives, with one challenge step.
2. Defeat 3 raid bosses or complete one full story raid.
3. Complete 6 PvP matches, 3 wins or 1,200 objective points.
4. Finish 5 regional/public-event chains across at least 2 regions.
5. Deliver 5 high-value work orders and one guild project contribution.
6. Complete 8 collection, exploration, mentor or companion objectives.

Each selected lane grants one Canopy Cache choice. Exactly three caches per week can contain power progression; further lane completions grant cosmetics, reputation and catch-up tokens. Progress is additive—no “all objectives in one run” trap. Weekly reset and caps are always visible.

### Long-term goals

- Complete 25-map exploration: exactly 5 maps per region and one hub per region (5 hubs total).
- Rank all eight Mantles to 10 through class-specific journeys.
- Complete collections for six fairies, eight pets and four partners.
- Earn each dungeon mastery at keystone 5 and all three raid story conclusions.
- Pursue PvP season rank/cosmetic collections with no PvE power requirement.
- Complete one profession codex, regional reputations and account-wide appearance library.
- Optional prestige: no-stat titles, housing/guild-hall trophies and challenge visual variants.

## Social systems

Launch:

- Friends, recent players, block/mute/report, presence privacy and cross-platform party invites.
- Parties of four for world/dungeons and raids composed from two parties; role/build summary, ready check, reconnect and vote-to-remove safeguards.
- Text chat: party, raid, guild, local and direct message with filters, rate limits and parental controls. Quick-chat and pings cover all required objectives.
- Party finder with activity, language, learning/experienced tag, schedule and minimum published requirement; no paid listing priority.
- Guild foundation: 50 members, ranks/permissions, message, roster, activity calendar, shared goals and cosmetic banner.
- Collections: equipment appearances, lore, maps, bosses, Mantles, companions and seasonal cosmetics; account-wide where appropriate.

Post-launch:

- Guild hall as cosmetic/social progression; shared projects cannot grant exclusive combat stats.
- Guild alliances, event calendar improvements, inspectable achievement showcases and opt-in mentor reputation.
- Spectator/replay for approved competitive events, community-created party-finder templates and housing visits.
- Voice chat only after platform moderation, parental and accessibility requirements are met; never required for matchmaking.

## Guild safeguards and progression

Guild ownership transfer has inactivity rules and a seven-day audit window. Currency withdrawals use granular permissions, daily caps and immutable logs. Invitations and messages are rate-limited. Guild progression comes from diverse member contributions with per-account normalization; large guilds unlock cosmetics sooner but cannot gain stronger buffs. Leaving never deletes personal rewards. Guild contracts rotate among PvE, PvP, craft, exploration and mentorship so one playstyle cannot monopolize progress.

## Collections and achievements

Every collection entry shows source, availability window and whether it can return. Missable power does not exist. Seasonal cosmetics enter an archive path no earlier than two seasons later, with original-season prestige marker retained. Achievement points are display-only. Collection completion rewards titles, dyes, emotes, follower cosmetics, housing/guild trophies and premium-quality visual variants without stats.

## Live operations

- 12-week seasons: weeks 1–2 onboarding/story, 3–5 activity rotation, 6 midpoint patch/event, 7–10 mastery, 11 finale, 12 catch-up/celebration.
- Events reuse maps through new objectives/dialogue/encounters while preserving the permanent 25-map canon; temporary instances do not count as new maps.
- A public calendar shows start/end, grace vendor, reward sources and maintenance. Emergency changes receive inbox notice.
- Telemetry monitors queue time, completion/failure, class/Mantle representation, economy faucets/sinks, churn, harassment reports and device performance. It must not drive manipulative personalized prices or opaque drop-rate changes.
- Content cadence target: one meaningful event or challenge rotation every 2–4 weeks; quality and mobile performance gates override calendar pressure.

## Expansion and catch-up

An expansion may raise content breadth but does not silently change locked counts or cap 60; any cap/region/map/class/Mantle change requires an explicit new canon revision. New raids/dungeons cannot invalidate existing story access.

Catch-up activates one season after a power tier:

- Story completion unlocks a seven-objective returning-player path to prior-tier baseline.
- Rested weekly credit stores up to two missed weeks.
- Previous raid tokens gain a higher cap and reduced exact-item cost.
- Account-wide map, waystone, cosmetic, fairy/pet and recipe knowledge reduces alt repetition.
- Mentor scaling lets geared players help without trivializing mechanics; both receive bounded rewards.
- Returning players never receive current pinnacle rewards automatically, and active players retain cosmetic/prestige recognition.

## Authority, reliability and acceptance

The server validates queue eligibility, party, input rate, movement, skill targets, normalized loadout, objective state, score, rating and rewards. Match and loot operations are idempotent. Disconnect snapshots allow safe reconnect; abandoned instances resolve rewards once. Region selection uses measured latency and exposes it before ranked acceptance.

Acceptance requires real-device portrait/landscape tests, minimum/maximum player-count load, all class/Mantle matchups, colorblind/readability checks, reconnect, surrender, tie, timeout, AFK and abuse cases. Bots can test rules but cannot certify feel, fairness or touch ergonomics.

## Launch/post-launch reconciliation

Launch modes: Duel, 3v3 Arena and 8v8 Battleground—all three complete. Launch PvE includes all six dungeons and all three raids. Post-launch cap-season content adds challenge refinements and separately approved social features without reclassifying launch Raid 3.

Counts:

- PvP modes: 3 exactly (`PVP_01`–`PVP_03`).
- Dungeons: 6 exactly (`DGN_01`–`DGN_06`).
- Raids: 3 exactly (`RAID_01`–`RAID_03`).
- Regions/maps/hubs: 5 regions, 25 maps (5 each), 5 hubs (1 each).
- Level cap: 60.
