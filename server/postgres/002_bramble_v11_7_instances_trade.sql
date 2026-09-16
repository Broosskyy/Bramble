-- BRAMBLE V11.7 dedicated-server persistence expansion. Apply after 001.
CREATE TABLE IF NOT EXISTS bramble_item_instances (
  instance_id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  owner_character_id TEXT NOT NULL REFERENCES bramble_characters(character_id) ON DELETE CASCADE,
  meta_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS bramble_item_instances_owner_idx ON bramble_item_instances(owner_character_id);
CREATE TABLE IF NOT EXISTS bramble_trades (
  trade_id TEXT PRIMARY KEY,
  character_a_id TEXT NOT NULL,
  character_b_id TEXT NOT NULL,
  result_json JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE bramble_transactions ADD COLUMN IF NOT EXISTS request_hash TEXT;
CREATE INDEX IF NOT EXISTS bramble_transactions_character_idx ON bramble_transactions(character_id, created_at DESC);
