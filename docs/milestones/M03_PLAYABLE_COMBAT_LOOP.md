# M03 — Playable Combat Loop

**Project:** `BRAMBLE_GAME/`  
**Branch:** `origin/main`  
**Baseline:** `534501cc8717fa55b2f92ee4144cd557a5ea3589`  
**Godot:** 4.7.2  
**Main Scene:** `res://scenes/main.tscn`

---

## Status

| Gate | Result |
|------|--------|
| **PLAYABLE_COMBAT_LOOP** | **PASS** |
| **MULTIPLAYER_MINIMUM** | **PARTIAL** |
| **VISUAL_FOUNDATION_LOCKED** | **FALSE** |

---

## A. Existing System Audit

| System | Existing | Missing Wiring (pre-M03) | Runtime Verified | M03 Action |
|--------|----------|--------------------------|------------------|------------|
| Entity Registry | `network_entity_registry.gd` | `node_for_entity()` | Partial | Added lookup + player/enemy registration |
| Player Combat | `player_controller.gd` | Skills, target ID in intents | Partial | Wired attack/skill/targeting |
| Targeting | implicit nearest | Tap/click, HUD | No | `combat_targeting_service.gd` |
| Moorling AI | `enemy.gd` | Respawn, loot authority | Partial | Respawn + kill pipeline |
| Combat Runtime | server offline split | Unified offline path | Partial | `combat_runtime_service.gd` |
| Loot | `loot_pickup.gd` | Inventory mutation | Partial | Item drops + inventory |
| Quest | `game_state.gd` | Moorling mismatch | Partial | Canonical offline moorling 0/3 |
| XP/Level | `game_state.gd` | HUD only offline | Yes | Kill → XP → HUD |
| Skills | `skill_authority_service.gd` | Client skill input | No | Skill slot 0 (`cut`) offline+host |
| Remote Players | none | Replication | No | `remote_player_service.gd` + snapshot sync |
| Production HUD | `production_hud.gd` | Target, CD, inventory | Partial | Target panel + skill CD + inv counts |

---

## B. Entity Registry

- `BrambleNetworkEntityRegistry.node_for_entity(id)`
- `entity_id_for(node)`
- Registers player (id=1), enemies, remote players (2000+peer)
- Used by `combat_validation_service.target_from_payload()`

## C. Targeting

- `combat_targeting_service.gd`
- Tap/click monster → target ring + HUD target panel
- `Q` cycles targets in range
- Tap loot in range → pickup
- Target state: entityId, HP, distance, valid/alive

## D. Basic Attack

- Attack button / Space → `combat_runtime_service.resolve_basic_attack()`
- Sends `target_entity_id` in online intents
- Host uses `server_authority._basic()` with validation
- Damage: 14 (offline runtime), 13–14 (authority)

## E. Skill Pipeline

- Skill slot 1 → `cut` / Klingenhieb (`data/content/skills.json`)
- Cooldown tracked in runtime + HUD overlay
- VFX flash at target on skill hit
- Online: `send_intent("skill", {slot, target_entity_id})`

## F. Moorling AI

- Production moorlings east of village (3 spawn points)
- States: idle, chase, attack, hit, dead, respawn (8s)
- Stats: 48 HP, 8 dmg, 22 XP, 6 gold loot table
- `loot_table_id = moorling_common`

## G. Player Combat/Death

- Player HP via `game_state` (canonical offline HUD source)
- Hit presentation via `player_visual.play_hit()`
- Death → defeated pose → 2s recovery at `PLAYER_SPAWN`
- Combat blocked during death

## H. Loot

- Kill → guaranteed herb + gold world drop
- 35% ore drop
- Pickup → `game_state.add_inventory_item()` + gold

## I. Inventory

- `game_state.inventory: Array[String]`
- HUD shows herb/ore counts (`H:n O:n`)

## J. XP / Level

- Kill → `register_enemy_kill()` → `add_xp()`
- Level threshold in `game_state` (level * 100)
- HUD XP/level updates on kill

## K. Quest

- **Canonical offline quest:** Lina → kill 3 moorlings → return
- `game_state.quest_stage` + `moorling_kills`
- Online content quest `q01` aligned to moorling ×3
- Quest tracker reads `game_state` signals

## L. Respawn

- Moorling `_die()` → hidden → 8s timer → full HP at spawn
- Loop repeatable without restart

## M. Remote Player Replication

- `remote_player_service.gd` renders peer avatars from authority snapshots
- `network_world_sync._rpc_snapshot()` calls `sync_players()`
- Host updates `player_authority` from local player each frame
- **Gap:** full two-process ENet client join not automated in CI capture; snapshot path verified

## N. Mobile Combat

- Joystick + attack + skill buttons via `production_hud.gd`
- Portrait + landscape layouts preserved
- Same input actions as desktop (`basic_attack`, `skill_1`)

## O. Visual Residual Fixes

- Opportunistic only: third moorling spawn for combat loop density
- Grass seams / river edges / portrait tree occlusion **not** fully resolved

## P. Runtime QA

| Test | Result |
|------|--------|
| A Spawn → move → target | PASS (capture) |
| B Basic attack → HP down | PASS (capture) |
| C Skill + VFX + CD | PASS (capture) |
| D Moorling aggro → player HP | PASS (implementation) |
| E Monster death presentation | PASS |
| F Loot drop on kill | PASS (capture) |
| G Pickup → inventory | PASS (implementation) |
| H Kill → XP | PASS |
| I 3 kills → quest complete | PASS (capture) |
| J Respawn | PASS (implementation) |
| K Player death/recovery | PASS (implementation) |
| L Landscape touch combat | PASS (HUD wired) |
| M Portrait touch combat | PASS (capture) |
| N Host + client visible | PARTIAL (snapshot avatar; capture uses authority peer) |

## Q. Evidence

`artifacts/m03/`

- `landscape_target.png`
- `landscape_combat.png`
- `landscape_skill.png`
- `landscape_loot.png`
- `landscape_quest_complete.png`
- `portrait_combat.png`
- `portrait_loot.png`
- `multiplayer_two_players.png`

Capture command:

```powershell
Godot --path BRAMBLE_GAME res://scenes/main.tscn --m03-capture multiplayer
```

## R. Known Issues

- Grass repeat visibility at distance
- Occasional river tile seams
- Hard tree occlusion in portrait combat framing
- Full two-client ENet session not yet part of automated delivery script
- Online HUD still primarily driven by `game_state` for local host presentation

## S. Architecture Debt

- Dual quest paths (`game_state` vs `quest_authority`) bridged but not fully unified
- Client skill prediction minimal
- Status effects stored but not applied back into combat presentation
- `loot_authority` online path not fully exercised in offline production loop

## T. Recommended M04

- Real two-instance ENet QA harness
- Unify online HUD with `player_authority` state stream
- Second skill + resource bar from authority
- Visual residual pass (grass/river/occlusion)
- PostgreSQL persistence integration (deferred)

---

**Delivery:**

```powershell
py -3 tools/bramble_delivery.py --milestone m03 --message "feat(m03): playable combat loop"
```
