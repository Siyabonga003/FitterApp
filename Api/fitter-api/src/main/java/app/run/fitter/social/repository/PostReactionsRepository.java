package app.run.fitter.social.repository;

import app.run.fitter.social.entity.PostReactions;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PostReactionsRepository extends R2dbcRepository<PostReactions, UUID> {
}
