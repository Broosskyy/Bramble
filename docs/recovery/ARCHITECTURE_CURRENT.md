# BRAMBLE Architecture — Current State

**Project:** `BRAMBLE_GAME/`  
**Engine:** Godot 4.7.2  
**Main scene:** `res://scenes/main.tscn`  
**Service model:** Scene-tree nodes with groups (no autoloads)

---

## CLIENT

### Main Scene
Single `Node2D` root (`bootstrap.gd`) containing all services as child nodes plus world/player/HUD. V11 adds 28 server-domain service nodes.

### Player
- `CharacterBody2D` at (0, 360) with capsule collision (layer 1, mask 2|4)
- `player_controller.gd` — WASD/touch movement, dash, attack, interact, potion
- `player_visual.gd` — AnimatedSprite2D with registry-driven poses
- `equipment_rig.gd` — layered armor/weapon sprites (starter: leather + sword)

### World
- `village_builder.gd` builds procedural 2.5D village on `_ready()`
- Layers: Ground, Roads, WorldObjects (y-sort), NPCs, Monsters, Portals, Collisions
- StaticBody2D collision on layer 4 for buildings/trees
- Eastern field zone with 9 enemies

### Camera
- `Camera2D` child of Player
- Smoothing enabled (speed 7.0)
- Limits: ±1500 horizontal, ±1100 vertical
- Fixed oblique follow — no portrait/landscape switching yet

### Input
- Keyboard: WASD move, Space attack, E interact, R potion, Shift dash, 1–4 skills, Q target, T tame, F specialist
- Defined in `project.godot` `[input]` section

### Mobile Controls
- Touch D-pad (HUD/Touch/Dpad/*) bound to input actions via `dev_hud.gd`
- Action buttons: Attack, Interact, Potion
- V11: `mobile_character_select.gd` overlay for character lobby

### UI
- `dev_hud.gd` — HP/XP bars, quest text, network mode, touch controls
- `authority_status_ui.gd` — authority debug overlay
- `mobile_character_select.gd` — character create/select/delete UI

---

## GAMEPLAY

| System | Implementation | Online authority | Status |
|--------|---------------|------------------|--------|
| Movement | player_controller + CharacterBody2D | player_authority + collision validator | WORKING offline; IMPLEMENTED_NOT_RUNTIME_VERIFIED online |
| Combat | player_controller basic_attack + enemy AI | server_authority → combat_validation | WORKING offline |
| Skills | server_authority._skill | skill_authority_service | PARTIAL — no client skill intents |
| Enemies | enemy.gd AI + enemy_authority_service metadata | Host runs AI; clients receive snapshots | IMPLEMENTED_NOT_RUNTIME_VERIFIED |
| HP/Death | game_state (offline), player_authority (online) | Server-owned | WORKING offline |
| Loot | loot_pickup visual on death | loot_authority exists, not in kill flow | PARTIAL |
| XP/Level | game_state.add_xp | progression_service (V11) | WORKING offline |
| Inventory | — | inventory_service (V11) | IMPLEMENTED server-side only |
| Equipment | equipment_rig visuals | equipment_service (V11) | Visual WORKING; server PARTIAL |
| NPC | npc.gd → game_state.talk_to_npc | npc_interaction_service (V11) | WORKING offline |
| Quest | game_state hardcoded Lina quest | quest_authority_service (V11) | WORKING offline |
| Portal | portal.gd teleport | — | WORKING |
| Party | party_manager data only | — | PARTIAL stub |
| Shop/Trade | — | shop/trade services (V11) | IMPLEMENTED server-side only |
| Potion | game_state.use_potion | server_authority intent | WORKING offline |

---

## NETWORK

```
┌─────────────┐    ENet intents     ┌──────────────────┐
│   Client    │ ──────────────────→ │  Host / Dedicated │
│ player_ctrl │ ←── snapshots/RPC ─ │ server_authority  │
└─────────────┘                     └──────────────────┘
```

| Component | File | Role |
|-----------|------|------|
| Session | network_session.gd | ENet host/client/offline, port 27840 |
| Entity registry | network_entity_registry.gd | Enemy ID mapping |
| World sync | network_world_sync.gd | 10Hz enemy snapshots |
| Prediction | prediction_reconciliation.gd | Input buffer + correction |
| Join sync | join_sync_service.gd | Auth → character → world join |
| Server bootstrap | server_bootstrap.gd | `--bramble-server` headless host |

**Not implemented:** remote player avatars, relay adapter, reconnect full test.

---

## AUTHORITY

Principle: **Client sends intent → authority validates → state changes → replicate → client presents.**

| Domain | V10 | V11 addition | Wired end-to-end? |
|--------|-----|--------------|-------------------|
| Player movement | player_authority | lifecycle gate | Partial |
| Combat | server_authority + authoritative_combat | combat_validation_service | Partial |
| Skills | server_authority._skill | skill_authority_service | No client wiring |
| Enemy | Local AI on host | enemy_authority_service | Partial |
| Status effects | — | status_effect_service | Server only |
| Loot | loot_authority | reward_transaction_service | Not in kill flow |
| Quest | game_state (offline) | quest_authority_service | Dual path |
| Economy | — | Full transaction pipeline | Server only |

---

## PERSISTENCE

| Layer | Implementation | Storage |
|-------|---------------|---------|
| Characters | character_service + character_repository | `user://bramble_v11_characters.json` |
| Sessions | session_service | In-memory + reconnect tokens |
| Inventory/Equipment | inventory/equipment services | In-memory (server host) |
| Audit | transaction_audit_service | `user://` JSONL |
| Outbox | outbox_service | `user://` JSONL |
| PostgreSQL | 4 SQL migrations + contract GDScript | **No runtime DB connection** |

---

## CONTENT

| Source | Path | Contents |
|--------|------|----------|
| Content DB | data/content/*.json | classes, enemies, items, maps, npcs, portals, quests, skills, shops |
| Portable mirror | portable_data/*.json | Same structure for portability |
| Registries | data/*_registry_v4.json | Animation poses, equipment attachments |
| QA/manifests | data/PARITY_*.json, V11_*_MANIFEST.json | Static QA metadata |

---

## ASSETS

| Layer | Path | Status |
|-------|------|--------|
| Legacy runtime | assets/catalog_legacy/ | ACTIVE — village demo sprites |
| Equipment runtime | assets/equipment/ | ACTIVE — armor/weapons |
| Animation runtime | assets/animation_frames/ | ACTIVE — character poses |
| Workchat pool | assets/workchat_master_unique/ | ACTIVE — dev gallery only |
| Canonical target | assets/game/ | NOT DEPLOYED |
| Visual masters | references/visual_master/ | REFERENCE ONLY (.gdignore) |
| Source kits | BRAMBLE_NEW/*.zip | UNTOUCHED archives |

### Migration status
Runtime paths stable. Canonical `assets/game/` deployment deferred to future milestone.

---

## VISUAL TARGET

- Oblique 2.5D presentation (~38° target)
- y-sort enabled on entity layers
- Elevation via z_index layering
- Portrait + landscape: **same world state, different presentation** (not yet implemented)
- Visual masters define target look in `references/visual_master/`
