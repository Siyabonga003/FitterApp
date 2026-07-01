package app.run.fitter.challenge.repository;

import app.run.fitter.challenge.entity.Challenges;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ChallengesRepository extends R2dbcRepository<Challenges, UUID> {
}
