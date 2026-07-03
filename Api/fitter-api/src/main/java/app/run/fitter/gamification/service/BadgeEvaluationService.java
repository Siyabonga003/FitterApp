package app.run.fitter.gamification.service;

import app.run.fitter.gamification.dto.BadgeDto;
import app.run.fitter.gamification.entity.BadgesAwarded;
import app.run.fitter.gamification.repository.BadgesAwardedRepository;
import app.run.fitter.controller.BadgeController;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.UUID;

@Service
public class BadgeEvaluationService {

    private final BadgesAwardedRepository badgesAwardedRepository;
    private final DatabaseClient db;
    private final BadgeNotificationService notificationService;

    public BadgeEvaluationService(BadgesAwardedRepository badgesAwardedRepository,
                                   DatabaseClient db,
                                   BadgeNotificationService notificationService) {
        this.badgesAwardedRepository = badgesAwardedRepository;
        this.db = db;
        this.notificationService = notificationService;
    }


    public Flux<BadgeDto> evaluateAndAward(UUID userId) {
        return Flux.merge(
                checkFirst5K(userId),
                checkStreak(userId, 7, "STREAK_7"),
                checkStreak(userId, 30, "STREAK_30"),
                checkWeekly20Km(userId),
                checkMonthly100Km(userId)
        )
        .flatMap(code -> awardIfNotAlreadyAwarded(userId, code))
        .doOnNext(badge -> notificationService.notifyBadgeAwarded(userId, badge));
    }

    private Mono<String> checkFirst5K(UUID userId) {
        return db.sql("""
                    SELECT COUNT(*) FROM activity.activities
                    WHERE user_id = :userId::uuid
                    AND distance_km >= 5
                    AND is_deleted = false
                """)
                .bind("userId", userId.toString())
                .map(row -> row.get(0, Long.class))
                .one()
                .filter(count -> count != null && count >= 1)
                .map(count -> "FIRST_5K");
    }

    private Mono<String> checkStreak(UUID userId, int days, String code) {
        return db.sql("""
                    WITH daily AS (
                        SELECT DISTINCT DATE(started_at) AS activity_date
                        FROM activity.activities
                        WHERE user_id = :userId::uuid
                        AND is_deleted = false
                        ORDER BY activity_date DESC
                        LIMIT :days
                    ),
                    consecutive AS (
                        SELECT activity_date,
                               activity_date - (ROW_NUMBER() OVER (ORDER BY activity_date))::int AS grp
                        FROM daily
                    )
                    SELECT COUNT(*) FROM consecutive
                    WHERE grp = (SELECT grp FROM consecutive ORDER BY activity_date DESC LIMIT 1)
                """)
                .bind("userId", userId.toString())
                .bind("days", days)
                .map(row -> row.get(0, Long.class))
                .one()
                .filter(count -> count != null && count >= days)
                .map(count -> code);
    }

    private Mono<String> checkWeekly20Km(UUID userId) {
        return db.sql("""
                    SELECT COALESCE(SUM(distance_km), 0)
                    FROM activity.activities
                    WHERE user_id = :userId::uuid
                    AND is_deleted = false
                    AND DATE_TRUNC('week', started_at) = DATE_TRUNC('week', now())
                """)
                .bind("userId", userId.toString())
                .map(row -> row.get(0, Double.class))
                .one()
                .filter(total -> total != null && total >= 20.0)
                .map(total -> "WEEKLY_20KM");
    }

    private Mono<String> checkMonthly100Km(UUID userId) {
        return db.sql("""
                    SELECT COALESCE(SUM(distance_km), 0)
                    FROM activity.activities
                    WHERE user_id = :userId::uuid
                    AND is_deleted = false
                    AND DATE_TRUNC('month', started_at) = DATE_TRUNC('month', now())
                """)
                .bind("userId", userId.toString())
                .map(row -> row.get(0, Double.class))
                .one()
                .filter(total -> total != null && total >= 100.0)
                .map(total -> "MONTHLY_100KM");
    }

    private Mono<BadgeDto> awardIfNotAlreadyAwarded(UUID userId, String code) {
        return badgesAwardedRepository.existsByUserIdAndCode(userId, code)
                .filter(exists -> !exists)
                .flatMap(notAwarded -> getBadgeTypeId(code))
                .flatMap(badgeTypeId -> {
                    BadgesAwarded badge = BadgesAwarded.builder()
                            .badgeAwardedId(UUID.randomUUID())
                            .userId(userId)
                            .badgeTypeId(badgeTypeId)
                            .awardedAt(ZonedDateTime.now())
                            .build();
                    return badgesAwardedRepository.save(badge);
                })
                .flatMap(saved -> getBadgeDto(code, saved.getAwardedAt(), true));
    }

   
    private Mono<Short> getBadgeTypeId(String code) {
        return db.sql("SELECT badge_type_id FROM lookup.badge_types WHERE code = :code")
                .bind("code", code)
                .map(row -> row.get("badge_type_id", Short.class))
                .one();
    }

   
    private Mono<BadgeDto> getBadgeDto(String code, ZonedDateTime awardedAt, boolean isNew) {
        return db.sql("SELECT name, description FROM lookup.badge_types WHERE code = :code")
                .bind("code", code)
                .map(row -> new BadgeDto(
                        code,
                        row.get("name", String.class),
                        row.get("description", String.class),
                        awardedAt,
                        isNew
                ))
                .one();
    }
}