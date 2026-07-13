package app.run.fitter.app.repository;

import app.run.fitter.app.entity.Friendships;
import org.springframework.data.r2dbc.repository.Modifying;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface FriendshipsRepository extends R2dbcRepository<Friendships, UUID> {

    @Query("""
            SELECT * FROM app.friendships
            WHERE (user_id = :userId AND friend_id = :friendId)
            OR (user_id = :friendId AND friend_id = :userId)
            LIMIT 1
            """)
    Mono<Friendships> findBetween(UUID userId, UUID friendId);

    @Query("""
            SELECT * FROM app.friendships
            WHERE (user_id = :userId OR friend_id = :userId)
            AND status = 'ACCEPTED'
            """)
    Flux<Friendships> findAcceptedFriends(UUID userId);

    @Query("""
            SELECT * FROM app.friendships
            WHERE friend_id = :userId
            AND status = 'PENDING'
            """)
    Flux<Friendships> findIncomingRequests(UUID userId);

    @Query("""
            SELECT * FROM app.friendships
            WHERE user_id = :userId
            AND status = 'PENDING'
            """)
    Flux<Friendships> findOutgoingRequests(UUID userId);

    @Modifying
    @Query("""
            UPDATE app.friendships
            SET status = :status
            WHERE friendship_id = :friendshipId
            """)
    Mono<Void> updateStatus(UUID friendshipId, String status);

    @Modifying
    @Query("""
            DELETE FROM app.friendships
            WHERE (user_id = :userId AND friend_id = :friendId)
            OR (user_id = :friendId AND friend_id = :userId)
            """)
    Mono<Void> deleteBetween(UUID userId, UUID friendId);
}