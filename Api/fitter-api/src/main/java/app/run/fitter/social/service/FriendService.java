package app.run.fitter.social.service;

import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@Service
public class FriendService {

    private final DatabaseClient db;

    public FriendService(DatabaseClient db) {
        this.db = db;
    }

    public Mono<List<String>> getFriendIds(String userId) {
        return db.sql("""
                    SELECT friend_id::text
                    FROM app.friendships
                    WHERE user_id = :userId::uuid
                    AND status = 'ACCEPTED'
                """)
                .bind("userId", userId)
                .map(row -> row.get("friend_id", String.class))
                .all()
                .collectList();
    }
}