-- Add notification types needed for friend request system
INSERT INTO lookup.notification_types (code, name, description)
VALUES
    ('FRIEND_REQUEST', 'Friend Request', 'Someone sent you a friend request'),
    ('FRIEND_ACCEPTED', 'Friend Request Accepted', 'Your friend request was accepted')
ON CONFLICT (code) DO NOTHING;