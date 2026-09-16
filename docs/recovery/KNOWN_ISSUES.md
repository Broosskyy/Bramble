# Known Issues — Post Recovery 01

## Critical (fixed in BRAMBLE_GAME)

| ID | Issue | Status |
|----|-------|--------|
| KI-001 | `player_lifecycle_service.gd` `_set()` conflicts with Godot Object API | **FIXED** → `_set_stage()` |

## High — Blocks full online authority

| ID | Issue | Impact |
|----|-------|--------|
| KI-002 | `combat_validation_service.gd` calls `registry.node_for_entity()` but `network_entity_registry.gd` lacks this method | Combat validation fallback only; has_method guard prevents crash |
| KI-003 | Client never sends skill intents (keys 1–4 bound but unused in player_controller) | Skills server-side only |
| KI-004 | No remote player avatar replication | Multiplayer shows local player + synced enemies only |
| KI-005 | `loot_authority.gd` not integrated into enemy death flow | Visual loot pickup only; no authoritative loot rolls |

## Medium — Dual/ incomplete wiring

| ID | Issue | Impact |
|----|-------|--------|
| KI-006 | Offline quest uses `game_state.gd`; online uses `quest_authority_service.gd` | Two quest systems |
| KI-007 | Offline NPC uses `game_state.talk_to_npc`; online uses `npc_interaction_service` | Two NPC paths |
| KI-008 | `party_manager.gd` + `shared_reward_service.gd` never called | Party system is stub |
| KI-009 | `world_collision.gd` is comment-only stub | Collision handled inline in village_builder |
| KI-010 | `persistence_provider.gd` is abstract no-op | Real persistence is local JSON/JSONL only |

## Medium — Asset paths

| ID | Issue | Impact |
|----|-------|--------|
| KI-011 | `equipment_registry_v4.json` references `assets/equipment_items/` but `equipment_rig.gd` loads `assets/equipment/` | Registry paths unused by runtime rig |
| KI-012 | `assets/game/` canonical library not deployed | Kits 1–93 remain in ZIP archives only |
| KI-013 | Visual master files are JPEG with `.png` extension | Cannot import as PNG; excluded via .gdignore |

## Low — Infrastructure

| ID | Issue | Impact |
|----|-------|--------|
| KI-014 | PostgreSQL migrations exist but no GDScript DB driver | Schema is contract-only |
| KI-015 | Relay adapter CLI flag logged but not implemented | `--relay=` has no effect |
| KI-016 | V10 README claims static QA only, not runtime-tested | Original packaging caveat |
| KI-017 | `project.godot` config/name was V10 string in V11 zip | Updated to "BRAMBLE GAME" in recovery |
| KI-018 | bootstrap.gd prints V11.8 banner, not V11.10 | Cosmetic version string lag |

## Not Issues (by design)

- Source of Mana not imported — intentional
- NosCore not integrated — reference only per spec
- Asset kit ZIPs not extracted — intentional (recovery rules)
- Visual masters not used as runtime sprites — intentional

## Validation Gate Gaps

- [ ] Full visual render test
- [ ] Multiplayer host/client session test
- [ ] Mobile device touch test
- [ ] PostgreSQL connection test
- [ ] End-to-end quest/combat/loot authority test
