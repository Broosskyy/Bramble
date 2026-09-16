# BRAMBLE — Godot 4.7.2 Complete Work-Chat Asset Project

This package corrects the earlier incomplete Godot test project.

## Included BRAMBLE asset sources

1. `BRAMBLE_ASSET_KIT_AUTUMN_HALLOWEEN_01.zip`
   - 102 PNG assets.
2. `BRAMBLE_ASSET_KIT_ENVIRONMENT_02.zip`
   - 58 PNG assets.
3. `BRAMBLE_10_Asset_Kits.zip`
   - 10 core production sheets plus character/NPC/specialist animation sheets, equipment and VFX.
4. Previously normalized BRAMBLE catalog from the V23.x workstream.
5. Godot-ready extracted V4 character/NPC/specialist animation frames.
6. Godot-ready extracted weapon and armor assets.
7. Portable gameplay/content JSON from the earlier migration package.

## Important folders

- `assets/source_kits/`
  Original ZIP sources, untouched.
- `assets/workchat_kits/autumn_halloween_01/`
  Full extracted Autumn/Halloween kit.
- `assets/workchat_kits/environment_02/`
  Full extracted Environment 02 kit.
- `assets/workchat_kits/kit10_v4/`
  Full extracted 10-kit/V4 source package.
- `assets/catalog_legacy/`
  Existing individually extracted BRAMBLE catalog used by V23.x.
- `assets/animation_frames/`
  Godot-ready frame extraction.
- `assets/equipment/`
  Extracted weapon/armor layers.
- `data/complete_asset_inventory.json`
  Machine-readable complete inventory.

## Inventory

Total PNG files physically present in the Godot package: **387**
Unique PNG file contents: **387**

Counts by source:
- autumn_halloween_01: 102
- environment_02: 58
- kit10_v4_raw: 31
- legacy_normalized_catalog: 84
- v4_animation_frames: 92
- v4_equipment_extracted: 20

Duplicated source/extracted files are intentional. Original source sheets are preserved alongside normalized/extracted production assets.

## Godot

Open `project.godot` with Godot 4.7.2.

This package is now the recommended BRAMBLE Godot asset baseline. Do not replace the original source kits; production scenes should reference the normalized/extracted assets where available.
