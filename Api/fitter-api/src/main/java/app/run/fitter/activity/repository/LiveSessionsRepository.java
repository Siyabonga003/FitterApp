package app.run.fitter.activity.repository;

import app.run.fitter.activity.entity.LiveSessions;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface LiveSessionsRepository extends R2dbcRepository<LiveSessions, UUID> {
}
