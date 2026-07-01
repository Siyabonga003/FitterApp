package app.run.fitter.app.repository;

import app.run.fitter.app.entity.Devices;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface DevicesRepository extends R2dbcRepository<Devices, UUID> {
}
