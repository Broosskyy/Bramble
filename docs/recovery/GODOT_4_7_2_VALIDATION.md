# Godot 4.7.2 Validation

**Engine:** `C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe`  
**Project:** `BRAMBLE_GAME/`  
**Date:** 2026-09-15

## project.godot

| Check | Result |
|-------|--------|
| Config version | Valid Godot 4 format |
| Main scene | `res://scenes/main.tscn` |
| Renderer | gl_compatibility (desktop + mobile) |
| Input actions | 16 actions defined |
| Autoloads | None |

## Import Pass

```
godot --headless --path BRAMBLE_GAME --import
```

**Result:** PASS with warnings

| Issue | Severity | Resolution |
|-------|----------|------------|
| Visual master PNGs fail import (JPEG with .png extension) | Warning | Added `references/.gdignore` |
| 587+ runtime PNGs imported successfully | OK | — |

Log: `docs/recovery/godot_import.log`

## Smoke Test

```
godot --headless --path BRAMBLE_GAME --quit-after 120
```

### Attempt 1 (pre-fix)
**Result:** FAIL

```
SCRIPT ERROR: Parse Error: The function signature doesn't match the parent.
  Parent signature is "_set(StringName, Variant) -> bool".
  at: player_lifecycle_service.gd:13
ERROR: Failed to load script "res://scripts/village_builder.gd"
```

Root cause: `player_lifecycle_service._set()` conflicted with Godot Object virtual.

### Attempt 2 (post-fix)
**Result:** PASS

```
BRAMBLE V11 domains: identity, session, character, world, combat, skills, ...
BRAMBLE V11 dedicated authority UDP 27840
BRAMBLE · Godot 4.7.2 · V11.8 SECURE TRADE / NPC SHOPS / ITEM UPGRADES
```

Exit code: 0  
Log: `docs/recovery/godot_smoke2.log`

## Script Compilation

| Area | Status |
|------|--------|
| 63 GDScript files | Compile after lifecycle fix |
| class_name declarations | 31 classes — no duplicate conflicts detected |
| Scene load_steps | 58 — all ext_resource paths resolve |

## Resource Paths Verified

| Path | On disk |
|------|---------|
| res://assets/catalog_legacy/png/terrain_meadow.png | YES |
| res://assets/equipment/armor/leather_torso.png | YES |
| res://assets/equipment/weapons/sword.png | YES |
| res://assets/catalog_legacy/png/monster_sprout.png | YES |
| res://assets/animation_frames/characters/male/00_idle_open.png | YES |
| res://assets/game/ | NO (expected — not deployed) |

## Runtime Verification Status

| Test | Status |
|------|--------|
| Project parse | PASS |
| Resource import | PASS (with visual master exclusion) |
| Main scene load | PASS |
| Headless 2s run | PASS |
| Visual rendering | NOT TESTED (headless) |
| Multiplayer session | NOT TESTED |
| Mobile touch | NOT TESTED |
| Full gameplay loop | NOT RUNTIME VERIFIED |

## Compatibility Fix Applied

**File:** `scripts/player_lifecycle_service.gd`  
**Change:** Renamed `_set()` → `_set_stage()` (6 call sites)  
**Reason:** Godot 4.7.2 requires Object._set(StringName, Variant) -> bool signature  
**Scope:** Minimal recovery fix — no behavioral change

## Deprecated API Scan

No obvious deprecated Godot 3.x API patterns found in scripts. Uses Godot 4 APIs:
- CharacterBody2D, Input.get_vector, @onready, signal syntax
- ENetMultiplayerPeer, OfflineMultiplayerPeer
- class_name pattern throughout

## UID / Cyclic Dependencies

No `.uid` sidecar files in source archives. Godot 4.7.2 generates UIDs on import. No cyclic dependency errors observed during smoke test.
