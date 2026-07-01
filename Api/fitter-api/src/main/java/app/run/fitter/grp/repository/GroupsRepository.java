package app.run.fitter.grp.repository;

import app.run.fitter.grp.entity.Groups;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface GroupsRepository extends R2dbcRepository<Groups, UUID> {
}
