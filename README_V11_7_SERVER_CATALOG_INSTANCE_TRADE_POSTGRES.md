# BRAMBLE V11.7 — Server Catalog Pricing / Instance Trade / PostgreSQL Boundary

V11.7 keeps BRAMBLE mobile-first while hardening server authority.

## Changes
- Shop buy/sell prices are now resolved exclusively from server-loaded item content. Client-supplied unit prices are removed from the shop API.
- Item content contains server-side shop metadata (`buy_price`, `sell_price`, `currency`, `enabled`). Starter gear is not sellable/buyable by default.
- Trade accepts stackable `items` and unique `instances` separately. Equipment-class items must trade by `instance_id` and preserve their metadata/identity.
- Trade is idempotency-aware and restores both character snapshots if a multi-party commit fails.
- PostgreSQL contract is explicitly dedicated-server-only and documents `BRAMBLE_DATABASE_URL` as a server environment secret rather than a mobile/client setting.
- PostgreSQL migration 002 adds item-instance and trade persistence tables and transaction lookup support.

## Security rule
Android/iOS builds never receive PostgreSQL credentials. A production DB driver/sidecar is still intentionally not bundled into the Godot mobile project; the runtime adapter belongs to dedicated server deployment.
