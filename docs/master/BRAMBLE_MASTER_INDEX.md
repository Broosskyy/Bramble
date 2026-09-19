# BRAMBLE Master Index

Status: **authoritative production index**  
Baseline: M04.31B, Godot 4.7.2  
Current phase: M04 production foundation complete except the Batch 001 authored
Wayfarer action pack. The next phase is production from this blueprint, not
another architecture spike.

## Authority and precedence

When documents disagree, use this order:

1. This index fixes authority, scope, IDs, counts, and precedence.
2. `docs/master/BRAMBLE_MASTER_CONCEPT_VNEXT.md` owns product identity,
   launch scope, system relationships, authority boundaries, UI and audio.
3. `docs/master/BRAMBLE_LEVEL_1_TO_ENDGAME_PLAN.md` owns level pacing,
   unlocks, first-session flow, and endgame loops.
4. Domain masterplans own their named content:
   - `BRAMBLE_WORLD_CONTENT_MASTERPLAN.md`
   - `BRAMBLE_CLASSES_AND_SP_MASTERPLAN.md`
   - `BRAMBLE_PVE_DUNGEON_RAID_MASTERPLAN.md`
   - `BRAMBLE_EQUIPMENT_LOOT_ECONOMY_MASTERPLAN.md`
   - `BRAMBLE_COMPANIONS_FAIRIES_PETS_MASTERPLAN.md`
   - `BRAMBLE_PVP_SOCIAL_ENDGAME_MASTERPLAN.md`
   - `BRAMBLE_MOBILE_PRODUCT_STANDARD.md`
5. `docs/production/BRAMBLE_CONTENT_MASTER_REGISTER.csv` is the stable-ID
   inventory; domain plans supply prose detail.
6. `docs/production/BRAMBLE_ASSET_MASTER_REGISTER.csv` owns asset status and
   authored-output counts. The repaired `assets/game/_catalog/` remains the
   source of truth for existing-file identity and provenance.
7. `BRAMBLE_ART_PRODUCTION_MATRIX.md`, `BRAMBLE_ASSET_SCALE_BIBLE.md`,
   `BRAMBLE_POSE_SOCKET_BIBLE.md`, and `BRAMBLE_ANIMATION_BIBLE.md` own
   authoring contracts.
8. `BRAMBLE_ASSET_CREATION_QUEUE.md` owns build order; its Creation Cards
   specialize, but may not contradict, the bibles.
9. `BRAMBLE_ASSET_BUDGET.md` owns launch output totals and mobile envelopes.
10. `BRAMBLE_PRODUCTION_ROADMAP.md` owns phase gates.
11. Milestone reports record evidence and never override later master plans.

No source sheet, filename, old kit label, mockup, or secondary reference can
override verified catalog provenance or this authority chain.

## Locked launch canon

- Level cap: **60**, with additive post-launch cap increases.
- Regions: **5**; world maps: **25**; hubs: **5**.
- Dungeons: **6**; raids: **3**.
- Classes: **4**; Mantles (specialist/SP forms): **8**, two per class.
- Field enemies: **50** (40 standard, 10 elite).
- Bosses: **14** (5 world minibosses, 6 dungeon bosses, 3 raid bosses).
- NPCs: **35**.
- Equipment tiers: **6**.
- Pets: **8**; partners: **4**; fairies: **6**.
- PvP modes: **3**.
- Quests: **90 main, 60 side, 25 repeatable**.

Progression bands:

| Band | Levels | Region |
|---|---:|---|
| B01 | 1–12 | R01 Amberway Vale |
| B02 | 13–24 | R02 Briarwood Reach |
| B03 | 25–36 | R03 Sunmere Coast |
| B04 | 37–48 | R04 Cinderpeak March |
| B05 | 49–60 | R05 Starfall Fen |

Classes are `CLS_01 Briar Vanguard`, `CLS_02 Gale Strider`,
`CLS_03 Ember Arcanist`, and `CLS_04 Bloom Warden`. Mantles are transformative
visual/gameplay profiles, not recolors: Thorn Bastion, Sunsteel Duelist,
Tempest Ranger, Veilrunner, Cinder Sage, Tideshaper, Grovekeeper, Starcaller.

## Existing-content reconciliation

The current `data/content/` is an implemented prototype contract, not the
launch content database. Preserve it until migration is scheduled.

| Existing ID | Evidence status | Launch mapping |
|---|---|---|
| `adventurer` | IMPLEMENTED tutorial prototype | pre-class state, levels 1–5 |
| `sword` | IMPLEMENTED prototype | migrates to `CLS_01` |
| `bow` | IMPLEMENTED prototype | migrates to `CLS_02` |
| `mage` | IMPLEMENTED prototype | migrates to `CLS_03` |
| Bloom Warden | MISSING | new `CLS_04` |
| Existing German map/enemy IDs | IMPLEMENTED prototype | alias during R01 migration |

Do not rename live IDs in documentation-only work. The roadmap requires an
explicit content migration with compatibility aliases and save migration.

## Proven, partial, and planned

Evidence labels follow `BRAMBLE_MASTER_CONCEPT_VNEXT.md` §12. No launch
feature is **PRODUCTION PROVEN** on mobile target devices until
`BRAMBLE_MOBILE_PRODUCT_STANDARD.md` §13 passes with real-device evidence.

**IMPLEMENTED (M04 slice / desktop presentation):** Node3D spatial world;
hybrid 2D/2.5D presentation; limited orbit/follow camera; camera-relative
adaptive presenter; authoritative world facing and client-local camera;
canonical Moorling Kit60/70/71; cataloged organic roads; authored shallow-2.5D
buildings; visible equipment layers; landscape/portrait **desktop** framing;
multiplayer movement/combat smoke.

**IMPLEMENTED (systems):** offline explore/combat/loot/XP loop; basic NPC quest;
inventory/equipment/economy authority services; ENet host/client and snapshots;
Kit88 starter melee cels; equipment-state visual profiles.

**PARTIAL:** equipped player action quality; skills end-to-end; persistence
database runtime; inventory/economy client flows; party; mobile production HUD;
reconnect/app lifecycle; content migration.

**EXPERIMENTAL:** M04.26 Wayfarer armor/helmet atlases and certified lab
artifacts until promoted by the asset register.

**PLANNED:** all launch regions beyond the proven micro-area, classes/Mantles,
companions, dungeons, raids, PvP, guilds, endgame and LiveOps.

**MISSING:** Batch 001 Wayfarer action keyposes; real-device performance data;
production backend deployment; complete launch content and production audio.

**SUPERSEDED:** universal eight-direction requirements; flat/rectangular test
map composition; Kit21-as-Moorling claims; camera yaw in authority; the
assumption that `assets/game/` is undeployed.

## Locked production lessons

- Player = 1.0 scale anchor; visible power growth is mandatory.
- Direction count is per entity/state: 1/2/4/8/billboard/custom.
- Camera state stays client-local; gameplay state stays authoritative.
- Authored art supplies identity/anatomy/key silhouettes. Godot supplies
  restrained timing, travel, recoil, secondary motion, LOD and VFX events.
- Maps use authored roads, clustered environmental pockets, controlled
  density, combat breathing room and foreground/midground/background depth.
- Mobile readability and thermal/network budgets are design constraints, not
  a later porting pass.
- Visual Masters are reference-only targets. NosTale supplies structural
  lessons only; no proprietary content may be copied.

## Current blocker and queue

The only M04 visual P1 blocker is Batch 001: eight male windup/commit cardinal
body PNGs, eight matching Wayfarer armor overlays, and one socket JSON at
512×512 with pivot `(256,468)` and no mirroring. Exact instructions are in
`docs/production/BRAMBLE_ASSET_CREATION_QUEUE.md`.

After Batch 001, work top-to-bottom through that queue and accept each roadmap
gate before opening the next content band.

## Drift-control rule

Any scope/count/ID change must update, in one review:

1. this index;
2. affected domain plan;
3. content register;
4. asset register and budget;
5. creation queue if production order changes;
6. roadmap gate.

If those six do not reconcile, the change is not production-approved.
