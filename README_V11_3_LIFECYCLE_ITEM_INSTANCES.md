# BRAMBLE V11.3 — Lifecycle, Item Instances & Audit

BRAMBLE remains mobile-first. V11.3 deepens only the server-authoritative online foundation.

## Added
- Explicit connect → authenticate/resume → session → character resolve → world join lifecycle.
- Gameplay intents are ignored until the peer reaches `world_joined`.
- Stable item instance IDs for non-stackable equipment while stackable consumables keep quantity stacks.
- Equipment may validate a concrete owned `instance_id`.
- Server-side transaction/audit foundation carrying account, character, session and peer context.
- Protocol bumped to `bramble-v11.3`.

## Security boundary
Production token verification and PostgreSQL credentials remain server-only. The mobile Godot client never receives database credentials. Guest auth remains a development path.

## Compatibility
Legacy inventory/equipment shapes remain readable during migration. Item-instance normalization happens when a character joins so V10/V11 saves are not discarded.
