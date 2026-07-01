package app.run.fitter.analytics.repository;

import app.run.fitter.analytics.entity.UserDailyStats;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface UserDailyStatsRepository extends R2dbcRepository<UserDailyStats, UUID> {
}
