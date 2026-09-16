-- BRAMBLE V11.8 dedicated-server persistence expansion. Apply after 002.
CREATE TABLE IF NOT EXISTS bramble_trade_sessions (
 trade_id TEXT PRIMARY KEY, character_a_id TEXT NOT NULL, character_b_id TEXT NOT NULL,
 status TEXT NOT NULL, revision INTEGER NOT NULL DEFAULT 1, offer_a_json JSONB NOT NULL DEFAULT '{}'::jsonb, offer_b_json JSONB NOT NULL DEFAULT '{}'::jsonb,
 a_locked BOOLEAN NOT NULL DEFAULT FALSE, b_locked BOOLEAN NOT NULL DEFAULT FALSE, a_confirmed BOOLEAN NOT NULL DEFAULT FALSE, b_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), created_at TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE bramble_item_instances ADD COLUMN IF NOT EXISTS upgrade_level INTEGER NOT NULL DEFAULT 0;
ALTER TABLE bramble_item_instances ADD COLUMN IF NOT EXISTS quality TEXT NOT NULL DEFAULT 'common';
CREATE INDEX IF NOT EXISTS bramble_trade_sessions_status_idx ON bramble_trade_sessions(status, updated_at DESC);
