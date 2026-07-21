ALTER TABLE grp.groups
    ADD COLUMN target_distance_km NUMERIC(10, 2);

COMMENT ON COLUMN grp.groups.target_distance_km IS 'Shared distance goal for the group, in kilometers, over the active period';