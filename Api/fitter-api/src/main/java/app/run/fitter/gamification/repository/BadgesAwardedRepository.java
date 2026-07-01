package app.run.fitter.gamification.repository;

import app.run.fitter.gamification.entity.BadgesAwarded;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface BadgesAwardedRepository extends R2dbcRepository<BadgesAwarded, UUID> {

    @Query("""
            SELECT
                ba.badges_awarded_id,
                ba.user_id,
                ba.badge_type_id,
                ba.awarded_at,
                bt.code,
                bt.name,
                bt.description
            FROM gamification.badges_awarded ba
            JOIN lookup.badge_types bt ON bt.badge_type_id = ba.badge_type_id
            WHERE ba.user_id = :userId
            ORDER BY ba.awarded_at DESC
            """)
    Flux<BadgeAwardedView> findAllByUserId(UUID userId);

    @Query("""
            SELECT COUNT(*) > 0
            FROM gamification.badges_awarded ba
            JOIN lookup.badge_types bt ON bt.badge_type_id = ba.badge_type_id
            WHERE ba.user_id = :userId AND bt.code = :code
            """)
    Mono<Boolean> existsByUserIdAndCode(UUID userId, String code);
}