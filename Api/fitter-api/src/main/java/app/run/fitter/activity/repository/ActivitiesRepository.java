package app.run.fitter.activity.repository;

import app.run.fitter.activity.entity.Activities;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

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
}
