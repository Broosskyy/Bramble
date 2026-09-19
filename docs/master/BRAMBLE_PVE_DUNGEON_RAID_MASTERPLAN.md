# BRAMBLE PvE, Dungeon and Raid Masterplan

Status: launch content lock  
Scope: documentation only; level cap 60  
Authority: `BRAMBLE_MASTER_INDEX.md`, `BRAMBLE_WORLD_CONTENT_MASTERPLAN.md`  
Presentation: mobile-first spatial 2.5D; touch-native; landscape and portrait

## 1. Launch contract

- Field PvE: 40 standard enemies, 10 elite field enemies, 5 open-world minibosses across 25 world maps.
- Instanced PvE: 6 dungeons with 6 dungeon bosses; 3 raids with 3 raid bosses.
- Dungeon and raid instance spaces are tracked separately from the 25-map world ledger.
- Raids do not block cap-60 main-story completion. Dungeons gate regional Mantle attunement but not cross-region travel after the first clear.
- Every instance ID in this document is the canonical name for `BRAMBLE_CONTENT_MASTER_REGISTER.csv`.

## 2. Dungeon roster

| ID | Name | Region | Level band | World entrance | Boss ID | Boss name | Teaching focus |
|---|---|---|---|---|---|---|---|
| `DGN_01` | Rootbound Cellar | R01 | 10–12 | `MAP_R01_05` Waystone Hollow | `BOSS_D01` | The Gilded Burrower | positioning, interrupts, party roles |
| `DGN_02` | Thornvault Burrows | R02 | 22–24 | `MAP_R02_05` Warden's Crown | `BOSS_D02` | The Thornbound King | line-of-sight, adds, tether management |
| `DGN_03` | Brineglass Grotto | R03 | 34–36 | `MAP_R03_05` Beacon Isle | `BOSS_D03` | The Glass-Tide Queen | reflection lanes, timed movement |
| `DGN_04` | Embervein Foundry | R04 | 46–48 | `MAP_R04_05` Caldera Gate | `BOSS_D04` | The Ashen Warden | heat lanes, vent interrupts |
| `DGN_05` | Fallen Star Archive | R05 | 56–58 | `MAP_R05_05` Starfall Cradle | `BOSS_D05` | The Fen Oracle | route choice, resonance puzzles |
| `DGN_06` | Nightglass Depths | R05 | 60 | `MAP_R05_05` Starfall Cradle | `BOSS_D06` | The Fallen Star | multi-Mantle mastery, cap challenge |

Each dungeon supports **story** and **challenge** difficulty. Challenge uses fixed weekly affix pairs from a tested pool, five keystone steps, and deterministic token/pity rewards. Affixes alter decisions, not enemy health alone, and never invalidate a class. Matchmade runs target 20–30 minutes on mobile.

### Room-chain contract (all dungeons)

- Entrance foyer with safe reset and tutorial plaque.
- Two traversal rooms with one mechanic each.
- One elite gate room.
- One boss arena with rest shrine outside ranked PvP lock.
- Return portal to the world entrance map.
- Mobile readability: one primary hazard color, one secondary telegraph shape, no full-screen occlusion during boss tells.

## 3. Open-world miniboss roster

Minibosses are world-map climax encounters. They are not counted among the 40 standard field enemies.

| ID | Name | Region | Level | Map | Notes |
|---|---|---|---|---|---|
| `BOSS_R01_01` | Bellhide Grazer | R01 | 12 | `MAP_R01_05` | teaches large-target positioning before `DGN_01` |
| `BOSS_R02_01` | Crownroot Stag | R02 | 24 | `MAP_R02_05` | `Root Guardian` source family; collision review required |
| `BOSS_R03_01` | Saltcrown Matron | R03 | 36 | `MAP_R03_05` | tide-state arena; optional before `RAID_01` |
| `BOSS_R04_01` | Ashmantle Ram | R04 | 48 | `MAP_R04_05` | vent arena; optional before `RAID_02` |
| `BOSS_R05_01` | Cometback Behemoth | R05 | 60 | `MAP_R05_05` | cap-field climax before `DGN_05`/`DGN_06` |

## 4. Raid roster

| ID | Name | Region | Players | Boss ID | Boss name | Boss count inside encounter | Entry requirement |
|---|---|---|---|---|---|---:|---|
| `RAID_01` | The Drowned Orrery | R03 | 8 | `BOSS_RAID_01` | Worldroot Behemoth | 3 | level 36+, `DGN_03` story clear |
| `RAID_02` | The Caldera Ward | R04 | 8 | `BOSS_RAID_02` | Sunforge Dragon | 4 | level 48+, `DGN_04` story clear |
| `RAID_03` | Heart of Starfall | R05 | 8 | `BOSS_RAID_03` | Astral Fen Sovereign | 4 | level 60, `DGN_05` and `DGN_06` story clear |

**Story mode** is matchmade and preserves narrative. **Standard** is coordinated but accessible through party finder. **Challenge** adds prestige cosmetics and faster targeting, never exclusive raw item budget. Personal loot and slot-family tokens prevent loot disputes. Encounter lockouts apply to bonus loot, not practice or helping friends.

### Raid structure contract

- Entry plaza with role briefing, composition check, and mobile-safe ready UI.
- Two progression wings with one mechanic each and a checkpoint.
- One multi-phase boss arena with clearly separated telegraph colors.
- Post-clear reward chamber and return portal.
- Ranked PvP lock applies to declared Mantle for the match; raids allow Mantle switch only at rest shrines between wings.

## 5. Regional PvE integration

| Region | Dungeon | Raid | Miniboss | Mantle gate |
|---|---|---|---|---|
| R01 | `DGN_01` | — | `BOSS_R01_01` | first Mantle quest begins late R02 |
| R02 | `DGN_02` | — | `BOSS_R02_01` | `SP_C01_01`–`SP_C04_01` unlock band 24–30 |
| R03 | `DGN_03` | `RAID_01` | `BOSS_R03_01` | coastal stewardship |
| R04 | `DGN_04` | `RAID_02` | `BOSS_R04_01` | `SP_C01_02`–`SP_C04_02` unlock band 42–50 |
| R05 | `DGN_05`, `DGN_06` | `RAID_03` | `BOSS_R05_01` | cap finale; main story resolves before `RAID_03` |

## 6. Field encounter rules

- Standard enemies (`MON_R##_01`–`MON_R##_08`): 4-direction idle minimum; walk and attack families per asset register.
- Elite enemies (`ELITE_R##_01`–`ELITE_R##_02`): full directional combat set with accent legibility at 110% base scale.
- Spawn budgets per map follow the world content masterplan encounter tables; safe/social pockets reject hostile spawns.
- Leash, respawn cadence, and anti-stack spacing are authored per map cluster, not inferred from art bounds.
- Canonical provenance: Moorling = Kit60/70/71; Kit21 is vegetation only.

## 7. Loot and reward families

- Dungeons award tier-appropriate equipment, crafting tokens, Mantle Resonance, and story keys.
- Raids award cap-tier accessories, raid crests (`CU_RAID_CREST`), cosmetics, and collection entries.
- Challenge affixes add cosmetic variants and targeted pity tokens; they do not create exclusive combat stats unavailable in story mode.
- Every boss encounter declares personal-loot table families in the equipment masterplan; this document owns encounter IDs only.

## 8. Mobile production requirements

- Boss and raid arenas must preserve target ring, primary telegraph, and retreat lane in portrait and landscape.
- Maximum 6 simultaneous hazard overlays on low tier; 10 on mid tier.
- Phase transitions under 2.5 s of full-screen occlusion; prefer edge vignette and ground tell.
- Touch targeting assists may widen selection for adds but not for boss weakpoints.
- Companion policy: partners fill missing party slots in dungeons; pets utility-disabled; fairies low VFX. Raids hide partners/pets; fairies become attachment motes only.

## 9. Art and asset dependencies

| Content tier | Register families | Canvas | Direction policy |
|---|---|---|---|
| Standard monster | `AST_MON_STD_*` | 512×512 | 4 cardinal minimum |
| Elite | `AST_ELITE_VISUALS` | 512×512 | 4 cardinal full set |
| Miniboss | `AST_MINIBOSS_VISUALS` | 768×768 | 4 cardinal full set |
| Dungeon boss | `AST_DUNGEON_BOSS_VISUALS` | 1024×1024 | 4 cardinal full set |
| Raid boss | `AST_RAID_BOSS_VISUALS` | 1536×1536 | 4 cardinal + LOD |
| Dungeon kit | `AST_DUNGEON_KITS` | source-native | fixed oblique modules |
| Raid kit | `AST_RAID_KITS` | source-native | arena modules + hazard sockets |

Production order follows `BRAMBLE_ASSET_CREATION_QUEUE.md` batches 005–010.

## 10. Acceptance gates

- [ ] All 6 dungeon IDs and 3 raid IDs resolve in content and asset registers.
- [ ] Each dungeon has entrance on its listed world map, boss ID, and encounter capture pack.
- [ ] Each raid has regional entry, boss ID, and 8-player mobile readability captures.
- [ ] No raid blocks cap-60 main-story completion.
- [ ] Field roster totals remain 40 + 10 elite + 5 miniboss; instanced bosses remain 6 + 3 raid.
- [ ] Affix pool documented and tested; no class-invalidating weekly pair.

## Reconciliation

- Dungeons: 6 exactly — `DGN_01` through `DGN_06`.
- Dungeon bosses: 6 exactly — `BOSS_D01` through `BOSS_D06`.
- Raids: 3 exactly — `RAID_01` through `RAID_03`.
- Raid bosses: 3 exactly — `BOSS_RAID_01` through `BOSS_RAID_03`.
- Open-world minibosses: 5 exactly — `BOSS_R01_01` through `BOSS_R05_01`.
- Combined boss total for launch canon: 14 (5 + 6 + 3).
