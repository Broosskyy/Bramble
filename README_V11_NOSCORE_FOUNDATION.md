# BRAMBLE V11 — NosCore Architecture Foundation

V11 keeps the playable Godot V10.3R authority/runtime intact and adds a BRAMBLE-native backend foundation inspired by the separation patterns reviewed in NosCore. NosCore is **not** bundled and is not a runtime dependency.

## Added
- Stable Account / Character / Session identity boundary
- Reconnect-token session lifecycle (120 s grace)
- Character repository abstraction with local JSON persistence (`user://bramble_v11_characters.json`)
- Character service separating persistent character state from ENet peer IDs
- Domain registry for Identity, Session, Character, World, Combat, Inventory, Equipment, Progression, Loot, Quest, Party, Social and LiveOps
- Join flow: claim -> resume/auth identity -> character resolve -> session -> authoritative world snapshot
- Protocol marker `bramble-v11`
- Existing ENet/headless authority, prediction/reconciliation, collision, combat, loot and shared rewards remain in place.

## Intentional next boundary
The repository is deliberately storage-agnostic at the service boundary. Local JSON is the V11 executable fallback. PostgreSQL/API adapters should be added behind the repository rather than leaking SQL into gameplay scripts.

## Run
Normal Godot launch remains unchanged. Dedicated headless server remains `--bramble-server` with optional `--port=`.
