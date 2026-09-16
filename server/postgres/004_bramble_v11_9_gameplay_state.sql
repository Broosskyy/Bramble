-- BRAMBLE V11.9 dedicated-server persistence extension
CREATE TABLE IF NOT EXISTS bramble_character_quest_state (
  character_id TEXT PRIMARY KEY,
  quest_index INTEGER NOT NULL DEFAULT 0,
  counters JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS bramble_skill_cooldown_audit (
  id BIGSERIAL PRIMARY KEY,
  character_id TEXT NOT NULL,
  skill_id TEXT NOT NULL,
  used_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
