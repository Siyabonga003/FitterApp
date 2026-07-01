package app.run.fitter.lookup.repository;

import app.run.fitter.lookup.entity.GroupPrivacies;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GroupPrivaciesRepository extends R2dbcRepository<GroupPrivacies, Short> {
}
