# BRAMBLE — Godot 4.7.2 Playable World V1

This package is intended to be opened directly in Godot 4.7.2.

## What you should see immediately after pressing Play

A real BRAMBLE start area, **Hainweiler**, composed from the production assets:

- meadow/flower terrain
- cobblestone and field paths
- inn, smithy, guild hall, cottage and shrine
- fountain, notice board, well, cart, signpost, bench, crates, barrels and chest
- oak, birch, cherry, ancient tree and vegetation
- visible NPCs: blacksmith, merchant, guard, healer, bard and baker
- visible field monsters: sprout, hornhare, mushroom, hedgehog, beetle, wolf and boar
- animated player character
- visible weapon/armor equipment rig
- collisions around major buildings and tree trunks
- smoothed player camera

## Controls

- WASD / configured movement input: move
- SPACE: attack

## Asset Gallery

Use the **ASSET GALLERY** button at the top of the running game.
It opens a paged in-engine gallery sourced from `all_workchat_asset_inventory.json`.

That means the large Work-Chat asset pool is not merely sitting in folders: it is discoverable and previewable inside the running Godot project without trying to render hundreds of full-resolution assets into the main world at once.

## Important

The main world is a first authored Godot composition, not yet the complete final MMO map.
NPC interaction, enemy AI/combat, quests, portals and server-authoritative gameplay will be ported in subsequent milestones.

The browser prototype is no longer required to verify the production assets.

## QA

`data/playable_world_qa.json` records the current integration checks.
