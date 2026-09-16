# V10.3R CORE — Component Audit

**Source:** `_recovery/v10_core/BRAMBLE_GODOT_4_7_2_PARITY_V10_3R/`  
**Godot version:** 4.7.2 (declared in README/data)  
**Main scene:** `res://scenes/main.tscn`  
**Autoloads:** None — all services wired as scene-tree nodes in `main.tscn`

## V10_COMPONENTS

| component | path | purpose | dependencies | runtime_status | asset_dependencies | notes |
|-----------|------|---------|--------------|----------------|-------------------|-------|
| Project config | `project.godot` | Engine config, input map, GL compatibility renderer | — | VALID | — | No autoload section |
| Bootstrap | `scripts/bootstrap.gd` | Startup banner | — | WORKING | — | V10 prints V10 banner |
| Main scene | `scenes/main.tscn` | Root scene: world + all services | All service scripts | WORKING | Runtime assets required | 30 load steps in V10 |
| Game state | `scripts/game_state.gd` | Offline HP/XP/level/quest/potion | — | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | Hardcoded Lina quest |
| Content DB | `scripts/content_db.gd` | JSON content loader (classes, skills, items) | `data/content/*`, `portable_data/*` | WORKING | — | `class_name BrambleContentDB` |
| Web parity state | `scripts/web_parity_state.gd` | Join seed / web migration state | `data/online_runtime_v10.json` | PARTIAL | — | Used by join sync |
| Player controller | `scripts/player_controller.gd` | Movement, dash, attack, interact | Input map, network_session | IMPLEMENTED_NOT_RUNTIME_VERIFIED | animation_frames, equipment | Sends move/dash intents online |
| Player visual | `scripts/player_visual.gd` | AnimatedSprite2D pose playback | `asset_registry.gd`, `animation_registry_v4.json` | IMPLEMENTED_NOT_RUNTIME_VERIFIED | `assets/animation_frames/` | Registry-driven |
| Equipment rig | `scripts/equipment_rig.gd` | Layered armor/weapon sprites | `equipment_registry_v4.json` | IMPLEMENTED_NOT_RUNTIME_VERIFIED | `assets/equipment/` | Path mismatch vs registry JSON |
| Village builder | `scripts/village_builder.gd` | Procedural village: terrain, buildings, NPCs, enemies, portals, collision | `catalog_legacy/png/*` | IMPLEMENTED_NOT_RUNTIME_VERIFIED | catalog_legacy | Core world content |
| World collision | `scripts/world_collision.gd` | Collision helper | — | MISSING | — | Comment-only stub |
| Server collision validator | `scripts/server_collision_validator.gd` | Server-side move/dash validation | Physics layers | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | Layer 4 = world solids |
| Enemy | `scripts/enemy.gd` | AI: aggro, chase, attack, death, loot spawn | game_state, loot_pickup | IMPLEMENTED_NOT_RUNTIME_VERIFIED | catalog_legacy/png | 9 enemies east of village |
| NPC | `scripts/npc.gd` | Interactable NPCs | game_state | IMPLEMENTED_NOT_RUNTIME_VERIFIED | catalog_legacy/png | 6 NPCs in village |
| Portal | `scripts/portal.gd` | Map teleport | player group | IMPLEMENTED_NOT_RUNTIME_VERIFIED | catalog_legacy/png | Village ↔ eastern fields |
| Loot pickup | `scripts/loot_pickup.gd` | Visual gold pickup on enemy death | game_state | IMPLEMENTED_NOT_RUNTIME_VERIFIED | catalog_legacy/png | Not using loot_authority |
| Party manager | `scripts/party_manager.gd` | Party data structure | — | PARTIAL | — | Not wired to gameplay |
| Dev HUD | `scripts/dev_hud.gd` | HUD + mobile touch controls | Input actions | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | D-pad + action buttons |
| Authority status UI | `scripts/authority_status_ui.gd` | Online authority debug overlay | network services | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | |
| Network session | `scripts/network_session.gd` | ENet host/client/offline, intents | ENetMultiplayerPeer | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | Port 27840 |
| Player authority | `scripts/player_authority.gd` | Server-owned player state | network_session | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | Move/dash/position/respawn |
| Server authority | `scripts/server_authority.gd` | Intent router: combat, skills, potion | All authority services | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | |
| Authoritative combat | `scripts/authoritative_combat.gd` | Damage formulas | content_db | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | |
| Network entity registry | `scripts/network_entity_registry.gd` | Enemy ID ↔ node mapping | enemy nodes | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | No `node_for_entity` method |
| Network world sync | `scripts/network_world_sync.gd` | 10Hz enemy snapshots | entity registry | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | No remote player avatars |
| Prediction reconciliation | `scripts/prediction_reconciliation.gd` | Client prediction + correction | network_session | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | |
| Join sync service | `scripts/join_sync_service.gd` | World join handshake | web_parity_state | PARTIAL | — | Basic V10 seed |
| Server bootstrap | `scripts/server_bootstrap.gd` | Headless `--bramble-server` auto-host | network_session | IMPLEMENTED_NOT_RUNTIME_VERIFIED | — | |
| Loot authority | `scripts/loot_authority.gd` | Personal/shared/need-greed loot rules | — | PARTIAL | — | Not called from enemy death |
| Online action authority | `scripts/online_action_authority.gd` | Tame/specialist actions | — | PARTIAL | — | |
| Shared reward service | `scripts/shared_reward_service.gd` | Proximity XP multiplier | party_manager | PARTIAL | — | Never called |
| Asset registry | `scripts/asset_registry.gd` | Animation frame path resolver | animation_registry_v4.json | WORKING | animation_frames | |
| Complete asset library | `scripts/complete_asset_library.gd` | Full asset inventory browser | complete_asset_inventory.json | PARTIAL | workchat_master_unique | Dev tool |
| Workchat asset library | `scripts/workchat_asset_library.gd` | Work-chat asset pool | all_workchat_asset_inventory.json | PARTIAL | workchat_master_unique | |
| Asset inventory check | `scripts/asset_inventory_check.gd` | Asset validation utility | — | PARTIAL | — | |
| Data: content | `data/content/*.json` | Classes, enemies, items, maps, NPCs, quests, skills | — | WORKING | — | |
| Data: portable | `portable_data/*.json` | Portable content mirror | — | WORKING | — | |
| Data: registries | `data/*_registry_v4.json` | Animation/equipment registries | — | WORKING | Runtime assets | |
| Data: QA manifests | `data/PARITY_V10*.json` | Static QA metadata | — | REFERENCE | — | Not runtime-tested per README |
| Assets (core) | `assets/README_INSTALL_RUNTIME_ASSETS.md` | Install instructions only | RUNTIME zip | MISSING in core | — | Core ships without PNGs |
| Web reference | `web_reference_v23_28/` | Web parity migration reference | — | REFERENCE | — | |

## Asset Path Dependencies (V10 Core Code)

| Path pattern | Used by |
|--------------|---------|
| `res://assets/catalog_legacy/png/{id}.png` | village_builder, enemy, npc, portal, loot_pickup |
| `res://assets/equipment/armor/{style}_*.png` | equipment_rig |
| `res://assets/equipment/weapons/{id}.png` | equipment_rig |
| `res://assets/animation_frames/characters/{gender}/*.png` | asset_registry ← animation_registry_v4.json |

All PNG paths fulfilled by V10.3R RUNTIME ASSETS package (not by core alone).

## V10 Role Summary

V10.3R CORE is a **complete playable Godot project skeleton** with:
- Full village demo (movement, combat, quest, NPCs, portals)
- ENet multiplayer foundation with server authority routing
- Mobile touch HUD
- Content/data layer

It is **incomplete without RUNTIME ASSETS** and **superseded in authority/economy by V11 overlay**.
