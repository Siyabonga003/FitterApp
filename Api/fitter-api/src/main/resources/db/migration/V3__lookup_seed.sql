BEGIN;

INSERT INTO lookup.activity_types (code, name, description) VALUES
    ('WALK','Walking','Walking activity'),
    ('JOG','Jogging','Jogging activity'),
    ('RUN','Running','Running activity')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.visibilities (code, name, description) VALUES
    ('PUBLIC','Public','Visible to everyone'),
    ('FRIENDS','Friends','Visible to friends only'),
    ('PRIVATE','Private','Visible only to the owner'),
    ('GROUP','Group','Visible to a specific group')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.group_privacies (code, name, description) VALUES
    ('OPEN','Open','Anyone can find and join'),
    ('INVITE_ONLY','Invite Only','Join by invitation or approval'),
    ('PRIVATE','Private','Hidden and invite-only')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.reactions (code, name) VALUES
    ('LIKE','Like'),
    ('CHEER','Cheer'),
    ('CLAP','Clap'),
    ('FIRE','Fire'),
    ('HEART','Heart')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.notification_types (code, name, description) VALUES
    ('FRIEND_STARTED_RUN','Friend Started Run','A friend started a live activity'),
    ('WEEKLY_GOAL_HIT','Weekly Goal Hit','User reached weekly goal'),
    ('COMMENT','New Comment','Someone commented on your post'),
    ('REACTION','New Reaction','Someone reacted to your post'),
    ('CHALLENGE_UPDATE','Challenge Update','Changes or progress in a challenge')
ON CONFLICT (code) DO NOTHING;

INSERT INTO lookup.badge_types (code, name, description) VALUES
    ('STREAK_7','7-Day Streak','Completed activities for 7 consecutive days'),
    ('STREAK_30','30-Day Streak','Completed activities for 30 consecutive days'),
    ('FIRST_5K','First 5K','Completed first 5 km run'),
    ('WEEKLY_20KM','Weekly 20 km','Ran 20 km in a week'),
    ('MONTHLY_100KM','Monthly 100 km','Ran 100 km in a month')
ON CONFLICT (code) DO NOTHING;

COMMIT;