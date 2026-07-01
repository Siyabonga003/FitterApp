package app.run.fitter.gamification.repository;

import java.time.ZonedDateTime;
import java.util.UUID;

public record BadgeAwardedView(
        UUID badgesAwardedId,
        UUID userId,
        Short badgeTypeId,
        ZonedDateTime awardedAt,
        String code,
        String name,
        String description
) {}