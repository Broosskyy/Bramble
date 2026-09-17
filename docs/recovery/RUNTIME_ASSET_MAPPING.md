# Runtime Asset Mapping

> Historical recovery snapshot. Its `assets/game/` deployment status and
> migration phases are obsolete: the canonical library now exists. Use
> `docs/art/BRAMBLE_ASSET_CATALOG_INTEGRITY_AUDIT.md` and
> `assets/game/_catalog/` for current asset truth.

**Runtime source:** `BRAMBLE_GODOT_4_7_2_PARITY_V10_3R_RUNTIME_ASSETS.zip`  
**Canonical catalog:** `GAME_ASSET_CATALOG_V2.zip` (955 indexed files, kits 1–93)  
**Target canonical library:** `assets/game/` (NOT YET DEPLOYED)

## Runtime Asset Inventory (merged into BRAMBLE_GAME)

| Directory | Files | Role |
|-----------|-------|------|
| `assets/catalog_legacy/` | 170 | Legacy catalog JSON + PNG sprites used by village_builder |
| `assets/catalog_legacy/png/` | ~80 PNG | World tiles, buildings, props, NPCs, monsters |
| `assets/equipment/` | 40 | Armor sets + weapons for equipment_rig |
| `assets/animation_frames/` | 184 | Character animation pose sheets |
| `assets/workchat_master_unique/` | 782 | Extended asset pool for dev gallery |

**Total PNG in BRAMBLE_GAME after merge:** 591

## Code → Runtime Path Dependencies

| Code reference | Runtime path | Status in BRAMBLE_GAME |
|----------------|--------------|------------------------|
| `village_builder.gd` → `res://assets/catalog_legacy/png/{id}.png` | catalog_legacy/png/ | **MATCH** — all village IDs present |
| `enemy.gd`, `npc.gd` → catalog_legacy/png/{asset_id}.png | catalog_legacy/png/ | **MATCH** |
| `equipment_rig.gd` → `assets/equipment/armor/{style}_*.png` | equipment/armor/ | **MATCH** |
| `equipment_rig.gd` → `assets/equipment/weapons/{id}.png` | equipment/weapons/ | **MATCH** |
| `asset_registry.gd` → `assets/animation_frames/characters/{gender}/*.png` | animation_frames/ | **MATCH** |
| `equipment_registry_v4.json` → `assets/equipment_items/` | — | **INCOMPATIBLE** — path not used by rig; directory absent |
| `complete_asset_inventory.json` → various workchat paths | workchat_master_unique/ | **MATCH** (dev tooling) |

## V10 Runtime vs Catalog Canonical (`assets/game/`)

| OLD_RUNTIME_ASSET | NEW_CANONICAL_ASSET | Classification |
|-------------------|---------------------|----------------|
| `catalog_legacy/png/terrain_meadow.png` | Kit 01 terrain (catalog) | RUNTIME_ONLY — catalog maps to kit sheets, not individual PNGs yet |
| `catalog_legacy/png/building_inn.png` | Kit 05/39 village buildings | RUNTIME_ONLY |
| `catalog_legacy/png/npc_healer.png` | Kit 08 NPCs / Kit 58 blacksmith dirs | RUNTIME_ONLY |
| `catalog_legacy/png/monster_sprout.png` | Kit 09 field monsters | RUNTIME_ONLY |
| `assets/equipment/armor/leather_*.png` | Kit 07 armor looks | RUNTIME_ONLY |
| `assets/animation_frames/characters/male/*.png` | Kits 54–57, 64–65 base male | BETTER_CANONICAL_REPLACEMENT (future — 8-dir + locomotion) |
| `assets/workchat_master_unique/*` | Various kits 1–93 | DUPLICATE / UNCLEAR — overlap with catalog entries |
| `assets/game/` (target) | Kits 1–93 deployed | CATALOG_ONLY — not extracted into project |

## Asset Kits Status

| Item | Status |
|------|--------|
| 12 source ZIP archives in `BRAMBLE_NEW/` | **UNTOUCHED** |
| `GAME_ASSET_CATALOG_V2` extracted to `_recovery/asset_catalog/` | Reference only |
| Bulk kit extraction into project | **NOT PERFORMED** (per recovery rules) |
| `assets/game/` in BRAMBLE_GAME | **MISSING** — future canonical library |

## Migration Strategy (documented, not executed)

**Phase 1 (current recovery):** Keep `catalog_legacy/` + `equipment/` + `animation_frames/` as active runtime paths. Do not delete.

**Phase 2 (future):** Deploy `assets/game/` from catalog + kits. Map:
```
catalog_legacy/png/{id} → assets/game/{category}/{canonical_id}
equipment/armor/{style}_* → assets/game/equipment/{style}/
animation_frames/ → assets/game/characters/{gender}/animations/
```

**Phase 3:** Update registries and loaders to prefer `assets/game/`. Maintain legacy aliases until all references migrated.

## Visual Masters

| File | Location | Classification |
|------|----------|----------------|
| gameplay_portrait.png | references/visual_master/ | VISUAL_MASTER_REFERENCE_ONLY |
| gameplay_landscape.png | references/visual_master/ | VISUAL_MASTER_REFERENCE_ONLY |
| inventory_portrait.png | references/visual_master/ | VISUAL_MASTER_REFERENCE_ONLY |
| hub_landscape.png | references/visual_master/ | VISUAL_MASTER_REFERENCE_ONLY |

Note: Files are JPEG data with `.png` extension. Excluded from Godot import via `references/.gdignore`.

## Runtime-Only Assets Not in Catalog

The `catalog_legacy/png/` set is a **curated runtime subset** — pre-cut sprites for the village demo. The catalog indexes **kit source sheets** (955 files), not these individual runtime cuts. Both coexist; mapping is many-to-one from kits → runtime cuts.
