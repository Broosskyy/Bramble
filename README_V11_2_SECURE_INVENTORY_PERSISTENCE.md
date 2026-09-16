# BRAMBLE V11.2 — Secure Inventory & Persistence Boundary

BRAMBLE remains mobile-first. V11.2 hardens server domains without moving database credentials or authoritative persistence into the Android/iOS client.

## Added
- Inventory content/quantity/ownership validation and transactional transfer rollback.
- Equipment ownership, content and slot validation.
- Persistence-provider abstraction plus PostgreSQL server-adapter contract.
- Auth gateway boundary for later dedicated token verification.
- Protocol `bramble-v11.2`.

## Runtime compatibility
The existing local JSON character repository remains the executable development adapter. PostgreSQL is intentionally a contract only until a dedicated backend runtime/driver is connected. Existing ENet gameplay, combat, movement, loot, progression, reconnect and mobile presentation remain intact.
