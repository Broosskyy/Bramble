# BRAMBLE — Godot 4.7.2 — ALL WORK-CHAT ASSETS

This expands the previous complete asset project and additionally scans the recoverable BRAMBLE source/full-source archives from the work-chat lineage.

## Result

- **391 unique PNG/WebP image assets** collected and deduplicated by SHA-1.
- Existing structured V4 animation/equipment folders remain.
- Autumn/Halloween, Environment 02, ten-kit/V4 and legacy normalized catalog remain.
- Loose production assets (`base_male_unarmed_8f.png`, `base_female_unarmed_8f.png`, `armor_parts.png`, `weapons_separate.png`) are explicitly preserved.
- `assets/workchat_master_unique/` is a deduplicated master pool.
- `data/all_workchat_asset_inventory.json` records provenance for every image and every archive occurrence.

### Categories
- buildings: 24
- characters: 27
- equipment: 42
- infrastructure: 1
- misc: 24
- monsters: 10
- npcs: 41
- resources: 2
- seasonal: 63
- specialists: 38
- terrain: 30
- terrain_paths: 8
- terrain_water: 1
- vegetation: 41
- vfx: 2
- world_props: 37

### Important
The deduplicated master pool is for discovery/audit. Existing normalized folders should continue to be used by scenes where already mapped, so references remain stable.
