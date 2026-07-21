package app.run.fitter.social.repository;

import app.run.fitter.social.entity.FeedPosts;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface FeedPostsRepository extends R2dbcRepository<FeedPosts, UUID> {
    Mono<FeedPosts> findByActivityId(UUID activityId);
}