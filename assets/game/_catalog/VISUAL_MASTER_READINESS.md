# Visual Master Readiness

Generated: 2026-09-15T19:25:39.233318+00:00

## 1. Visual Master Files (REFERENCE ONLY)

Location: `references/visual_master/` (project root — **not** `assets/game/`)

| File | Role | Status |
|---|---|---|
| `gameplay_landscape.png` | Primary landscape gameplay visual master | VISUAL_MASTER_REFERENCE_ONLY |
| `gameplay_portrait.png` | Primary portrait gameplay visual master | VISUAL_MASTER_REFERENCE_ONLY |
| `inventory_portrait.png` | Complex mobile menu / inventory visual master | VISUAL_MASTER_REFERENCE_ONLY |
| `hub_landscape.png` | Long-term social/town/hub visual master | VISUAL_MASTER_REFERENCE_ONLY |
| `README.md` | Usage constraints | VISUAL_MASTER_REFERENCE_ONLY |

**Do not** crop, modify, or use these PNGs as in-game textures.

Technical world presentation reference: `assets/game/references/WORLD_CAMERA_SPEC.md`
(~38° oblique orthographic, h0/h1/h2, footpoints, fixed view preferred).

## 2. Portrait Gameplay Readiness

**Status: PARTIAL**

- Visual master present and extracted
- Production HUD + touch controls available (`ui/hud/`, `ui/touch/`)
- Player + monster readable at target scale (needs in-engine framing)
- Missing: authored portrait camera bounds, safe-area layout, assembled scene

## 3. Landscape Gameplay Readiness

**Status: PARTIAL**

- World tiles, buildings, elevation, combat VFX, HUD components present
- Matches oblique 2.5D direction per WORLD_CAMERA_SPEC
- Missing: camera implementation, depth sort rules, target frame composition

## 4. Inventory / Menu Readiness

**Status: PARTIAL**

- Panel assets: inventory, equipment, character, item detail (kits 76, 26, 63)
- Needs layout composition, tab flow, portrait density tuning vs `inventory_portrait.png`

## 5. Hub / Town Readiness

**Status: PARTIAL**

- Village buildings, props, NPC directions, portals available
- No dedicated multi-player hub scene; social UI partial (chat bar, raid panels)
- `hub_landscape.png` is long-term target, not PLAYABLE 01 scope

## 6. Player Asset Candidates

- `characters/base/male/directions/front.png` — VISUAL_MASTER_READY
- `characters/base/male/animations/walk/walk_a.png` — VISUAL_MASTER_ADJUST
- `characters/base/male/animations/run/run_a.png` — VISUAL_MASTER_ADJUST
- `characters/animations/male/attack_melee/02_male_swing.png` — VISUAL_MASTER_ADJUST
- `characters/base/male/animations/hit.png` — VISUAL_MASTER_ADJUST
- `characters/base/male/animations/defeated.png` — VISUAL_MASTER_ADJUST

## 7. Monster Asset Candidates

- `monsters/moorling/directions/kit60_front.png` — VISUAL_MASTER_ADJUST
- `monsters/moorling/actions/idle.png` — VISUAL_MASTER_ADJUST
- `monsters/moorling/actions/attack.png` — VISUAL_MASTER_ADJUST
- `monsters/moorling/actions/hit.png` — VISUAL_MASTER_ADJUST
- `monsters/moorling/actions/defeated.png` — VISUAL_MASTER_ADJUST
- **Gap:** monster walk/run directional movement — `VISUAL_MASTER_INCOMPLETE`

## 8. NPC Asset Candidates

- `npcs/merchant/directions/front.png` — VISUAL_MASTER_READY
- `npcs/blacksmith/directions/front.png` — VISUAL_MASTER_READY

## 9. World Asset Candidates

- `world/terrain/seamless/meadow.png` — VISUAL_MASTER_READY
- `world/roads/road_cobble.png` — VISUAL_MASTER_READY
- `world/roads/riverbank_straight.png` — VISUAL_MASTER_READY
- `world/roads/wooden_footbridge.png` — VISUAL_MASTER_READY
- `world/buildings/red_oak.png` — VISUAL_MASTER_READY
- `world/buildings/cottage.png` — VISUAL_MASTER_READY
- `world/buildings/inn.png` — VISUAL_MASTER_READY
- `world/portals/portal_arch_active.png` — VISUAL_MASTER_READY
- `world/elevation/ramp.png` — VISUAL_MASTER_ADJUST
- `world/elevation/staircase.png` — VISUAL_MASTER_ADJUST
- **Gap:** vegetation mostly in source sheets (kit 03, 11) — slice before use

## 10. Combat / VFX Candidates

- `combat/vfx/melee_slash_sequence/frames/03_slash_peak.png` — VISUAL_MASTER_READY
- `combat/vfx/magic_support/frames/07_violet_impact.png` — VISUAL_MASTER_READY
- `combat/projectiles/06_arrow_hit.png` — VISUAL_MASTER_READY

## 11. UI Candidates

- `ui/hud/player_status_panel.png` — VISUAL_MASTER_READY
- `ui/target/target_bar.png` — VISUAL_MASTER_ADJUST
- `ui/hud/primary_attack_button.png` — VISUAL_MASTER_READY
- `ui/skills/skill_button.png` — VISUAL_MASTER_ADJUST
- `ui/hud/kit62_virtual_joystick.png` — VISUAL_MASTER_ADJUST
- `ui/map/minimap_frame.png` — VISUAL_MASTER_ADJUST
- `ui/quests/quest_panel.png` — VISUAL_MASTER_ADJUST
- `ui/inventory/kit76_inventory_panel.png` — VISUAL_MASTER_ADJUST
- `ui/equipment/equipment_panel.png` — VISUAL_MASTER_ADJUST

## 12. Visual Inconsistencies

- Player locomotion frames are not direction-bound; visual masters show direction-specific gameplay
- Kit 21 was falsely labeled as Moorling: its four extracted children are world vegetation, now under `world/vegetation/`
- Eight source records use false semantic names for exact copies of kits 11–18; corrected aliases are recorded in `SEMANTIC_OVERRIDES.json`
- Vegetation/props from early kits remain SOURCE_SHEET except the four verified kit-21 extractions
- Hub master implies higher NPC/player density than current single-sprite exports

## 13. Missing Asset Families (vs Visual Masters)

- Monster directional walk/run cycles
- Authored portrait/landscape HUD layout presets (presentation only)
- Social hub crowd variants / emotes
- Chat bubble / party frame assembly from existing partial UI
- Roof/tree transparency variants for occlusion (spec'd, not exported as separate assets)

## 14. PLAYABLE 01 Recommendation

Use **male** base player, **moorling** monster, **merchant** NPC, village slice:

```
Player:     characters/base/male/directions/front.png
            characters/base/male/animations/walk/walk_a.png
            characters/animations/male/attack_melee/02_male_swing.png
Monster:    monsters/moorling/directions/kit60_front.png
            monsters/moorling/actions/attack.png
NPC:        npcs/merchant/directions/front.png
Building:   world/buildings/cottage.png
Terrain:    world/terrain/seamless/meadow.png
Road:       world/roads/road_cobble.png
Vegetation: world/buildings/red_oak.png
Elevation:  world/elevation/ramp.png
Portal:     world/portals/portal_arch_active.png
VFX:        combat/vfx/melee_slash_sequence/frames/03_slash_peak.png
HUD:        ui/hud/player_status_panel.png
            ui/target/target_bar.png
            ui/hud/primary_attack_button.png
            ui/hud/kit62_virtual_joystick.png
            ui/map/minimap_frame.png
```

Compare all framing against:
- `references/visual_master/gameplay_landscape.png`
- `references/visual_master/gameplay_portrait.png`
