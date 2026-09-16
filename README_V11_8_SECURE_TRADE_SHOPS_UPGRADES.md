# BRAMBLE V11.8 — Secure Trade / NPC Shops / Item Upgrades

BRAMBLE remains mobile-first. V11.8 deepens the NosCore-inspired server architecture without introducing NosCore as a runtime dependency.

## Added
- Server-owned NPC shop definitions (`shops.json`) and shop stock validation.
- Shop prices remain server-authoritative; a client never supplies price or currency authority.
- Trade session state machine: Offer → Lock → Confirm → Commit. Editing an offer invalidates both locks/confirms.
- Unique equipment continues to transfer by `instance_id`.
- Persistent per-instance upgrade metadata foundation (`upgrade_level`, `quality`) and server-side upgrade service.
- PostgreSQL migration 003 for trade sessions and item-instance upgrade fields.
- PostgreSQL contract expanded for item instances, trade sessions and transaction locking.

## Deployment boundary
`BRAMBLE_DATABASE_URL` remains dedicated-server-only. Android/iOS clients contain no database credentials. A production PostgreSQL driver/sidecar is still deployment infrastructure, not bundled into the mobile project.
