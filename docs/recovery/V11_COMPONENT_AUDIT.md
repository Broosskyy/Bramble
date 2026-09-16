# V11.10 — Component Audit

**Source:** `_recovery/v11_10/BRAMBLE_GODOT_4_7_2_PARITY_V11_10_COMBAT_STATUS_ENEMY_AUTHORITY/`  
**Protocol:** `bramble-v11.10`  
**Relationship to V10:** Extension overlay — contains entire V10 tree plus 53 new files and 13 modifications.

## Package Type

| Question | Answer |
|----------|--------|
| Complete project? | **No** — lacks runtime PNG assets (same as V10 core) |
| Patch/overlay? | **Yes** — additive server-domain layer on V10 |
| Source delta? | **Yes** — 53 new files, 13 replaced files |
| Evolution of V10? | **Yes** — same main scene, extended service nodes |
| V10 files still needed? | **Yes** — 84 unchanged V10 files remain required; runtime assets still required |

## V11 New Services (53 files)

### Identity & Session
| Service | Path | Purpose | Status |
|---------|------|---------|--------|
| Domain registry | `scripts/domain_registry.gd` | Declares 18 gameplay domains | IMPLEMENTED |
| Identity service | `scripts/identity_service.gd` | Account/entity ID generation | IMPLEMENTED |
| Auth gateway | `scripts/auth_gateway.gd` | Guest/token auth gate | IMPLEMENTED |
| Session service | `scripts/session_service.gd` | Session open/resume/close, 120s grace | IMPLEMENTED |
| Player lifecycle | `scripts/player_lifecycle_service.gd` | connected→authenticated→world_joined stages | IMPLEMENTED (fixed `_set` conflict) |

### Character & Persistence
| Service | Path | Purpose | Status |
|---------|------|---------|--------|
| Character repository | `scripts/character_repository.gd` | Local JSON store `user://bramble_v11_characters.json` | IMPLEMENTED |
| Character service | `scripts/character_service.gd` | CRUD, max 4/account | IMPLEMENTED |
| Mobile character select | `scripts/mobile_character_select.gd` | Mobile lobby UI overlay | IMPLEMENTED |
| Persistence provider | `scripts/persistence_provider.gd` | Abstract adapter | STUB |
| Postgres contract | `scripts/postgres_repository_contract.gd` | Dedicated-server DB contract | CONTRACT ONLY |

### Economy & Items
| Service | Path | Purpose | Status |
|---------|------|---------|--------|
| Inventory service | `scripts/inventory_service.gd` | Server-owned inventory mutations | IMPLEMENTED |
| Equipment service | `scripts/equipment_service.gd` | Equip/unequip validation | IMPLEMENTED |
| Item instance service | `scripts/item_instance_service.gd` | Unique gear instances | IMPLEMENTED |
| Item upgrade service | `scripts/item_upgrade_service.gd` | Instance +level upgrades | IMPLEMENTED |
| Economy transaction | `scripts/economy_transaction_service.gd` | Atomic gold/item deltas | IMPLEMENTED |
| Reward transaction | `scripts/reward_transaction_service.gd` | Reward pipeline | IMPLEMENTED |
| Idempotency service | `scripts/idempotency_service.gd` | Transaction deduplication | IMPLEMENTED |
| Transaction audit | `scripts/transaction_audit_service.gd` | JSONL audit log | IMPLEMENTED |
| Outbox service | `scripts/outbox_service.gd` | Event outbox for replay | IMPLEMENTED |

### Shop & Trade
| Service | Path | Purpose | Status |
|---------|------|---------|--------|
| Shop catalog | `scripts/shop_catalog_service.gd` | Server shop from `shops.json` | IMPLEMENTED |
| Shop transaction | `scripts/shop_transaction_service.gd` | Buy/sell with server pricing | IMPLEMENTED |
| Trade session | `scripts/trade_session_service.gd` | Offer-lock-confirm sessions | IMPLEMENTED |
| Trade transaction | `scripts/trade_transaction_service.gd` | Atomic peer exchange | IMPLEMENTED |

### Gameplay Authority (V11.10 focus)
| Service | Path | Purpose | Status |
|---------|------|---------|--------|
| Combat validation | `scripts/combat_validation_service.gd` | Target/range validation | PARTIAL — expects `registry.node_for_entity()` |
| Skill authority | `scripts/skill_authority_service.gd` | CD, resource cost, unlock checks | IMPLEMENTED (server-side; client doesn't send skill intents) |
| Status effects | `scripts/status_effect_service.gd` | Buff/debuff tracking + expiry | IMPLEMENTED |
| Enemy authority | `scripts/enemy_authority_service.gd` | AI state machine metadata, attack cadence | IMPLEMENTED (AI still in enemy.gd) |
| Quest authority | `scripts/quest_authority_service.gd` | Content-driven quest progression | IMPLEMENTED (offline still uses game_state) |
| NPC interaction | `scripts/npc_interaction_service.gd` | Server NPC interact routing | IMPLEMENTED (client npc.gd uses game_state) |
| Progression | `scripts/progression_service.gd` | XP/level authority | IMPLEMENTED |

### PostgreSQL Migrations
| File | Purpose |
|------|---------|
| `server/postgres/001_bramble_v11_6_foundation.sql` | Foundation schema |
| `server/postgres/002_bramble_v11_7_instances_trade.sql` | Instances + trade |
| `server/postgres/003_bramble_v11_8_shop_trade_upgrade.sql` | Shop/trade/upgrade |
| `server/postgres/004_bramble_v11_9_gameplay_state.sql` | Gameplay state |

No GDScript PostgreSQL driver — SQL is contract/schema only.

### V11 Data Additions
- `data/content/shops.json`, `portable_data/shops.json`
- Manifest JSONs: V11_1 through V11_9, V11_NOSCORE_FOUNDATION
- README chain: V11_1 … V11_10, V11_NOSCORE_FOUNDATION

## V11 Modified Files (13)

| File | Change summary |
|------|----------------|
| `scenes/main.tscn` | +28 service nodes (58 load steps vs 30) |
| `scripts/bootstrap.gd` | V11 banner text |
| `scripts/network_session.gd` | Character RPCs, reconnect token, world join |
| `scripts/join_sync_service.gd` | Full auth→character→world pipeline |
| `scripts/server_authority.gd` | Routes through V11 validation services |
| `scripts/player_authority.gd` | Lifecycle gate, session persist |
| `scripts/loot_authority.gd` | Routes through reward_transaction_service |
| `scripts/enemy.gd` | Registers with enemy_authority_service |
| `data/content/items.json` | Extended item definitions |
| `data/content/network_protocol.json` | Protocol v11.10 |
| `portable_data/items.json` | Mirror update |
| `portable_data/network_protocol.json` | Mirror update |

## Authority Flow (V11)

```
Client intent → network_session.send_intent()
  → server_authority (host/dedicated)
    → combat_validation_service / skill_authority_service / enemy_authority_service
    → reward_transaction_service → economy + progression + audit
    → network_world_sync (replicate)
  → client presentation
```

## V11 Role Summary

V11.10 is the **authoritative server-domain layer** for a future MMORPG:
- Identity, session, character lifecycle
- Transaction-safe economy (inventory, equipment, shop, trade, upgrades)
- Combat/skill/enemy/status validation scaffolding
- PostgreSQL schema contracts

It **depends on V10** for client gameplay, world building, and runtime assets.
