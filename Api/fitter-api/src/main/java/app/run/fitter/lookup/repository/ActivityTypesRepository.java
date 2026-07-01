package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.ActivityTypes;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ActivityTypesRepository extends R2dbcRepository<ActivityTypes, Short> {
}
