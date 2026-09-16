# BRAMBLE V11.4 — Character / Transactions / Outbox

NosCore-inspired hardening while keeping BRAMBLE mobile-first and Godot-native.

## Added
- Account-scoped character listing, creation and ownership-safe selection foundation (max 4 characters).
- Stable character summaries for a future mobile character-select UI.
- Idempotency service for retry-safe server transactions; inventory grants accept transaction IDs.
- Equipment hardening: instance-requiring equipment can no longer be equipped by template ID only.
- Persistent JSONL audit trail (`user://bramble_v11_4_audit.jsonl`).
- Persistent outbox journal (`user://bramble_v11_4_outbox.jsonl`) for later DB/event-bus delivery.
- Protocol bumped to `bramble-v11.4`.

## Compatibility
Existing V11.3 character saves remain readable. The current auto-resolve join path remains intact so mobile gameplay does not require a new character-select screen yet.

## Next
V11.5 should expose explicit character-list/create/select RPCs, add transaction IDs to economy/trade/loot paths, and provide a PostgreSQL-backed repository/outbox implementation on dedicated servers.
