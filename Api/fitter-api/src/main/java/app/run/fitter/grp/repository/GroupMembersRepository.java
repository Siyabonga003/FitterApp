package app.run.fitter.grp.repository;

import app.run.fitter.grp.entity.GroupMembers;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface GroupMembersRepository extends ReactiveCrudRepository<GroupMembers, UUID> {
    
    // 🔗 Declaring this method lets Spring dynamically generate the reactive count query statement!
    Mono<Long> countByGroupId(UUID groupId);
}