INSERT INTO lookup.notification_types (code, name, description)
VALUES ('CHEER', 'Cheer', 'A cheer sent by a friend during a live run')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.notification_types (code, name, description)
VALUES ('BADGE_AWARDED', 'Badge Awarded', 'A new badge has been unlocked')
ON CONFLICT (code) DO NOTHING;