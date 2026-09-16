# BRAMBLE V11.6 — Transaction Pipeline

V11.6 keeps the Godot mobile client and current playable world intact while consolidating server-authoritative value changes behind transaction boundaries.

## Added
- RewardTransactionService: reward grants route economy/items through the idempotent economy service, progression separately, plus audit/outbox events.
- LootAuthority now commits loot through RewardTransactionService instead of directly mutating player inventory.
- ShopTransactionService: validated buy/sell operations with server-side gold + inventory transaction semantics.
- TradeTransactionService foundation: validates both parties and ownership before commit, with rollback of character state if the second leg fails.
- PostgreSQL V11.6 schema contract for characters, idempotent transaction results and outbox events. This is dedicated-server infrastructure only.
- Protocol version `bramble-v11.6` and economy/shop/trade domain declarations.

## Mobile lock
BRAMBLE remains mobile-first. No PostgreSQL driver, credentials, admin secret or authoritative economy logic belongs in Android/iOS exports. The mobile client sends intents; the server validates and commits them.

## Next hardening
Trade should move from in-process rollback to a real database transaction when the PostgreSQL adapter becomes active. Shop prices should be resolved from server-owned content/catalog data rather than trusted from a client request.
