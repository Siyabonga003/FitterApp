package app.run.fitter.notification.repository;

import app.run.fitter.notification.entity.Notifications;
import org.springframework.data.r2dbc.repository.Modifying;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface NotificationsRepository extends R2dbcRepository<Notifications, UUID> {

    @Query("""
            SELECT * FROM notification.notifications
            WHERE user_id = :userId
            ORDER BY created_at DESC
            LIMIT :limit OFFSET :offset
            """)
    Flux<Notifications> findByUserId(UUID userId, int limit, int offset);

    Mono<Long> countByUserIdAndIsReadFalse(UUID userId);

    @Modifying
    @Query("""
            UPDATE notification.notifications
            SET is_read = true
            WHERE user_id = :userId
            AND is_read = false
            """)
    Mono<Void> markAllAsRead(UUID userId);
}