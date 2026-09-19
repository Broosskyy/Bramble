# BRAMBLE Asset Budget

Status: launch production contract  
Authority: `BRAMBLE_ASSET_MASTER_REGISTER.csv`, `BRAMBLE_ASSET_CREATION_QUEUE.md`  
Scope: authored visual outputs for launch; audio excluded

## 1. Summary totals

| Metric | Value |
|---|---:|
| Asset families in register | 46 |
| Register production deliverables (all types) | **5,330** |
| **Authored raster PNG outputs** | **5,259** |
| Metadata / layout deliverables (non-raster) | 71 |
| Creation queue batches | **10** |
| Queue batch file sum | **5,234** |
| Audio placeholder families | 1 (`NOT_REQUIRED`) |

### Three-way count distinction (mandatory reporting)

| Count type | Value | Definition |
|---|---:|---|
| **A. Unique visual designs** | **~620** | Distinct identities/concepts a human/AI artist must design once |
| **B. Authored source outputs** | **5,259** | Unique PNG files that must be painted/exported |
| **C. Expected runtime files** | **~5,700–6,100** | Imported files after extraction, icon downscales, boss LOD sheets, atlas packing |

Register `TOTAL_EXPECTED_OUTPUT_FILES` is a **production-deliverable ledger**, not a synonym for painted art workload. Per the Art Production Matrix, excluded from **B**: `AST_M0431B_SOCKET` (1 JSON), `AST_UI_HUD_CORE` (2 `.tres`), `AST_UI_SCREENS` (68 `.tres`). Icon masters count once at 256×256 in **B**; 128/64 exports add to **C** only.

The queue batch sum (**5,234**) scopes net-new work and excludes **96 READY** catalog files marked reuse. It must not be confused with **B** or **C**.

## 2. Register status breakdown

| Status | Families | Expected files | Meaning |
|---|---:|---:|---|
| READY | 4 | 96 | runtime-usable without new art |
| PARTIAL | 18 | 1,772 | source or partial coverage; extraction/rework required |
| REWORK | 4 | 144 | semantic or directional correction required |
| MISSING | 19 | 3,318 | no suitable verified family |
| NOT_REQUIRED | 1 | 0 | intentionally excluded (audio) |

### READY families (96 files)

- `AST_WORLD_GROUND` — 28 terrain/road modules
- `AST_WORLD_BUILDINGS` — 44 building modules
- `AST_WORLD_ELEVATION` — 16 elevation modules
- `AST_PLAYER_IDLE_8D` — 8 male base direction idles

### Current P0 blocker (17 files, MISSING)

- `AST_M0431B_BODY` — 8 PNG
- `AST_M0431B_ARMOR` — 8 PNG
- `AST_M0431B_SOCKET` — 1 JSON

Batch 001 is the only gate before broader production may proceed.

## 3. Category budgets (register deliverables / raster PNG)

| Category | Families | Register | Raster PNG | Priority |
|---|---:|---:|---:|---|
| Player (incl. Batch 001) | 6 | 105 | 104 | P0 |
| Classes | 4 | 112 | 112 | P1 |
| Mantles / SP | 3 | 400 | 400 | P1 |
| Visible equipment | 3 | 216 | 216 | P0–P1 |
| NPCs | 2 | 280 | 280 | P0–P1 |
| Standard monsters | 5 | 1,440 | 1,440 | P0–P1 |
| Elites | 1 | 360 | 360 | P1 |
| Minibosses | 1 | 220 | 220 | P1 |
| Dungeon bosses | 1 | 312 | 312 | P1 |
| Raid bosses | 1 | 216 | 216 | P1 |
| Pets / partners / fairies | 3 | 712 | 712 | P1 |
| Ground / path | 1 | 28 | 28 | P0 |
| Buildings | 1 | 44 | 44 | P0 |
| Environment (veg/props/elev/portals) | 4 | 138 | 138 | P0–P1 |
| Dungeon / raid kits | 2 | 120 | 120 | P1 |
| Item icons | 1 | 180 | 180 | P1 |
| Skill icons | 1 | 80 | 80 | P1 |
| Skill VFX | 1 | 240 | 240 | P1 |
| Projectiles | 1 | 48 | 48 | P1 |
| UI layouts (non-raster) | 2 | 70 | 0 | P0–P1 |
| PvP presentation | 1 | 9 | 9 | P2 |
| **Total** | **46** | **5,330** | **5,259** | |

Largest raster categories: standard monsters **1,440** (27.4%), NPC idles **280**, elite sets **360**, Mantle actions **256**, monster walk frames alone **640**.

## 4. Batch workload schedule

| Batch | Scope | Files | Phase gate |
|---|---|---:|---|
| 001 | Wayfarer melee attack pack | 17 | Phase 0 |
| 002 | Player locomotion + damage | 80 | Phase 1 |
| 003 | Mobile HUD layouts | 2 | Phase 1 |
| 004 | R01 NPC cast | 56 | Phase 2 |
| 005 | R01 field enemies | 288 | Phase 2 |
| 006 | Classes + equipment foundation | 328 | Phase 2–3 |
| 007 | First Mantles + companion onboarding | 424 | Phase 3 |
| 008 | R02–R05 world roster | 2,078 | Phase 3–4 |
| 009 | Dungeons + remaining Mantles | 1,072 | Phase 4–5 |
| 010 | Raids + PvP + endgame presentation | 889 | Phase 5 |

## 5. Mobile memory and performance envelopes

Per active gameplay scene on **mid-tier** target (see `BRAMBLE_MOBILE_PRODUCT_STANDARD.md`):

| Resource | Low tier | Mid tier | Notes |
|---|---:|---:|---|
| Texture memory (world + entities) | 180 MB | 256 MB | includes atlases |
| Transparent overdraw hotspots | 3 layers | 6 layers | companion stack included |
| Simultaneous VFX particles | 80 | 160 | raid boss phases may burst to 200 for 1 s |
| Draw calls (sprites + UI) | 120 | 180 | batch by atlas |
| Largest single runtime texture | 1024² | 2048² | raid bosses use LOD downscale |
| Companion layers (local trio) | ≤3 | ≤3 | per companions masterplan |

Boss and raid families above 768 px source canvas must ship LOD downscale variants validated on two Android devices before `CERTIFIED`.

## 6. Reuse and provenance policy

Classify every planned asset before authoring:

| Class | Action |
|---|---|
| READY | bind catalog record; no regeneration |
| SOURCE EXISTS | extract per bible; do not load sheet at runtime |
| PARTIAL | complete missing states/directions only |
| REWORK | fix semantic/directional errors; preserve ID |
| MISSING | author from queue Creation Card |
| NOT REQUIRED | exclude from output sum |

Known semantic overrides: Kit21 = vegetation; Moorling = Kit60/70/71. Visual-master PNGs are reference-only.

## 7. Drift control

Any count or status change must update, in one review:

1. `BRAMBLE_MASTER_INDEX.md`
2. affected domain masterplan
3. `BRAMBLE_CONTENT_MASTER_REGISTER.csv`
4. `BRAMBLE_ASSET_MASTER_REGISTER.csv`
5. this budget document
6. `BRAMBLE_ASSET_CREATION_QUEUE.md` if order changes
7. `BRAMBLE_PRODUCTION_ROADMAP.md` gate if phase scope changes

## Reconciliation

- Register deliverables: **5,330** across **46** families.
- Authored raster PNG workload (**B**): **5,259**.
- READY + PARTIAL + REWORK + MISSING = 5,330 deliverables; NOT_REQUIRED = 0 art files.
- Queue batches: **10**; batch sum = **5,234** net-new scoped files; first gate = Batch 001 (**17** deliverables = 16 PNG + 1 JSON).
