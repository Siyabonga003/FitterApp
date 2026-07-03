package app.run.fitter.activity.repository;

import app.run.fitter.activity.entity.Activities;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface ActivitiesRepository extends R2dbcRepository<Activities, UUID> {
   @Query("""
            SELECT * FROM activity.activities
            WHERE user_id = :userId
            AND is_deleted = false
            ORDER BY started_at DESC
            """)
    Flux<Activities> findByUserIdAndIsDeletedFalse(UUID userId);

    @Query("""
            SELECT * FROM activity.activities
            WHERE is_deleted = false
            AND visibility_id = (
                SELECT visibility_id FROM lookup.visibilities WHERE code = 'PUBLIC'
            )
            ORDER BY started_at DESC
            """)
    Flux<Activities> findAllPublicActivities();

    // All-time aggregated stats
    @Query("""
            SELECT
                COALESCE(SUM(distance_km), 0) AS total_distance_km,
                COALESCE(SUM(duration_sec), 0) AS total_duration_sec,
                COALESCE(SUM(calories), 0) AS total_calories,
                COUNT(*) AS total_sessions
            FROM activity.activities
            WHERE user_id = :userId
            AND is_deleted = false
            AND ended_at IS NOT NULL
            """)
    Mono<ActivityStatsProjection> findStatsByUserId(UUID userId);

    // Returns ISO day of week (1=Mon ... 7=Sun) for each day
    // the user had an activity this week
    @Query("""
            SELECT DISTINCT EXTRACT(ISODOW FROM started_at)::int AS day_of_week
            FROM activity.activities
            WHERE user_id = :userId
            AND is_deleted = false
            AND DATE_TRUNC('week', started_at) = DATE_TRUNC('week', now())
            ORDER BY day_of_week
            """)
    Flux<Integer> findActiveDaysThisWeek(UUID userId);
}
