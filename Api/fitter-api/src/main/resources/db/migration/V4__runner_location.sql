CREATE TABLE IF NOT EXISTS social.runner_locations (
    user_id         VARCHAR(255)     NOT NULL PRIMARY KEY,
    latitude        DOUBLE PRECISION NOT NULL,
    longitude       DOUBLE PRECISION NOT NULL,
    pace_km_per_min DOUBLE PRECISION DEFAULT 0,
    distance_km     DOUBLE PRECISION DEFAULT 0,
    sharing_live    BOOLEAN          NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ      NOT NULL
);

CREATE INDEX idx_runner_locations_sharing_live
    ON social.runner_locations (sharing_live);

CREATE INDEX idx_runner_locations_updated_at
    ON social.runner_locations (updated_at);