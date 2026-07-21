package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.NotificationTypes;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface NotificationTypesRepository extends R2dbcRepository<NotificationTypes, Short> {
    Mono<NotificationTypes> findByCode(String code);
}