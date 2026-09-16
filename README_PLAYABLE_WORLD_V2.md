# BRAMBLE — Godot 4.7.2 Playable World V2

V2 turns the visual Hainweiler scene into a first actual gameplay slice.

## Playable now

- Player movement with collision.
- Animated character and equipment rig.
- Desktop controls plus visible mobile touch controls.
- Basic melee attack.
- Enemy AI with aggro, chase, attack, HP bars and death.
- Gold pickup drops.
- Player HP and respawn to Hainweiler.
- XP and level-up loop.
- Healing potion action.
- NPC interaction.
- Starter quest:
  1. Talk to Lina.
  2. Kill 3 Sprösslinge.
  3. Return to Lina.
  4. Receive XP + Gold.
- Portal/signpost interaction between village center and eastern field pocket.
- Asset Gallery remains available in-game.

## Controls

Desktop:
- WASD: move
- SPACE: attack
- E: interact
- R: potion

Mobile:
- D-pad: move
- ANGRIFF
- AKTION
- TRANK

## First run expectation

Open `project.godot` in Godot 4.7.2 and press Play.

You should spawn in Hainweiler, see the production-art village, move around, talk to Lina, walk to the eastern field, fight enemies and collect gold.

## Validation note

All referenced scripts/assets and `res://` scene paths were checked programmatically.
A Godot binary is not installed in the build environment, so the final engine runtime/import check must happen on first open in Godot 4.7.2.
