package app.run.fitter.gamification.dto;

import java.time.ZonedDateTime;


public record BadgeDto(
        String code,
        String name,
        String description,
        ZonedDateTime awardedAt,
        boolean isNew
) {}