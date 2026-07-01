package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.Visibilities;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VisibilitiesRepository extends R2dbcRepository<Visibilities, Short> {
}
