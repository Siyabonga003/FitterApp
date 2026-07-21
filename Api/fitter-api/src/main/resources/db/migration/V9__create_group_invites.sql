CREATE TABLE IF NOT EXISTS grp.group_invites (
  invite_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id     UUID NOT NULL REFERENCES grp.groups(group_id) ON DELETE CASCADE,
  code         VARCHAR(16) UNIQUE NOT NULL,
  created_by   UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  max_uses     INT,
  use_count    INT NOT NULL DEFAULT 0,
  expires_at   TIMESTAMPTZ,
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_invites_code ON grp.group_invites(code);
CREATE INDEX IF NOT EXISTS idx_group_invites_group ON grp.group_invites(group_id);