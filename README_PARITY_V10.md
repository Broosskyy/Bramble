# BRAMBLE — Godot 4.7.2 PARITY V10

## What this build is
This is the migration line where **Web V23.28 is the gameplay/content specification** and Godot 4.7.2 becomes the runtime. It is not a reduced restart.

The package is rebuilt on top of the last complete Godot asset/gameplay archive available in the workspace (Playable World V2), while importing the exact V23.28 portable content and retaining the complete Work-chat asset pool. The V3–V9 parity architecture is consolidated here into the V10 services rather than pretending the stripped README-only V9 folder contains the full source.

## Exact Web data imported
`classes.json`, `skills.json`, `items.json`, `quests.json`, `enemies.json`, `maps.json`, `npcs.json`, `portals.json`, `input_actions.json`, `network_protocol.json`, `bramble_content_registry.json` are copied into `data/content/` and `portable_data/`.

## V10 Online Hardening
- ENet LAN/direct-IP session foundation
- server-authoritative movement intents
- server collision validation against authored world collisions
- dash validation
- authoritative basic/skill damage foundation derived from level, class main stat, equipped weapon, rarity and enhancement
- authoritative potion use
- taming and specialist-state validation foundation
- player authority state for stats, equipment, quests/counters, event/raid/instant progress, pets and specialists
- 10 Hz world snapshots
- client prediction reconciliation with replay of unacknowledged movement/dash inputs
- join-in-progress enemy snapshot create/update/remove foundation
- 900-unit party reward range / 5-member party model
- personal/shared/Need-Greed loot authority foundation
- 120-second reconnect grace model
- headless dedicated-server bootstrap
- relay adapter boundary without falsely bundling a public relay backend

## Preserved assets
The full Playable World V2 package is the base, including the all-Work-chat asset inventory, legacy normalized catalog, source archives, animation frames and equipment extraction foundation.

## Web reference
The V23.28 HTML prototype, migration/server source and V23.17–V23.28 documentation are retained under `web_reference_v23_28/` for parity checks.

## Important QA note
No Godot executable is installed in this build environment. The package has static reference/JSON QA, but is **not claimed runtime-tested**. Open it in Godot 4.7.2 and report the first parser/runtime error if one appears; the next pass should fix actual engine feedback rather than guessing.

## Next parity targets
The largest remaining gap is not the data import; it is presentation/runtime depth: full encounter/event UI, Web-equivalent combat stagger/projectiles/boss phases, specialist/pet visuals wired into authority, richer authored 8-map composition, admin/staff surfaces, production auth/persistence and a real Internet relay/backend.
