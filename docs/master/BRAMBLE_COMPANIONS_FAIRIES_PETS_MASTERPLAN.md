# BRAMBLE Companions, Fairies and Pets Masterplan

Status: locked content/production contract. Canon: exactly six fairies, eight pets and four partners at launch scope.

## Companion pillars

- Companions show earned progression in the world without replacing the player’s agency.
- One combat partner, one utility pet and one fairy may be equipped, but follower visual limits determine what is rendered. No companion is obtained through random paid acquisition.
- Server owns unlocks, ranks, loadouts, cooldowns and combat outcomes. Follow smoothing, local facing, cosmetic emotes and quality LOD are presentation state.
- In ranked PvP, pets are cosmetic/disabled, fairy combat bonuses are normalized to utility templates, and partners are disabled unless the mode explicitly uses a standardized partner rule. Duels can opt into open-world companion rules before acceptance.

## Original elemental resonance

The First Canopy has six resonances: `VERDANT`, `EMBER`, `TIDE`, `GALE`, `LUX` and `UMBRAL`. They form three readable tensions, not a hard damage wheel:

- Verdant steadies Gale; Gale disperses Ember; Ember clears Verdant.
- Tide reveals Umbral; Umbral dims Lux; Lux purifies Tide’s stagnation.
- Matching an equipped fairy to a skill/Mantle tag unlocks one utility interaction (cleanse, reveal, movement, ward or resource smoothing). It never multiplies raw damage into a mandatory pairing.
- PvE enemies may be `EXPOSED` to one resonance for +8% stagger and clearer mechanics. PvP has no elemental damage bonus; only separately tuned statuses apply.
- Visual language: Verdant leaf/earth, Ember coal/orange, Tide ribbon/blue, Gale spiral/cyan, Lux star/gold, Umbral mist/violet. Shape and audio differentiate them without relying on color.

## Shared progression

Fairies use Bond ranks 1–10; pets use Trust ranks 1–10; partners use Fellowship levels 1–60 and five talent milestones. Progress comes from active play, favorite activities and deterministic quests. Daily affinity has a generous soft bonus, not a hard cap. Catch-up grants 200% affinity until ten ranks below the account’s highest companion. Duplicates never exist; repeat rewards become universal treats or cosmetics.

No companion has hunger decay, injury timers, permanent death, breeding RNG, paid revive or success-chance training. Respec is free in hubs and after balance changes.

## Six fairies

Shared fairy skills: one automatic utility, one player-triggered 30–45s cooldown and one rank-10 cosmetic flourish. Fairies cannot be targeted, body-block, trigger traps or draw aggro.

### FAI_01 — Mossbell

Resonance/role: Verdant, sustain/steadying. Acquisition: R01 waystone restoration quest, guaranteed. Progression preference: gathering and protecting allies. Skills: `SK_FAI_01_01 Soft Moss` grants a small out-of-combat recovery pulse; `SK_FAI_01_02 Rootheart` reduces one knockback and grants 1s control resistance (40s); `SK_FAI_01_03 Bellbloom` cosmetic rank-10 bloom. PvE: recovery and stagger support. PvP: no healing pulse during combat; Rootheart normalized and cannot prevent ultimates. Visual: round green light with bell-leaf wings, low orbit.

Exact assets: 1 portrait, 1 collection icon, 3 skill icons; hybrid billboard/shallow body; idle orbit 12f, travel 8f, react 6f, skill 10f, celebrate 12f; six resonance VFX variants are not shared—Mossbell gets 3 bespoke low/high-tier effects; 5 SFX + 1 chirp set; attachment/follow/occlusion data; landscape/portrait/bright-ground/dark-ground/mobile-overdraw captures.

### FAI_02 — Cinderskip

Resonance/role: Ember, tempo/cleanse. Acquisition: R02 hearth trial. Preference: elite and dungeon victories. Skills: `SK_FAI_02_01 Banked Coal` shortens out-of-combat resource refill; `SK_FAI_02_02 Sparkclean` removes one minor slow and leaves no damage (35s); `SK_FAI_02_03 Firefly Reel` flourish. PvE: rotation recovery. PvP: only mode-approved slow classes, fixed cooldown. Visual: ember core, split coal wings, hopping flight.

Exact assets: portrait + collection + 3 skill icons; body and glow masks; 12/8/6/10/12f state set; 3 bespoke scalable VFX; 6 SFX/chirps; follow metadata and full capture set.

### FAI_03 — Rill

Resonance/role: Tide, cleanse/flow. Acquisition: R02 flooded-garden puzzle. Preference: exploration and healing. Skills: `SK_FAI_03_01 Clear Current` increases safe-zone recovery; `SK_FAI_03_02 Rinsing Arc` removes one minor damage-over-time effect (40s); `SK_FAI_03_03 Moonpool` flourish. PvE: hazard recovery. PvP: cleanse whitelist and no immunity. Visual: droplet body, ribbon fins, smooth figure-eight.

Exact assets: portrait + collection + 3 skill icons; shallow body/ribbon; 12/10/6/12/12f states; 3 low-overdraw VFX; 6 SFX/chirps; transparency stress test, metadata and full captures.

### FAI_04 — Whistlewing

Resonance/role: Gale, mobility. Acquisition: R03 wind-route time trial with accessibility alternate. Preference: traversal discoveries. Skills: `SK_FAI_04_01 Following Breeze` +5% noncombat movement; `SK_FAI_04_02 Updraft` brief slow resistance (35s); `SK_FAI_04_03 Pinwheel Sky` flourish. PvE: traversal and reposition. PvP: noncombat bonus disabled; Updraft normalized. Visual: kite-like cyan wings and spiral tail.

Exact assets: portrait + collection + 3 skill icons; directional shallow body; 12/10/6/10/14f states; 3 scalable VFX; 7 SFX/chirps; speed/follow-band tests, metadata and full captures.

### FAI_05 — Gleam

Resonance/role: Lux, reveal/guidance. Acquisition: R03 observatory constellation quest. Preference: quests and secrets. Skills: `SK_FAI_05_01 Guidelight` highlights nearby interactables after player search input; `SK_FAI_05_02 Clearstar` reveals concealed enemies within 5m for 2s (45s); `SK_FAI_05_03 Dawn Crown` flourish. PvE: secrets/mechanic clarity. PvP: loud tell, fixed radius, no map-wide reveal. Visual: gold star core, prism wings.

Exact assets: portrait + collection + 3 skill icons; billboard/prism mesh hybrid; 12/8/6/12/14f states; 4 VFX including accessibility outlines; 7 SFX/chirps; photosensitivity and visibility QA, metadata and full captures.

### FAI_06 — Hush

Resonance/role: Umbral, threat/escape utility. Acquisition: R04 moonlit memory quest, never random. Preference: stealth objectives and revives. Skills: `SK_FAI_06_01 Quiet Company` reduces open-world enemy detection radius by 5% outside combat; `SK_FAI_06_02 Veilbreak` clears reveal from self only after 1s without damage (45s); `SK_FAI_06_03 Velvet Eclipse` flourish. PvE: safer exploration. PvP: detection reduction disabled; Veilbreak has visible cast and interrupt. Visual: violet moth silhouette with crescent eyes.

Exact assets: portrait + collection + 3 skill icons; moth body/glow masks; 12/10/6/12/14f states; 4 VFX with proximity shimmer; 7 SFX/chirps; visibility and concealment QA, metadata and full captures.

## Eight pets

Pets provide exploration/loot convenience and small open-world utility. They never add direct raid/ranked damage. Utility shares global pet cooldowns and cannot automate combat, gather unattended or bypass inventory limits.

### PET_01 — Acorn Prowler

Role: material finder. Acquisition: R01 forester quest. Progression: Trust from gathering. Skills: `SK_PET_01_01 Sniff Cache` points to one nearby discovered-category node (60s); `SK_PET_01_02 Carry Home` sends one material stack to storage at a hub waystone. PvE/open world only; cosmetic in PvP. Visual: squirrel-fox, leaf tail.

Assets: portrait, collection icon, 2 skill icons; 8-direction idle 6f, move 8f, react 6f, sniff 10f, celebrate 10f; 2 VFX, 8 SFX; follow/collision/ground/shadow/LOD metadata and capture matrix.

### PET_02 — Pebbleback

Role: ore finder. Acquisition: R01 quarry rescue. Trust from mining. Skills `SK_PET_02_01 Stone Sense` and `SK_PET_02_02 Sturdy Pack` (one extra temporary material stack, auto-mails on expiry). PvP cosmetic. Visual: tiny moss tortoise.

Assets: portrait + collection + 2 icons; 4-direction approved due symmetry, 6/8/6/10/10f states; 2 VFX, 7 SFX; no mirroring of shell mark; metadata/captures.

### PET_03 — Reedhopper

Role: fishing helper. Acquisition: R02 angler journal. Trust from fishing/wetland exploration. Skills `SK_PET_03_01 Ripple Tell` improves timing readability, not catch odds; `SK_PET_03_02 Dry Leap` reveals safe shallow crossing. PvP cosmetic. Visual: reed-eared frog.

Assets: portrait + collection + 2 icons; 4-direction 6/10/6/10/12f set; 3 VFX, 8 SFX; water/ground pivots and captures.

### PET_04 — Coalnose

Role: hidden-chest scent. Acquisition: R02 cinder kennel story. Trust from elite chests. Skills `SK_PET_04_01 Warm Trail` hints at unopened local chest; `SK_PET_04_02 Camp Ember` accelerates out-of-combat recovery near rest sites only. PvP cosmetic. Visual: soot hound pup.

Assets: portrait + collection + 2 icons; 8-direction 6/8/6/10/12f; 3 VFX, 9 SFX; scent path readability, metadata/captures.

### PET_05 — Cloudfinch

Role: route scout. Acquisition: R03 summit nest quest. Trust from waystones. Skills `SK_PET_05_01 High View` marks the next player-selected map landmark; `SK_PET_05_02 Tailwind Hop` short traversal hop over tagged gaps, never combat geometry. PvP cosmetic. Visual: round white-blue bird.

Assets: portrait + collection + 2 icons; billboard/directional hybrid 8/10/6/10/12f; 3 VFX, 9 SFX; air follow band and captures.

### PET_06 — Lantern Moth

Role: cave visibility. Acquisition: R03 cavern collection. Trust from secrets. Skills `SK_PET_06_01 Gentle Lamp` local accessibility light; `SK_PET_06_02 Dustscript` exposes nearby lore glyphs. PvP cosmetic with lamp off. Visual: large soft-wing moth.

Assets: portrait + collection + 2 icons; 4-direction 10/10/6/12/14f; 3 VFX, 8 SFX; light performance tiers/photosensitivity QA and captures.

### PET_07 — Bramble Boarlet

Role: salvage helper. Acquisition: R04 broken-caravan quest. Trust from salvaging. Skills `SK_PET_07_01 Good Scrap` previews salvage return; `SK_PET_07_02 Truffle Find` locates one daily cosmetic cooking ingredient. PvP cosmetic. Visual: striped boar with thorn collar.

Assets: portrait + collection + 2 icons; 8-direction 6/8/6/10/12f; 2 VFX, 10 SFX; ground/collision/LOD metadata and captures.

### PET_08 — Starling Wisp

Role: collection guide. Acquisition: R05 collection milestone, guaranteed. Trust from collection completion. Skills `SK_PET_08_01 Missing Thread` selects one incomplete collection hint; `SK_PET_08_02 Memory Path` replays a discovered scenic route. PvP cosmetic. Visual: star-tailed floating cat.

Assets: portrait + collection + 2 icons; 8-direction 8/10/6/12/14f; 4 VFX, 10 SFX; floating pivot, accessibility and captures.

## Four partners

Partners are authored characters with dialogue, relationship quests and combat roles. They use character-grade eight-direction coverage and server AI. Player pings set `FOCUS`, `FOLLOW`, `HOLD` or `INTERACT`; no micromanagement hotbar is required.

### PAR_01 — Rowan Thatch

Role: Vanguard defender; personality: practical hedge guard. Acquisition: R01 main story, permanent after trial. Progression: Fellowship through story, rescues and defensive play. Skills: `SK_PAR_01_01 Shieldcall` taunts PvE/weakens PvP duel targets; `SK_PAR_01_02 Hedge Line` short barrier; `SK_PAR_01_03 Last Branch` emergency ally guard. PvE: tank; PvP: duel opt-in only with normalized kit. Visual: square shield, russet cloak, human-scale chibi.

Exact assets: portrait, bust/dialogue set with 6 expressions, collection icon, 3 skill icons; 8-direction idle 8f, move 10f, basic 10f, 3 skills 12f each, hit 6f, downed 10f, revive 10f, celebrate 12f, 4 emotes; shield/body layers and sockets; 5 VFX, 14 combat SFX, voice effort set, 20 launch dialogue barks; AI/nav/revive/capture tests.

### PAR_02 — Sable Quill

Role: Strider ranged damage/scout; personality: curious cartographer. Acquisition: R02 map-fragment arc. Fellowship from discoveries and precision play. Skills `SK_PAR_02_01 Marking Arrow`, `SK_PAR_02_02 Skipping Shot`, `SK_PAR_02_03 Covering Wind`. PvE: priority damage; duel PvP normalized. Visual: shortbow, map-scroll cape.

Exact assets: portrait, 6-expression bust, collection + 3 skill icons; same character-grade state matrix as Rowan with bow-specific 10/12/14f skill actions; 3 projectiles, 5 VFX, 15 SFX/efforts, 20 barks; full AI/socket/capture tests.

### PAR_03 — Ilyra Ashwater

Role: Arcanist control/burst; personality: exacting elemental researcher. Acquisition: R03 observatory crisis. Fellowship from puzzles and combo play. Skills `SK_PAR_03_01 Steam Lance`, `SK_PAR_03_02 Cooling Field`, `SK_PAR_03_03 Cinderwake`. PvE: AoE/control; duel PvP normalized with reduced control. Visual: split ember/tide staff.

Exact assets: portrait, 6-expression bust, collection + 3 icons; 8-direction full state matrix, skill actions 12/14/16f; 2 projectiles, 6 VFX with mobile tiers, 16 SFX/efforts, 20 barks; overdraw, AI and capture tests.

### PAR_04 — Oren Bellflower

Role: Warden healer/support; personality: warm traveling apothecary. Acquisition: R04 plague-garden story. Fellowship from healing and crafting. Skills `SK_PAR_04_01 Bell Mend`, `SK_PAR_04_02 Clean Ground`, `SK_PAR_04_03 Second Spring`. PvE: sustain/revive; duel PvP normalized and Second Spring disabled. Visual: flower crook, medicine satchel.

Exact assets: portrait, 6-expression bust, collection + 3 icons; 8-direction full state matrix, skill actions 12/14/16f; 6 VFX, 16 SFX/efforts, 20 barks; heal-targeting, revive, AI and capture tests.

Partners use fixed level-appropriate templates, not player hand-me-down gear at launch. Cosmetic friendship outfits are full compatible visual sets with no stats. Partner AI cannot consume player items and teleports safely only after path recovery fails.

## Follower visual and performance limits

- Solo world: render player + 1 partner + 1 pet + 1 fairy. Four combat-readable entities maximum.
- Four-player party: render all players; local partner only when solo instances permit it; local pet/fairy at full detail; remote pets/fairies default hidden beyond 12m and reduced inside 12m. Maximum eight full-detail companion entities on screen.
- Hubs: local pet/fairy full detail; remote companions use 50% density deterministic culling, maximum 12 visible companion entities in camera. Partners remain at designated social anchors.
- Dungeons: partners allowed only for missing-party fill; pets utility-disabled; fairies visible at low VFX. Raids: partners and pets hidden/disabled, fairies reduced to attachment motes. Ranked PvP: pets/partners hidden; fairy is a standardized low-particle mote.
- Companion collision never blocks players. Shadows: partner full contact shadow; grounded pet contact blob; fairy no shadow. Audio applies nearest/priority caps: at most 2 pet voices, 2 fairy chirps and 1 partner bark in any 2s window.
- Per local trio target: ≤3 transparent companion layers, ≤40 sustained particles and ≤2 dynamic lights (normally zero). LOD reduces particles, animation rate, then hides remote cosmetic followers; gameplay signals remain.

## Launch and post-launch

Launch includes the complete six-fairy, eight-pet (`PET_01`–`PET_08`) and four-partner (`PARTNER_01`–`PARTNER_04`) rosters, their regional acquisition quests, collection UI, loadouts and follower budgets. Post-launch may add cosmetics, bond stories or new companions only through separately approved IDs; it cannot defer or substitute any locked launch entry.

## Reconciliation

- Fairies: 6 exactly, one per resonance (`FAIRY_01`–`FAIRY_06`; prose aliases `FAI_01`–`FAI_06`).
- Pets: 8 exactly (`PET_01`–`PET_08`).
- Partners: 4 exactly (`PARTNER_01`–`PARTNER_04`; prose aliases `PAR_01`–`PAR_04`).
- Every entry specifies role, acquisition, progression, skills, PvE/PvP behavior, visual identity and exact asset requirements.
