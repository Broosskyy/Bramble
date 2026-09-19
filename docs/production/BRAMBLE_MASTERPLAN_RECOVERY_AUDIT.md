# BRAMBLE Masterplan Recovery Audit

Date: 2026-09-18  
Recovery pass: interrupted Sol documentation run  
Worktree: `BRAMBLE_GAME/` (M04.3 WIP preserved separately)

## Executive summary

The interrupted Sol run produced **16 of 18** expected deliverables at **SUBSTANTIAL** or **COMPLETE** quality. Recovery completed the **2 missing P0 documents**, reconciled register/name drift, and validated launch counts. The masterplan is **PARTIAL** — structurally coherent for production, with P2 detail (per-quest IDs, per-skill rows, full Creation Card library) still deferred.

**INTERRUPTED SOL WORK RECOVERED: YES**

---

## Deliverable classification

| Deliverable | Status | Last completed section / notes |
|---|---|---|
| `BRAMBLE_MASTER_INDEX.md` | **COMPLETE** | Drift-control rule; recovery added asset budget precedence |
| `BRAMBLE_MASTER_CONCEPT_VNEXT.md` | **COMPLETE** | §14 Acceptance authority |
| `BRAMBLE_LEVEL_1_TO_ENDGAME_PLAN.md` | **COMPLETE** | §9 Progression acceptance |
| `BRAMBLE_WORLD_CONTENT_MASTERPLAN.md` | **SUBSTANTIAL BUT INCOMPLETE** | §9 Consistency gates; map display names differ from register IDs |
| `BRAMBLE_CLASSES_AND_SP_MASTERPLAN.md` | **COMPLETE** | Reconciliation; all 8 Mantles at launch |
| `BRAMBLE_PVE_DUNGEON_RAID_MASTERPLAN.md` | **COMPLETE** (recovery) | Was **MISSING**; created from world content + register |
| `BRAMBLE_EQUIPMENT_LOOT_ECONOMY_MASTERPLAN.md` | **COMPLETE** | Reconciliation |
| `BRAMBLE_COMPANIONS_FAIRIES_PETS_MASTERPLAN.md` | **COMPLETE** | Reconciliation; register IDs `FAIRY_01`/`PARTNER_01` |
| `BRAMBLE_PVP_SOCIAL_ENDGAME_MASTERPLAN.md` | **COMPLETE** | Recovery aligned dungeon/raid names to PvE masterplan |
| `BRAMBLE_MOBILE_PRODUCT_STANDARD.md` | **COMPLETE** | §13 Test and release gate |
| `BRAMBLE_ART_PRODUCTION_MATRIX.md` | **COMPLETE** | Production acceptance |
| `BRAMBLE_ASSET_SCALE_BIBLE.md` | **COMPLETE** | M04.31B pivot exception documented |
| `BRAMBLE_POSE_SOCKET_BIBLE.md` | **COMPLETE** | Full socket and depth contract |
| `BRAMBLE_ANIMATION_BIBLE.md` | **COMPLETE** | M04.31B gap cross-reference |
| `BRAMBLE_CONTENT_MASTER_REGISTER.csv` | **SUBSTANTIAL BUT INCOMPLETE** | 209 rows; recovery fixed class/Mantle/dungeon/raid/miniboss names |
| `BRAMBLE_ASSET_MASTER_REGISTER.csv` | **SUBSTANTIAL BUT INCOMPLETE** | 46 families; aggregate rows use `..` ranges not per-entity rows |
| `BRAMBLE_ASSET_CREATION_QUEUE.md` | **SUBSTANTIAL BUT INCOMPLETE** | Batches 001–010 + CC_001–005; batches 006–010 lack per-card detail |
| `BRAMBLE_ASSET_BUDGET.md` | **COMPLETE** (recovery) | Was **MISSING** |
| `BRAMBLE_PRODUCTION_ROADMAP.md` | **COMPLETE** | Phase 0–5 gates |

### P2 still deferred

| Item | Status |
|---|---|
| Individual Creation Cards for batches 006–010 | **STARTED** (template refs only) |
| Per-quest `Q_R##_M###` rows in content register | **MISSING** (arcs only) |
| Per-skill `SK_` rows in content register | **MISSING** (families only) |
| Map display-name harmonization (world vs register) | **STARTED** (IDs stable; names differ cosmetically) |

---

## Completed by Sol (preserved)

- Master Index with locked launch canon and precedence chain
- Master Concept vNext with product identity, UI inventory, audio plan
- Level 1–60 progression with first 30 min / 5 hr flows
- World Content masterplan with 5 regions, 25 maps, quest allocation, asset truth table
- Classes/SP masterplan with 4 classes, 8 Mantles, full skill production matrix
- Equipment/Loot/Economy, Companions, PvP/Social/Endgame, Mobile Product Standard
- Art Production Matrix, Scale Bible, Pose/Socket Bible, Animation Bible
- Content Master Register (209 stable IDs)
- Asset Master Register (46 families, 5,330 expected outputs)
- Asset Creation Queue (10 batches, Batch 001 fully specified)
- Production Roadmap (Phase 0–5)

---

## Completed during recovery

- Created `BRAMBLE_PVE_DUNGEON_RAID_MASTERPLAN.md`
- Created `BRAMBLE_ASSET_BUDGET.md`
- Created this recovery audit
- Reconciled content register: class names, 8 Mantle names, 6 dungeon names, 3 raid names, 5 miniboss names, `RAID_01` region `R03`
- Aligned PvP/Social/Endgame dungeon and raid names to PvE masterplan
- Aligned companions reconciliation to register IDs (`FAIRY_01`, `PARTNER_01`)
- Added asset budget to Master Index precedence chain

---

## Still incomplete

1. **Content register granularity** — quest arcs and skill families exist; individual `Q_*` and `SK_*` rows not expanded (P2).
2. **Asset register granularity** — aggregate `MON_R01_01..MON_R05_08` rows; not 50 per-monster asset rows (acceptable for launch planning).
3. **Creation queue detail** — batches 006–010 are batch-level specs; Creation Cards CC_006+ not written (P2).
4. **Map display names** — world masterplan uses e.g. `Ambercross`; register uses `Amberway Crossroads` (same IDs, cosmetic drift only).
5. **Companion prose IDs** — body text still uses `FAI_01`/`PAR_01`; register uses `FAIRY_01`/`PARTNER_01` (aliases documented).

---

## Launch content totals (verified)

| Category | Canon | Register count | Match |
|---|---:|---:|---|
| Level cap | 60 | — | ✓ |
| Regions | 5 | 5 | ✓ |
| World maps | 25 | 25 | ✓ |
| Classes | 4 | 4 | ✓ |
| Mantles/SPs | 8 | 8 | ✓ |
| Field enemies | 50 | 40 MON + 10 ELITE | ✓ |
| Minibosses | 5 | 5 BOSS_R | ✓ |
| Dungeon bosses | 6 | 6 BOSS_D | ✓ |
| Raid bosses | 3 | 3 BOSS_RAID | ✓ |
| Total bosses | 14 | 14 | ✓ |
| Dungeons | 6 | 6 DGN | ✓ |
| Raids | 3 | 3 RAID | ✓ |
| NPCs | 35 | 35 | ✓ |
| Pets | 8 | 8 | ✓ |
| Partners | 4 | 4 | ✓ |
| Fairies | 6 | 6 | ✓ |
| PvP modes | 3 | 3 | ✓ |
| Equipment tiers | 6 | 6 EQ_T | ✓ |
| Main quests | 90 | 5 arcs × 18 | ✓ |
| Side quests | 60 | 5 arcs × 12 | ✓ |
| Repeatable | 25 | 5 arcs × 5 | ✓ |

---

## Asset register summary

| Status | Families | Files |
|---|---:|---:|
| READY | 4 | 96 |
| PARTIAL | 18 | 1,772 |
| REWORK | 4 | 144 |
| MISSING | 19 | 3,318 |
| NOT_REQUIRED | 1 | 0 |
| **Total** | **46** | **5,330** |

Provenance classes used in domain docs: READY, SOURCE EXISTS (within PARTIAL rows), PARTIAL, REWORK, MISSING, NOT REQUIRED.

---

## Asset creation queue

- **Batches:** 10
- **First gate:** Batch 001 (17 files: 16 PNG + 1 JSON)

### First 5 batches

| Batch | Goal | Files |
|---|---|---:|
| 001 | M04.31B Wayfarer melee attack pack | 17 |
| 002 | Player directional locomotion + damage | 80 |
| 003 | Mobile HUD landscape/portrait layouts | 2 |
| 004 | Amberway NPC cast (7 × 8 directions) | 56 |
| 005 | R01 field enemies (8 species full sets) | 288 |

---

## M04.3 WIP status

**PRESERVED** — Untouched. Modified tracked files (`scenes/main.tscn`, `scripts/bootstrap.gd`, etc.) and `artifacts/m04_3/` remain **outside** the documentation commit scope.

---

## Masterplan verdict

**PARTIAL** — All P0 structure documents and registers exist and reconcile on counts/IDs. P1 domain masterplans complete. P2 per-entity register expansion and Creation Cards 006–010 remain future documentation work, not production blockers after Batch 001.

---

## Inconsistencies found and resolved

| Issue | Resolution |
|---|---|
| PVE masterplan missing | Created; now name authority for dungeons/raids |
| Asset budget missing | Created |
| Register Mantle names ≠ classes masterplan | Fixed to Thorn Bastion, Sunsteel Duelist, etc. |
| Register class short names | Fixed to Briar Vanguard, Gale Strider, etc. |
| Dungeon/raid names differed across 3 docs | Unified to world-content names via PvE masterplan |
| `RAID_01` region was R02 in register | Fixed to R03 per world content |
| Companion ID prefix drift | Register IDs canonical; aliases in companions doc |
| Kit21/Moorling provenance | Preserved in all bibles and queue |

## Inconsistencies noted (not blocking)

- Map hub display names differ between world masterplan prose and register names (IDs match).
- Companion body text uses `FAI_`/`PAR_` shorthand; register uses `FAIRY_`/`PARTNER_`.
- Content register lacks individual quest and skill rows (arcs/families only).
