package app.run.fitter.file.repository;

import app.run.fitter.file.entity.Metadata;
import org.springframework.data.domain.Pageable;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

import java.util.UUID;

@Repository
public interface MetadataRepository extends R2dbcRepository<Metadata, UUID> {
    Flux<Metadata> findByUploadedByAndStatus(UUID uploadedBy, String status, Pageable pageable);
}
