package app.run.fitter.social.repository;

import app.run.fitter.social.entity.RunnerLocation;
import org.springframework.data.r2dbc.repository.Modifying;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;

@Repository
public interface RunnerLocationRepository extends ReactiveCrudRepository<RunnerLocation, String> {

    @Query("""
            SELECT
                rl.user_id,
                rl.latitude,
                rl.longitude,
                rl.pace_km_per_min,
                rl.distance_km,
                rl.sharing_live,
                rl.updated_at,
                u.display_name          -- pulled from app.users, not stored in runner_locations
            FROM social.runner_locations rl
            JOIN app.users u ON u.user_id = rl.user_id::uuid
            WHERE rl.user_id = ANY(:friendIds)
            AND rl.sharing_live = true
            """)
    Flux<RunnerLocation> findLiveFriends(List<String> friendIds);

    @Modifying
    @Query("DELETE FROM social.runner_locations WHERE updated_at < :cutoff")
    Mono<Void> deleteStaleLocations(Instant cutoff);

    @Query("""
            SELECT
                rl.user_id,
                rl.latitude,
                rl.longitude,
                rl.pace_km_per_min,
                rl.distance_km,
                rl.sharing_live,
                rl.updated_at,
                u.display_name
            FROM social.runner_locations rl
            JOIN app.users u ON u.user_id = rl.user_id::uuid
            WHERE rl.updated_at > :since
            ORDER BY rl.updated_at DESC
            """)
    Flux<RunnerLocation> findAllLivePresence(Instant since);

    @Query("""
            SELECT COUNT(*)
            FROM social.runner_locations
            WHERE updated_at > :since
            """)
    Mono<Long> countLivePresence(Instant since);
}