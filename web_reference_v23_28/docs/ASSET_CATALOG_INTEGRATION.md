# Asset Catalog Integration — V23.17

## Principle
Gameplay and maps refer to semantic IDs such as:
- `tree_oak_green`
- `terrain_flower_meadow`
- `building_smithy`
- `monster_hornhare`
- `hero_ranger`
- `spec_ember`

They do not depend on atlas coordinates.

## Map profiles
`map_visual_profiles.json` separates content assignment from rendering.
A later editor/admin system can change map visuals without rewriting combat code.

## Runtime use
The standalone HTML uses optimized embedded WebP assets. The source package retains
the transparent PNG catalog and all original uploaded ZIPs.

## New monster catalog mappings
The production monster kit is now used for sproutlings, hornhares, mushroomlings,
bramblehogs, beetles, wolves, moss turtles, fire spirits and boars.

## Character / NPC / specialist use
Playable class visuals, NPC profession visuals and specialist-card illustrations now
resolve through the same catalog rather than being hard-wired image fragments.
