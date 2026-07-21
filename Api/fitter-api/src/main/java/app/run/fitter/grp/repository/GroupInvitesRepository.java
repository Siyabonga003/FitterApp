package app.run.fitter.grp.repository;

import app.run.fitter.grp.entity.GroupInvites;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface GroupInvitesRepository extends ReactiveCrudRepository<GroupInvites, UUID> {
    Mono<GroupInvites> findByCodeAndIsActiveTrue(String code);
}