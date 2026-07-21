INSERT INTO lookup.notification_types (code, name, description)
VALUES
    ('GROUP_INVITE', 'Group Invite', 'You were invited to join a group')
ON CONFLICT (code) DO NOTHING;