package app.run.fitter.activity.repository;

import java.math.BigDecimal;

public record ActivityStatsProjection(
        BigDecimal totalDistanceKm,
        Integer totalDurationSec,
        Integer totalCalories,
        Long totalSessions
) {}