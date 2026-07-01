CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS lookup;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS activity;
CREATE SCHEMA IF NOT EXISTS social;
CREATE SCHEMA IF NOT EXISTS grp;
CREATE SCHEMA IF NOT EXISTS challenge;
CREATE SCHEMA IF NOT EXISTS gamification;
CREATE SCHEMA IF NOT EXISTS notification;
CREATE SCHEMA IF NOT EXISTS integration;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS file;

-- ============================================================================
-- Shared utilities: updated_at trigger
-- ============================================================================
CREATE OR REPLACE FUNCTION app.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Lookup Tables
-- ============================================================================

-- Activity Types
CREATE TABLE IF NOT EXISTS lookup.activity_types (
  activity_type_id   SMALLSERIAL PRIMARY KEY,
  code               VARCHAR(32) UNIQUE NOT NULL,  -- WALK, JOG, RUN
  name               VARCHAR(64) NOT NULL,
  description        TEXT,
  is_active          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_activity_types_updated
BEFORE UPDATE ON lookup.activity_types
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Visibility Levels
CREATE TABLE IF NOT EXISTS lookup.visibilities (
  visibility_id  SMALLSERIAL PRIMARY KEY,
  code           VARCHAR(32) UNIQUE NOT NULL, -- PUBLIC, FRIENDS, PRIVATE, GROUP
  name           VARCHAR(64) NOT NULL,
  description    TEXT,
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_visibilities_updated
BEFORE UPDATE ON lookup.visibilities
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Group Privacy Types
CREATE TABLE IF NOT EXISTS lookup.group_privacies (
  group_privacy_id SMALLSERIAL PRIMARY KEY,
  code             VARCHAR(32) UNIQUE NOT NULL, -- OPEN, INVITE_ONLY, PRIVATE
  name             VARCHAR(64) NOT NULL,
  description      TEXT,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_group_priv_updated
BEFORE UPDATE ON lookup.group_privacies
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Reaction Types
CREATE TABLE IF NOT EXISTS lookup.reactions (
  reaction_id   SMALLSERIAL PRIMARY KEY,
  code          VARCHAR(32) UNIQUE NOT NULL, -- LIKE, CHEER, CLAP, FIRE, HEART
  name          VARCHAR(64) NOT NULL,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_reactions_updated
BEFORE UPDATE ON lookup.reactions
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Notification Types
CREATE TABLE IF NOT EXISTS lookup.notification_types (
  notification_type_id SMALLSERIAL PRIMARY KEY,
  code                 VARCHAR(48) UNIQUE NOT NULL, -- FRIEND_STARTED_RUN, WEEKLY_GOAL_HIT, COMMENT, REACTION, CHALLENGE_UPDATE
  name                 VARCHAR(96) NOT NULL,
  description          TEXT,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_notification_types_updated
BEFORE UPDATE ON lookup.notification_types
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Badge Types
CREATE TABLE IF NOT EXISTS lookup.badge_types (
  badge_type_id  SMALLSERIAL PRIMARY KEY,
  code           VARCHAR(48) UNIQUE NOT NULL, -- STREAK_7, STREAK_30, FIRST_5K, WEEKLY_20KM, MONTHLY_100KM
  name           VARCHAR(128) NOT NULL,
  description    TEXT,
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_badge_types_updated
BEFORE UPDATE ON lookup.badge_types
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- ============================================================================
-- Core App / Users (linked to Keycloak)
-- ============================================================================
CREATE TABLE IF NOT EXISTS app.users (
  user_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kc_user_id      UUID UNIQUE NOT NULL,  -- Keycloak User ID
  email           VARCHAR(256) UNIQUE,
  display_name    VARCHAR(120) NOT NULL,
  first_name      VARCHAR(80),
  last_name       VARCHAR(80),
  gender          VARCHAR(20),
  birth_date      DATE,
  profile_pic_url TEXT,
  bio             VARCHAR(280),
  -- Privacy defaults
  default_activity_visibility_id SMALLINT NOT NULL REFERENCES lookup.visibilities(visibility_id),
  default_route_visible          BOOLEAN NOT NULL DEFAULT TRUE,
  default_live_location_share    BOOLEAN NOT NULL DEFAULT FALSE,
  -- Audit
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_kc_user_id ON app.users(kc_user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);
CREATE TRIGGER trg_users_updated
BEFORE UPDATE ON app.users
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Friendships (mutual)
CREATE TABLE IF NOT EXISTS app.friendships (
  friendship_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  friend_id     UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  status        VARCHAR(20) NOT NULL DEFAULT 'ACCEPTED', -- PENDING, ACCEPTED, BLOCKED
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, friend_id),
  CHECK (user_id <> friend_id)
);
CREATE INDEX IF NOT EXISTS idx_friendships_user ON app.friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend ON app.friendships(friend_id);

-- Devices (for push notifications)
CREATE TABLE IF NOT EXISTS app.devices (
  device_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  platform     VARCHAR(16) NOT NULL, -- ANDROID, IOS, WEB
  push_token   TEXT NOT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  last_seen_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, push_token)
);
CREATE INDEX IF NOT EXISTS idx_devices_user ON app.devices(user_id);
CREATE TRIGGER trg_devices_updated
BEFORE UPDATE ON app.devices
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- User Goals (weekly/monthly)
CREATE TABLE IF NOT EXISTS app.user_goals (
  user_goal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  period_type  VARCHAR(16) NOT NULL, -- WEEKLY, MONTHLY
  year         INT NOT NULL,
  period_value INT NOT NULL, -- ISO week number or month (1-12)
  target_km    NUMERIC(7,2) NOT NULL CHECK (target_km >= 0),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, period_type, year, period_value)
);
CREATE INDEX IF NOT EXISTS idx_user_goals_user ON app.user_goals(user_id);
CREATE TRIGGER trg_user_goals_updated
BEFORE UPDATE ON app.user_goals
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- ============================================================================
-- Activity Tracking
-- ============================================================================

-- Activities (one row per activity session)
CREATE TABLE IF NOT EXISTS activity.activities (
  activity_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  activity_type_id SMALLINT NOT NULL REFERENCES lookup.activity_types(activity_type_id),
  started_at       TIMESTAMPTZ NOT NULL,
  ended_at         TIMESTAMPTZ,
  duration_sec     INT GENERATED ALWAYS AS (
    CASE WHEN ended_at IS NOT NULL THEN EXTRACT(EPOCH FROM (ended_at - started_at))::INT ELSE NULL END
  ) STORED,
  distance_km      NUMERIC(7,3) CHECK (distance_km >= 0),
  avg_pace_sec_per_km INT, -- calculated
  avg_speed_kmh    NUMERIC(6,3),
  calories         INT CHECK (calories >= 0),
  route_geojson    JSONB, -- [{"lat":-15.4,"lng":28.3,"ts":"..."}, ...]
  start_lat        NUMERIC(9,6),
  start_lng        NUMERIC(9,6),
  end_lat          NUMERIC(9,6),
  end_lng          NUMERIC(9,6),
  route_visible    BOOLEAN NOT NULL DEFAULT TRUE,
  visibility_id    SMALLINT NOT NULL REFERENCES lookup.visibilities(visibility_id),
  is_live          BOOLEAN NOT NULL DEFAULT FALSE,
  notes            VARCHAR(500),
  is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_activities_user ON activity.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_type ON activity.activities(activity_type_id);
CREATE INDEX IF NOT EXISTS idx_activities_started ON activity.activities(started_at);
CREATE INDEX IF NOT EXISTS idx_activities_visibility ON activity.activities(visibility_id);
CREATE INDEX IF NOT EXISTS idx_activities_route_gin ON activity.activities USING GIN (route_geojson jsonb_path_ops);
CREATE TRIGGER trg_activities_updated
BEFORE UPDATE ON activity.activities
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Activity Photos
CREATE TABLE IF NOT EXISTS activity.activity_photos (
  photo_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id  UUID NOT NULL REFERENCES activity.activities(activity_id) ON DELETE CASCADE,
  url          TEXT NOT NULL,
  caption      VARCHAR(200),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_activity_photos_activity ON activity.activity_photos(activity_id);

-- Live Sessions (ephemeral)
CREATE TABLE IF NOT EXISTS activity.live_sessions (
  live_session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id     UUID NOT NULL UNIQUE REFERENCES activity.activities(activity_id) ON DELETE CASCADE,
  share_enabled   BOOLEAN NOT NULL DEFAULT FALSE,
  share_started_at TIMESTAMPTZ,
  share_ended_at   TIMESTAMPTZ,
  websocket_token  TEXT, -- if needed for server-side auth to WS
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_live_sessions_updated
BEFORE UPDATE ON activity.live_sessions
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- ============================================================================
-- Social / Feed
-- ============================================================================

-- Feed posts (typically 1:1 with an activity, but allow free posts if needed)
CREATE TABLE IF NOT EXISTS social.feed_posts (
  post_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  activity_id    UUID REFERENCES activity.activities(activity_id) ON DELETE SET NULL,
  text_content   VARCHAR(1000),
  visibility_id  SMALLINT NOT NULL REFERENCES lookup.visibilities(visibility_id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted     BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_feed_posts_user ON social.feed_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_feed_posts_visibility ON social.feed_posts(visibility_id);
CREATE INDEX IF NOT EXISTS idx_feed_posts_created ON social.feed_posts(created_at);
CREATE TRIGGER trg_feed_posts_updated
BEFORE UPDATE ON social.feed_posts
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Reactions
CREATE TABLE IF NOT EXISTS social.post_reactions (
  post_reaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id          UUID NOT NULL REFERENCES social.feed_posts(post_id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  reaction_id      SMALLINT NOT NULL REFERENCES lookup.reactions(reaction_id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (post_id, user_id, reaction_id)
);
CREATE INDEX IF NOT EXISTS idx_reactions_post ON social.post_reactions(post_id);

-- Comments
CREATE TABLE IF NOT EXISTS social.post_comments (
  comment_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id      UUID NOT NULL REFERENCES social.feed_posts(post_id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  content      VARCHAR(1000) NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at   TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_comments_post ON social.post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user ON social.post_comments(user_id);
CREATE TRIGGER trg_post_comments_updated
BEFORE UPDATE ON social.post_comments
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- ============================================================================
-- Groups & Challenges
-- ============================================================================

-- Groups
CREATE TABLE IF NOT EXISTS grp.groups (
  group_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id   UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  name            VARCHAR(120) NOT NULL,
  description     VARCHAR(500),
  group_privacy_id SMALLINT NOT NULL REFERENCES lookup.group_privacies(group_privacy_id),
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_groups_owner ON grp.groups(owner_user_id);
CREATE TRIGGER trg_groups_updated
BEFORE UPDATE ON grp.groups
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Group Members
CREATE TABLE IF NOT EXISTS grp.group_members (
  group_member_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id        UUID NOT NULL REFERENCES grp.groups(group_id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  role            VARCHAR(20) NOT NULL DEFAULT 'MEMBER', -- ADMIN, MODERATOR, MEMBER
  status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- INVITED, ACTIVE, REMOVED
  joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (group_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_group_members_group ON grp.group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user ON grp.group_members(user_id);

-- Group Feed (optional separate from global feed)
CREATE TABLE IF NOT EXISTS grp.group_posts (
  group_post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id      UUID NOT NULL REFERENCES grp.groups(group_id) ON DELETE CASCADE,
  post_id       UUID NOT NULL REFERENCES social.feed_posts(post_id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (group_id, post_id)
);
CREATE INDEX IF NOT EXISTS idx_group_posts_group ON grp.group_posts(group_id);

-- Challenges (group or global)
CREATE TABLE IF NOT EXISTS challenge.challenges (
  challenge_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_by     UUID NOT NULL REFERENCES app.users(user_id) ON DELETE SET NULL,
  group_id       UUID REFERENCES grp.groups(group_id) ON DELETE SET NULL,
  name           VARCHAR(150) NOT NULL,
  description    VARCHAR(1000),
  start_date     DATE NOT NULL,
  end_date       DATE NOT NULL CHECK (end_date >= start_date),
  target_km      NUMERIC(7,2) CHECK (target_km >= 0),
  target_sessions INT CHECK (target_sessions >= 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_challenges_dates ON challenge.challenges(start_date, end_date);
CREATE TRIGGER trg_challenges_updated
BEFORE UPDATE ON challenge.challenges
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- Challenge Enrollments
CREATE TABLE IF NOT EXISTS challenge.enrollments (
  enrollment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id  UUID NOT NULL REFERENCES challenge.challenges(challenge_id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (challenge_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_enrollments_challenge ON challenge.enrollments(challenge_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON challenge.enrollments(user_id);

-- Challenge Progress (aggregated metrics per user per challenge)
CREATE TABLE IF NOT EXISTS challenge.progress (
  progress_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id  UUID NOT NULL REFERENCES challenge.challenges(challenge_id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  total_km      NUMERIC(9,3) NOT NULL DEFAULT 0,
  session_count INT NOT NULL DEFAULT 0,
  last_updated  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (challenge_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_progress_challenge_user ON challenge.progress(challenge_id, user_id);

-- ============================================================================
-- Gamification
-- ============================================================================
CREATE TABLE IF NOT EXISTS gamification.badges_awarded (
  badges_awarded_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  badge_type_id     SMALLINT NOT NULL REFERENCES lookup.badge_types(badge_type_id),
  awarded_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, badge_type_id)
);
CREATE INDEX IF NOT EXISTS idx_badges_user ON gamification.badges_awarded(user_id);

-- ============================================================================
-- Notifications
-- ============================================================================
CREATE TABLE IF NOT EXISTS notification.notifications (
  notification_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE, -- recipient
  sender_user_id        UUID REFERENCES app.users(user_id) ON DELETE SET NULL, -- optional
  notification_type_id  SMALLINT NOT NULL REFERENCES lookup.notification_types(notification_type_id),
  title                 VARCHAR(140) NOT NULL,
  body                  VARCHAR(500),
  data_json             JSONB,
  is_read               BOOLEAN NOT NULL DEFAULT FALSE,
  delivered_at          TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notification.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notification.notifications(is_read);

-- ============================================================================
-- Integrations (Google Fit, Apple Health)
-- ============================================================================
CREATE TABLE IF NOT EXISTS integration.health_connections (
  connection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  provider      VARCHAR(32) NOT NULL, -- GOOGLE_FIT, APPLE_HEALTH
  provider_user_id VARCHAR(120),
  access_token  TEXT, -- store encrypted at app level
  refresh_token TEXT,
  token_expires_at TIMESTAMPTZ,
  scopes        TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, provider)
);
CREATE TRIGGER trg_health_connections_updated
BEFORE UPDATE ON integration.health_connections
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

-- ============================================================================
-- Analytics (rollups & summaries)
-- ============================================================================

-- Daily user stats (per user per date)
CREATE TABLE IF NOT EXISTS analytics.user_daily_stats (
  user_daily_stats_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES app.users(user_id) ON DELETE CASCADE,
  stat_date     DATE NOT NULL,
  total_distance_km NUMERIC(9,3) NOT NULL DEFAULT 0,
  total_duration_sec INT NOT NULL DEFAULT 0,
  session_count  INT NOT NULL DEFAULT 0,
  avg_pace_sec_per_km INT,
  UNIQUE (user_id, stat_date)
);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON analytics.user_daily_stats(user_id, stat_date);

-- Weekly & Monthly could be materialized views or tables populated by ETL

-- ============================================================================
-- Audit
-- ============================================================================
CREATE TABLE IF NOT EXISTS audit.event_logs (
  event_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES app.users(user_id) ON DELETE SET NULL,
  event_type   VARCHAR(64) NOT NULL, -- LOGIN, START_RUN, END_RUN, CREATE_GROUP, etc.
  entity_table VARCHAR(64),
  entity_id    UUID,
  payload      JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_event_logs_user ON audit.event_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_event_logs_type ON audit.event_logs(event_type);

CREATE TABLE IF NOT EXISTS file.metadata (
  metadataId UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  original_file_name VARCHAR(255) NOT NULL,
  stored_file_name VARCHAR(255) NOT NULL UNIQUE,
  mime_type VARCHAR(100) NOT NULL,
  file_size BIGINT NOT NULL CHECK (file_size > 0),
  checksum VARCHAR(64) NOT NULL,
  upload_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_accessed TIMESTAMPTZ DEFAULT NOW(),
  uploaded_by UUID NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'UPLOADING',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Constraints & Policies
-- ============================================================================

-- Enforce visibility/route visibility consistency:
-- If visibility is PRIVATE then route_visible may remain true (owner sees it),
-- but when posting to social.feed_posts, route snapshots should respect post visibility at app layer.

-- Prevent activity live flag without live_sessions row (enforced via app logic);
-- Optionally add a check to ensure is_live implies ended_at IS NULL.
ALTER TABLE activity.activities
  ADD CONSTRAINT chk_live_activity_not_ended
  CHECK (NOT is_live OR ended_at IS NULL);

-- ============================================================================
-- Helpful Views
-- ============================================================================

-- View: Public feed (app logic should further filter per friendship/group)
CREATE OR REPLACE VIEW social.v_public_feed AS
SELECT p.post_id, p.user_id, p.activity_id, p.text_content, p.visibility_id, p.created_at,
       u.display_name, a.distance_km, a.duration_sec, a.avg_pace_sec_per_km, a.route_visible
FROM social.feed_posts p
JOIN app.users u ON u.user_id = p.user_id
LEFT JOIN activity.activities a ON a.activity_id = p.activity_id
JOIN lookup.visibilities v ON v.visibility_id = p.visibility_id AND v.code = 'PUBLIC'
WHERE p.is_deleted = FALSE;

-- Leaderboard (last 7 days) - simple sample
CREATE OR REPLACE VIEW analytics.v_weekly_leaderboard AS
SELECT
  a.user_id,
  u.display_name,
  SUM(a.distance_km) AS total_km,
  COUNT(*) AS sessions
FROM activity.activities a
JOIN app.users u ON u.user_id = a.user_id
WHERE a.started_at >= (now() - INTERVAL '7 days') AND a.is_deleted = FALSE
GROUP BY a.user_id, u.display_name
ORDER BY total_km DESC;

-- ============================================================================
-- Default Settings
-- ============================================================================
-- Example defaults: set user defaults to FRIENDS visibility if not specified at creation (app layer).

-- ============================================================================
-- End of V1
-- ============================================================================
