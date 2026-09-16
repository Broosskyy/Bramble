# M03.1 — Multiplayer + Visual Stabilization Gate

**Milestone:** M03.1  
**Baseline HEAD:** `e0d3125180a45c92e8cabefb40cfd10e99654def`  
**Gate date:** 2026-09-16

## A. Multiplayer E2E Setup

Two real Godot 4.7.2 processes on Windows using existing ENet:

```powershell
# Host
Godot --path BRAMBLE_GAME res://scenes/main.tscn --host --port=27841 --no-lobby --m03_1-e2e=host

# Client
Godot --path BRAMBLE_GAME res://scenes/main.tscn --join 127.0.0.1 --port=27841 --no-lobby --m03_1-e2e=client
```

Orchestrator:

```powershell
py -3 tools/m03_1_multiplayer_e2e.py
```

Both processes load the production `VisualMasterWorld`. CLI flags:

| Flag | Purpose |
|------|---------|
| `--host` / `--join <addr>` | ENet host or client |
| `--port=<n>` | Bind/connect port (default 27840, E2E uses 27841) |
| `--no-lobby` | Skip character lobby; auto-create/select guest |
| `--m03_1-e2e=host\|client` | Automated E2E movement, screenshots, logging |
| `--m03_1-capture` | Visual foundation screenshots |

## B. Host/Client Results

| Check | Result |
|-------|--------|
| Host starts | PASS — peer 1, port 27841 |
| Client connects | PASS — unique ENet peer IDs |
| Host self-join | PASS — local `receive_world_join` (no self-RPC) |
| Session established | PASS — matching `session_id` in log |

## C. Remote Player Replication

| Check | Result |
|-------|--------|
| Remote avatar spawn | PASS — `remote_player_created` logged |
| Host sees client | PASS — `host_with_client.png` |
| Client sees host | PASS — `client_with_host.png` |
| Host → client movement | PASS — snapshot replication logged |
| Client → host movement | PASS — bidirectional snapshots |
| Direction flip | PASS — `dir_x` in authority state |

## D. Disconnect/Reconnect

| Check | Result |
|-------|--------|
| Client disconnect | PASS — `peer_left`, `remote_player_removed` |
| Avatar cleanup | PASS — `disconnect_cleanup remotes=0` |
| Reconnect | PASS — second connection, `reconnect_ok` |
| No duplicate avatars | PASS — single remote after reconnect |

## E. Combat Network Sanity

Host + client connected; host targets nearest Moorling and performs basic attack while snapshots continue (`combat_sanity host_attack_ok snapshots=N`).

**Documented gap (deferred to Authority milestone):**

- Full combat state replication (enemy HP, loot, quest progress) is host-authoritative offline-style on host only.
- Client combat intents route through `server_authority`; local `combat_runtime_service` resolves on host/offline only.
- No regression observed in snapshot cadence when second player connected.

## F. Grass Fix

`terrain_tile_placer.gd`: deterministic `fill_grid_variated()` — alternates grass/dirt tiles, hash-based flip, sparse clump overlays. Applied to world fill in `visual_master_world_builder.gd`. Deterministic between runs.

## G. River Fix

`_build_river()` unified water/bank step on `water_step`; aligned endcaps to stream ends; removed orphan corner sprite. Banks use `TilePlacer.place` for consistent bleed.

## H. Occlusion Fix

`world_presentation_config.gd`: softer fade (0.68), wider min depth (18), slower fade speed (6).  
`occlusion_manager.gd`: requires player under canopy Y band, not merely near trunk X.  
Wilds combat trees near `(620,120)`: reduced canopy half-width / height on north-side oaks.

## I. M03 Regression Test

| Step | Result |
|------|--------|
| Movement → Target → Attack → Skill | PASS |
| Damage → Enemy Attack → Player Damage | PASS |
| Kill → Loot → Pickup → Inventory | PASS |
| XP → Quest Progress → Respawn | PASS |
| Smoke test | PASS |

## J. Runtime Evidence

```
artifacts/m03_1/
  landscape_world_final.png
  portrait_world_final.png
  portrait_combat_final.png
  host_with_client.png
  client_with_host.png
  multiplayer_e2e.log
  host_process.log
  client_session_1.log
  client_reconnect.log
```

## K. Remaining Issues

- Snapshot payload exceeds ENet MTU (~3.3 KB warning); monitor packet loss on larger worlds.
- ENet peer IDs are large integers on this Godot build; functionally correct but noisy in logs.
- Full MMO combat replication still deferred to Authority milestone.

## L. Gate Decision

| Gate | Status |
|------|--------|
| PLAYABLE_COMBAT_LOOP | **PASS** |
| MULTIPLAYER_MINIMUM | **PASS** |
| VISUAL_FOUNDATION_LOCKED | **TRUE** |

Visual foundation is stable for future map/gameplay work without another foundation rewrite. Not a claim of final art polish on every asset.
