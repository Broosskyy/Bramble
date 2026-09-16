# M04.2 Asset Usage

Milestone: M04.2  
Audit date: 2026-09-16  
Source library: `assets/game/` and `assets/game/_catalog/`

No Visual Master image is used at runtime. Canonical source assets were not destructively edited; composition, scaling, tint and cropping occur in Godot.

## HUD

- FOUND: `ui/hud/primary_attack_button.png`, character direction sprites, quest and target panels, bar-capable UI material.
- USED: `characters/base/male/directions/front.png` for the player portrait; `ui/quests/quest_tracker_panel.png`; centralized Godot progress-bar styling.
- NOT USED + REASON: large ornamental HUD sheets were unsuitable for the compact responsive status cluster.
- FALLBACK: the full-body character direction sprite is scaled into the portrait treatment.
- TRULY MISSING: a dedicated cropped player portrait set.

## Navigation

- FOUND: pouch, character, quest-card and common button assets.
- USED: `items/misc/supply_pouch.png`, `characters/base/male/directions/front.png`, `items/misc/specialist_card.png`; shared selected/hover/pressed fantasy button treatment.
- NOT USED + REASON: unrelated combat and inventory icons were rejected for the social action.
- FALLBACK: a small diamond glyph labels Social because no semantic production icon exists.
- TRULY MISSING: a coherent four-icon navigation family, especially Social.

## Inventory and Item Presentation

- FOUND: item-slot/panel art and semantic item sprites for weapons, tunic, boots, potion, herb and ore.
- USED: `ui/touch/item_slot.png` treatment plus content-driven icons: short sword, longsword, cloth tunic, leather boots, health potion, herb bundle and copper ore. Selection, rarity border and quantity badge are composed in Godot.
- NOT USED + REASON: generic inventory-panel icons formerly assigned to consumables/materials did not represent the actual items.
- FALLBACK: `items/materials/wood_charm.png` represents the copper accessory; an atlas region from `characters/equipment/armor/armor_parts.png` represents gloves.
- TRULY MISSING: isolated ring and glove inventory icons matching the current item definitions.

## Equipment

- FOUND: `ui/equipment/equipment_panel.png`, weapon sprites, armor sprites and the base character.
- USED: equipment panel as a subdued slot board, semantic weapon/tunic icons, and the base character at controlled scale. Seven canonical logical slots remain visible.
- NOT USED + REASON: the full armor sprite sheet is not shown uncropped in a slot.
- FALLBACK: the cloth-tunic item icon represents leather vest until a dedicated icon exists.
- TRULY MISSING: a complete isolated icon family for head, armor, gloves, boots and both accessory slots.

## Character

- FOUND: base front-facing character sprite and RPG panel assets.
- USED: `characters/base/male/directions/front.png`, styled HP/MP/XP bars, primary and derived stat rows.
- NOT USED + REASON: no screenshot crop or precomposed Master character was used.
- FALLBACK: the gameplay character direction sprite doubles as the paper-doll/avatar source.
- TRULY MISSING: dedicated high-resolution character-sheet portrait/paper-doll renders.

## Skills and Combat

- FOUND: skill button normal/locked/cooldown states and melee VFX frames.
- USED: `ui/skills/skill_button.png`, `ui/skills/skill_locked.png`, `ui/skills/skill_cooldown.png`, `combat/vfx/melee_slash_sequence/frames/03_slash_peak.png`, and `04_impact_peak.png`.
- NOT USED + REASON: abstract text glyphs were replaced where semantic runtime art exists.
- FALLBACK: melee VFX keyframes serve as the first two ability icons.
- TRULY MISSING: a dedicated icon set for the full skill catalog, including sustain/buff/locked future skills.

## Target and Combat Feedback

- FOUND: target status panel, selection ring primitives, attack button and combat VFX.
- USED: compact target card with name, HP and range; gold world-space target ring; `ui/hud/primary_attack_button.png`.
- NOT USED + REASON: large dialogue/quest frames would obscure gameplay when used for a transient target.
- FALLBACK: target selection ring remains a Godot `Line2D`, which is clearer than an unrelated icon.
- TRULY MISSING: dedicated target portrait frames and enemy portrait crops.

## Minimap

- FOUND: minimap frame/background assets and current SubViewport map system.
- USED: existing production frame with improved contrast and marker hierarchy; current map architecture is preserved.
- NOT USED + REASON: no static map image or Master crop is used because the minimap must remain live.
- FALLBACK: current vector/player markers.
- TRULY MISSING: a richer coherent marker icon family for player, quest, party and combat targets.

## Level-Up

- FOUND: general fantasy panels, gold border language and existing runtime level-up event.
- USED: a centered compact Godot-composed card with gold border, level and reward text.
- NOT USED + REASON: no suitable dedicated level-up banner/VFX was found that fit both orientations without dominating gameplay.
- FALLBACK: centralized panel styling and typography.
- TRULY MISSING: dedicated level-up burst/banner and celebratory VFX/audio package.

## Asset Decision Summary

The pass favors semantic existing assets over decorative but misleading art. Remaining fallbacks are explicit and local. No new sprite sheet, copied Master fragment, or unrelated placeholder image was introduced.
