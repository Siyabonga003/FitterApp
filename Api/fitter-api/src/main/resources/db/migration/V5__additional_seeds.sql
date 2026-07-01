INSERT INTO lookup.notification_types (code, name, description)
VALUES ('CHEER', 'Cheer', 'A cheer sent by a friend during a live run')
ON CONFLICT (code) DO NOTHING;