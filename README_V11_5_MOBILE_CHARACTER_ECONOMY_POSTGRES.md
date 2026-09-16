# BRAMBLE V11.5 — Mobile Character Lifecycle + Transaction-Safe Economy

V11.5 keeps BRAMBLE mobile-first while extending the V11 NosCore-inspired server architecture.

## Added
- Network character lobby: list/create/select/delete commands after authentication.
- Resume tokens bypass the lobby and restore the previous character/session.
- Mobile-safe character-select overlay with large touch targets; no desktop-only dependency.
- Character creation/deletion are idempotency-ready and audited.
- EconomyTransactionService for atomic/idempotent gold, reputation and item deltas with rollback on failure.
- Inventory remove operations now accept transaction IDs (fixes V11.4 transaction-id gap).
- Protocol version `bramble-v11.5` in runtime + portable data.
- PostgreSQL remains a dedicated-server adapter contract: credentials/drivers are never shipped in Android/iOS clients.

## Compatibility
Existing V11 saves remain readable. The local JSON repository remains the development adapter while the PostgreSQL contract is the production boundary.
