# V10 ↔ V11 Differential Audit

**Comparison method:** MD5 hash of all relative paths in extracted trees.

## Summary Counts

| Classification | Count |
|----------------|-------|
| UNCHANGED | 84 |
| V11_REPLACES_V10 | 13 |
| V11_NEW | 53 |
| V10-only | 0 |
| CONFLICT | 0 (hash-based; semantic conflicts exist — see below) |

## Classification: UNCHANGED (84 files)

All shared files with identical hash. Includes:
- All V10 gameplay scripts not listed below (player_controller, village_builder base logic, game_state, dev_hud, etc.)
- All V10 data except items.json and network_protocol.json
- All V10 README files
- `web_reference_v23_28/`

## Classification: V11_REPLACES_V10 (13 files)

| File | Notes |
|------|-------|
| `scenes/main.tscn` | V11_EXTENDS_V10 — adds 28 service nodes; same world/player/HUD structure |
| `scripts/bootstrap.gd` | Banner text only |
| `scripts/network_session.gd` | V11_EXTENDS_V10 — character RPCs, reconnect |
| `scripts/join_sync_service.gd` | V11_REPLACES_V10 — full join pipeline |
| `scripts/server_authority.gd` | V11_EXTENDS_V10 — routes to V11 services |
| `scripts/player_authority.gd` | V11_EXTENDS_V10 — lifecycle integration |
| `scripts/loot_authority.gd` | V11_EXTENDS_V10 — reward pipeline |
| `scripts/enemy.gd` | V11_EXTENDS_V10 — enemy_authority registration |
| `data/content/items.json` | V11_EXTENDS_V10 — more items |
| `data/content/network_protocol.json` | V11_REPLACES_V10 — protocol v11.10 |
| `portable_data/items.json` | V11_EXTENDS_V10 |
| `portable_data/network_protocol.json` | V11_REPLACES_V10 |

## Classification: V11_NEW (53 files)

See `V11_COMPONENT_AUDIT.md` for full list.

Categories:
- 11 README files (V11_1 … V11_10, NOSCORE)
- 6 manifest JSON files
- 2 shops.json (content + portable)
- 30 new GDScript services
- 4 PostgreSQL migration SQL files

## Classification: V11_DEPENDS_ON_V10

The entire V11 package depends on:
- V10 client gameplay scripts (unchanged)
- V10 village_builder world layout
- V10 runtime assets (catalog_legacy, equipment, animation_frames)
- V10 content JSON (classes, enemies, maps, quests, skills — except items/protocol deltas)

## Semantic CONFLICTS (not hash conflicts)

| Area | Issue | Classification |
|------|-------|----------------|
| Equipment paths | `equipment_rig.gd` loads `assets/equipment/` but `equipment_registry_v4.json` references `assets/equipment_items/` | CONFLICT — pre-existing V10 |
| Entity registry API | `combat_validation_service.gd` calls `registry.node_for_entity()` but `network_entity_registry.gd` lacks this method | CONFLICT — V11.10 |
| Quest flow | Offline `game_state.gd` quest vs `quest_authority_service.gd` | CONFLICT — dual paths |
| Loot on kill | `enemy.gd` spawns visual pickup; `loot_authority.gd` unused in kill flow | CONFLICT — incomplete wiring |
| Skills | Input actions exist; client never sends skill intents | PARTIAL |
| Party | `party_manager.gd` + `shared_reward_service.gd` exist but uncalled | OBSOLETE wiring |
| Player lifecycle | `_set()` method name conflicted with Godot Object API | CONFLICT — fixed in BRAMBLE_GAME |

## Classification: OBSOLETE

| Item | Notes |
|------|-------|
| `scripts/world_collision.gd` | Comment-only stub in both V10 and V11 |
| `scripts/persistence_provider.gd` | Abstract no-op in V11 |
| Relay adapter flag in server_bootstrap | Logged only, no implementation |

## Merge Strategy Applied

**Not "newest wins" blindly.**

1. Base = V11 tree (superset, includes all unchanged V10)
2. Runtime assets merged from V10.3R RUNTIME (required by both)
3. No V10-only files existed that V11 removed
4. Minimal compatibility fix applied post-merge

## Autoload Comparison

Neither V10 nor V11 use `[autoload]` entries. All services are scene-tree nodes in `main.tscn`.

V11 adds these node groups vs V10:
- identity_service, session_service, character_service, character_repository
- domain_registry, auth_gateway, player_lifecycle_service
- inventory_service, equipment_service, item_instance_service, progression_service
- persistence_provider, postgres_repository_contract
- economy/reward/idempotency/audit/outbox services
- shop/trade/upgrade services
- combat_validation, skill_authority, status_effect, enemy_authority
- quest_authority, npc_interaction
- mobile_character_select (UI overlay)
