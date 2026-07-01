package app.run.fitter.audit.repository;

import app.run.fitter.audit.entity.EventLogs;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface EventLogsRepository extends R2dbcRepository<EventLogs, UUID> {
}
