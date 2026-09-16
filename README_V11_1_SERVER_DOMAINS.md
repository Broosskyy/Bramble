# BRAMBLE V11.1 — Server Domains

Builds on V11 NosCore-inspired boundaries without adding a NosCore runtime dependency.

## Added
- Server-authoritative InventoryService with stack add/remove/count and persistence commits.
- EquipmentService with explicit equipment slots and persistence commits.
- ProgressionService for gold/XP/job XP/reputation, level-up and HP growth.
- Reward grants now route through Progression + Inventory domains.
- Potion consumption now routes through Inventory instead of mutating player state directly.
- Protocol bumped to `bramble-v11.1`.

## Compatibility
Godot/mobile client, ENet authority, prediction/reconciliation, combat, loot, reconnect and V10/V11 content remain intact. Local JSON remains the development persistence adapter; PostgreSQL is the next production adapter target.
