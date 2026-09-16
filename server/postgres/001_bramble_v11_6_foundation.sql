-- BRAMBLE V11.6 dedicated-server persistence contract. Never ship DB credentials in the mobile client.
CREATE TABLE IF NOT EXISTS bramble_characters (character_id TEXT PRIMARY KEY, account_id TEXT NOT NULL, version BIGINT NOT NULL DEFAULT 1, state_json JSONB NOT NULL, updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS bramble_characters_account_idx ON bramble_characters(account_id);
CREATE TABLE IF NOT EXISTS bramble_transactions (transaction_id TEXT PRIMARY KEY, character_id TEXT, domain TEXT NOT NULL, result_json JSONB NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS bramble_outbox (event_id TEXT PRIMARY KEY, topic TEXT NOT NULL, payload_json JSONB NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), delivered_at TIMESTAMPTZ);
CREATE INDEX IF NOT EXISTS bramble_outbox_pending_idx ON bramble_outbox(created_at) WHERE delivered_at IS NULL;
