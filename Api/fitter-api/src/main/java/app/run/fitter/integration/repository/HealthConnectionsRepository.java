package app.run.fitter.integration.repository;

import app.run.fitter.integration.entity.HealthConnections;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface HealthConnectionsRepository extends R2dbcRepository<HealthConnections, UUID> {
}
