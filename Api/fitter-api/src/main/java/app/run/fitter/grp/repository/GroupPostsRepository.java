package app.run.fitter.grp.repository;

import app.run.fitter.grp.entity.GroupPosts;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface GroupPostsRepository extends R2dbcRepository<GroupPosts, UUID> {
}
