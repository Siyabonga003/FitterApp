package app.run.fitter.challenge.repository;

import app.run.fitter.challenge.entity.Enrollments;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface EnrollmentsRepository extends R2dbcRepository<Enrollments, UUID> {
}
