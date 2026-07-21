package app.run.fitter.grp.repository;

import app.run.fitter.grp.entity.GroupMembers;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface GroupMembersRepository extends ReactiveCrudRepository<GroupMembers, UUID> {

    Mono<Long> countByGroupIdAndStatus(UUID groupId, String status);
    Flux<GroupMembers> findByGroupIdAndStatus(UUID groupId, String status);
    Mono<GroupMembers> findByGroupIdAndUserId(UUID groupId, UUID userId);
    Flux<GroupMembers> findByUserIdAndStatus(UUID userId, String status);
}