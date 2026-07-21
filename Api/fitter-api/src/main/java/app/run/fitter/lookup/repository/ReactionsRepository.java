package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.Reactions;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface ReactionsRepository extends R2dbcRepository<Reactions, Short> {
    Mono<Reactions> findByCode(String code);
}