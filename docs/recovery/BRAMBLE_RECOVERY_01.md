# BRAMBLE RECOVERY 01

**Date:** 2026-09-15  
**Target:** Godot 4.7.2 canonical project recovery  
**Workspace:** `BRAMBLE_NEW/`  
**Canonical project:** `BRAMBLE_GAME/`

## Objective

Establish one auditable, maintainable Godot 4.7.2 project from existing BRAMBLE archives — without blind merges, without Source of Mana dependency, without regenerating assets.

## Source Archives (READ-ONLY)

All original ZIPs in `BRAMBLE_NEW/` remain untouched.

| Archive | Role |
|---------|------|
| `BRAMBLE_GODOT_4_7_2_PARITY_V10_3R_CORE.zip` | Project core: scripts, scenes, data |
| `BRAMBLE_GODOT_4_7_2_PARITY_V10_3R_RUNTIME_ASSETS.zip` | Runtime PNG/catalog assets |
| `BRAMBLE_GODOT_4_7_2_PARITY_V11_10_COMBAT_STATUS_ENEMY_AUTHORITY.zip` | V11 overlay (superset of V10) |
| `BRAMBLE_*` asset kit ZIPs (12) | Raw kits 1–93 (not extracted into project) |
| `GAME_ASSET_CATALOG_V2.zip` | Inventory/catalog metadata |
| `BRAMBLE_VISUAL_MASTERS.zip` | Visual target references only |

## Recovery Directories

```
BRAMBLE_NEW/
  _recovery/          # extracted audit copies (not canonical)
    v10_core/
    v10_runtime/
    v11_10/
    asset_catalog/
    visual_masters/
  BRAMBLE_GAME/       # CANONICAL MASTER (created in this recovery)
  *.zip               # untouched originals
```

## Architecture Decision

**Foundation = V10.3R CORE + V10.3R RUNTIME ASSETS + V11.10 compatible extensions**

Rationale:
- V11.10 ZIP is a **superset** of V10.3R CORE (97 shared paths, 0 V10-only, 53 V11-only, 13 modified).
- V11 is **not** a standalone replacement for runtime assets — it contains no PNG binaries.
- V10/V11 share the same main scene, input map, and client gameplay loop.
- V11 adds server-domain services (identity, session, character, economy, combat validation, enemy authority, status effects, PostgreSQL contracts).

## Consolidation Performed

1. Copied V11.10 project tree → `BRAMBLE_GAME/`
2. Merged V10.3R runtime assets → `BRAMBLE_GAME/assets/`
3. Extracted visual masters → `BRAMBLE_GAME/references/visual_master/` (with `.gdignore` — not imported by Godot)
4. Applied minimal Godot 4.7.2 compatibility fix: `player_lifecycle_service.gd` renamed internal `_set()` → `_set_stage()` (conflicted with `Object._set`)
5. Updated `project.godot` display name to `BRAMBLE GAME`

## What Was NOT Done

- Asset kits 1–93 not bulk-extracted into project
- No `assets/game/` canonical library deployment yet
- No Source of Mana code imported
- No NosCore protocol integration
- No gameplay rewrites
- No runtime asset deletion

## Validation Gate

| Check | Status |
|-------|--------|
| project.godot present | PASS |
| Main scene present | PASS |
| Autoload paths valid | PASS (scene-tree services, no autoload entries) |
| Scripts referencable | PASS (after lifecycle fix) |
| Runtime assets present | PASS (591 PNG + catalog JSON) |
| Obvious missing deps | PARTIAL (see KNOWN_ISSUES) |
| V11 merge traceable | PASS |
| assets/game preserved | N/A — not yet present |
| Visual masters present | PASS |
| Asset kits untouched | PASS |
| Main scene parseable | PASS |
| Godot start attempted | PASS (headless smoke, 2s) |
| Errors documented | PASS |

## Documents

- `V10_COMPONENT_AUDIT.md`
- `V11_COMPONENT_AUDIT.md`
- `V10_V11_DIFF.md`
- `RUNTIME_ASSET_MAPPING.md`
- `ARCHITECTURE_CURRENT.md`
- `GODOT_4_7_2_VALIDATION.md`
- `KNOWN_ISSUES.md`

## Foundation Question

**Can BRAMBLE V10/V11 serve as our primary Godot MMORPG foundation instead of Source of Mana?**

**Answer: YES_WITH_FIXES**

See final report section H for reasoning.
