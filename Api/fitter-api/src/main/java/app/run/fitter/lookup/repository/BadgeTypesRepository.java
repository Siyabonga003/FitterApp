package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.BadgeTypes;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BadgeTypesRepository extends R2dbcRepository<BadgeTypes, Short> {
}
