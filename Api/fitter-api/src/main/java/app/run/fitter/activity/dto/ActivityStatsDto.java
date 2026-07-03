package app.run.fitter.activity.dto;

import java.math.BigDecimal;

public record ActivityStatsDto(
        BigDecimal totalDistanceKm,
        Integer totalDurationSec,
        Integer totalCalories,
        Long totalSessions
) {}