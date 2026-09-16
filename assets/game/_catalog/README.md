# Game Asset Library (`assets/game`)

Canonical production asset library for the mobile MMORPG.

- **Created:** ASSET FOUNDATION 01 (2026-09-15)
- **Source:** BRAMBLE kits 1–93 from `_asset_import/` (unchanged raw archive)
- **Work area:** `_asset_work/` (extraction staging, safe to delete after verification)

## Structure

- `characters/` — player bases, animations, equipment, specialists
- `monsters/` — monster directions and action assets
- `npcs/` — NPC directional and animation assets
- `world/` — terrain, buildings, props, portals, dungeons
- `items/` — loot, materials, quest items
- `combat/` — skills, VFX, projectiles
- `ui/` — HUD, touch controls, menus
- `references/` — source sheets, masters, concepts (not direct production sprites)
- `_catalog/` — manifests, mappings, audits

## Rules

1. Do not reference BRAMBLE kit paths in game code — use canonical paths only.
2. Full provenance is in `_catalog/SOURCE_MAPPING.csv`.
3. Source sheets must be sliced before use as individual sprites.

See `_catalog/ASSET_CATALOG.md` for full inventory.

## Visual Master References (project root)

Binding presentation targets live at `references/visual_master/` (**not** under `assets/game/`):

- `gameplay_landscape.png`, `gameplay_portrait.png`
- `inventory_portrait.png`, `hub_landscape.png`

Status: `VISUAL_MASTER_REFERENCE_ONLY` — do not use as in-game textures.

See `_catalog/VISUAL_MASTER_READINESS.md` for readiness vs production assets.
