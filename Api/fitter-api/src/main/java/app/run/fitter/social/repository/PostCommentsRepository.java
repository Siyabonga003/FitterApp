package app.run.fitter.social.repository;

import app.run.fitter.social.entity.PostComments;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface PostCommentsRepository extends R2dbcRepository<PostComments, UUID> {

    @Query("""
            SELECT * FROM social.post_comments
            WHERE post_id = :postId
            AND is_deleted = false
            ORDER BY created_at ASC
            LIMIT :limit OFFSET :offset
            """)
    Flux<PostComments> findByPostIdAndIsDeletedFalse(UUID postId, int limit, int offset);

    Mono<Long> countByPostIdAndIsDeletedFalse(UUID postId);
}