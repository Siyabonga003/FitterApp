package app.run.fitter.file.service.impl;

import app.run.fitter.config.ConfigProperties;
import app.run.fitter.file.dto.MetadataDTO;
import app.run.fitter.file.entity.Metadata;
import app.run.fitter.file.mapper.MetadataMapper;
import app.run.fitter.file.repository.MetadataRepository;
import app.run.fitter.file.service.MetadataService;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferFactory;
import org.springframework.core.io.buffer.DefaultDataBufferFactory;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.ZonedDateTime;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MetadataServiceImpl implements MetadataService {
    private final ConfigProperties configProperties;
    private final MetadataRepository metadataRepository;
    private final MetadataMapper metadataMapper;

    @PostConstruct
    private void init() {
        try {
            Files.createDirectories(Paths.get(configProperties.getFileStorageBasePath()));
            log.info("File storage initialized successfully at {}", configProperties.getFileStorageBasePath());
        } catch (IOException e) {
            log.error("Failed to initialize file storage", e);
        }
    }

    @Override
    @Transactional
    @CacheEvict(value = "files", allEntries = true)
    public Mono<MetadataDTO.MetadataResponse> storeFile(FilePart filePart, UUID uploadedBy) {
        return validateFile(filePart)
                .then(Mono.defer(() -> generateMetadata(filePart, uploadedBy)))
                .flatMap(metadata ->
                        saveFileToStorage(filePart, metadata)
                                .then(metadataRepository.save(metadata))
                                .map(metadataMapper::toResponse)
                )
                .doOnSuccess(metadataResponse -> log.info("File stored successfully: {}", metadataResponse.getMetadataId()))
                .doOnError(error -> log.error("Failed to store file", error))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @Override
    @Transactional
    @CacheEvict(value = "files", allEntries = true)
    public Flux<MetadataDTO.MetadataResponse> storeFiles(Flux<FilePart> fileParts, UUID uploadedBy) {
        return fileParts
                .take(configProperties.getFileStorageMaxFilesPerRequest())
                .flatMap(filePart -> storeFile(filePart, uploadedBy), 3)
                .doOnComplete(() -> log.info("Files stored successfully"));
    }

    @Override
    @Cacheable(value = "files", key = "{#fieldId, #requestedBy}")
    public Mono<DataBuffer> getFile(UUID fieldId, UUID requestedBy) {
        return metadataRepository.findById(fieldId)
                .switchIfEmpty(Mono.error(new RuntimeException("File not found")))
                .flatMap(metadata -> {
                    updateLastAccessed(metadata);

                    return readFileFromStorage(metadata);
                })
                .doOnSuccess(dataBuffer -> log.info("File retrieved successfully: {}", fieldId))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @Override
    @Transactional
    @CacheEvict(value = "files", allEntries = true)
    public Mono<Void> deleteFile(UUID fieldId, UUID requestedBy) {
        return metadataRepository.findById(fieldId)
                .switchIfEmpty(Mono.error(new RuntimeException("File not found")))
                .flatMap(metadata -> {
                    Path filePath = getStoragePath(metadata.getStoredFileName());

                    return Mono.fromCallable(() -> {
                        Files.deleteIfExists(filePath);

                        return metadata;
                    }).subscribeOn(Schedulers.boundedElastic());
                })
                .flatMap(metadata -> {
                    metadata.setStatus("DELETED");

                    return metadataRepository.save(metadata);
                })
                .then()
                .doOnSuccess(ignored -> log.info("File deleted successfully: {}", fieldId));
    }

    @Override
    public Mono<MetadataDTO.MetadataResponse> getFileMetadata(UUID fieldId) {
        return metadataRepository.findById(fieldId)
                .map(metadataMapper::toResponse);
    }

    private Mono<Void> validateFile(FilePart filePart) {
        return Mono.fromCallable(() -> {
            if (filePart.headers().getContentLength() > configProperties.getFileStorageMaxSize()) {
                throw new RuntimeException("File size exceeds maximum allowed size of " + configProperties.getFileStorageMaxSize());
            }

            String contentType = filePart.headers().getContentType() != null
                    ? Objects.requireNonNull(filePart.headers().getContentType()).toString()
                    : "";

            if (!configProperties.getFileStorageAllowedMimeTypes().contains(contentType)) {
                throw new RuntimeException("File type is not allowed: " + contentType);
            }

            return null;
        });
    }

    private Mono<Metadata> generateMetadata(FilePart filePart, UUID uploadedBy) {
        return Mono.fromCallable(() -> {
            MetadataDTO.CreateMetadata createMetadataRequest = MetadataDTO.CreateMetadata.builder()
                    .originalFileName(filePart.filename())
                    .storedFileName(generateStoredFilename(filePart.filename()))
                    .mimeType(Objects.requireNonNull(filePart.headers().getContentType()).toString())
                    .fileSize(filePart.headers().getContentLength())
                    .uploadedBy(uploadedBy.toString())
                    .status("UPLOADING")
                    .build();

            return metadataMapper.toEntity(createMetadataRequest);
        });
    }

    private Mono<Void> saveFileToStorage(FilePart filePart, Metadata metadata) {
        Path filePath = getStoragePath(metadata.getStoredFileName());

        return filePart.transferTo(filePath)
                .then(Mono.fromCallable(() -> {
                    String checksum = calculateChecksum(filePath);
                    metadata.setChecksum(checksum);

                    long actualSize = Files.size(filePath);
                    metadata.setFileSize(actualSize);

                    return null;
                }).subscribeOn(Schedulers.boundedElastic()))
                .doOnSuccess(ignored -> metadata.setStatus("COMPLETED"))
                .doOnError(error -> {
                    metadata.setStatus("FAILED");
                    deleteFileQuietly(filePath);
                }).then();
    }

    private Mono<DataBuffer> readFileFromStorage(Metadata metadata) {
        Path filePath = getStoragePath(metadata.getStoredFileName());

        return Mono.fromCallable(() -> {
                    if (!Files.exists(filePath)) {
                        throw new RuntimeException("File not found: " + metadata.getStoredFileName());
                    }

                    DataBufferFactory bufferFactory = new DefaultDataBufferFactory();
                    byte[] fileContent = Files.readAllBytes(filePath);

                    String actualChecksum = DigestUtils.sha256Hex(fileContent);
                    if (!actualChecksum.equals(metadata.getChecksum())) {
                        throw new RuntimeException("Checksum mismatch for file: " + metadata.getStoredFileName());
                    }

                    return bufferFactory.wrap(fileContent);
                })
                .subscribeOn(Schedulers.boundedElastic());
    }

    private void updateLastAccessed(Metadata metadata) {
        metadata.setLastAccessed(ZonedDateTime.now());

        metadataRepository.save(metadata).subscribe();
    }

    private Path getStoragePath(String filename) {
        return Paths.get(configProperties.getFileStorageBasePath(), filename);
    }

    private String generateStoredFilename(String originalFilename) {
        String extension = getFileExtension(originalFilename);

        return UUID.randomUUID() + (extension.isEmpty() ? "" : "." + extension);
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
    }

    private String calculateChecksum(Path filePath) {
        try {
            byte[] fileContent = Files.readAllBytes(filePath);

            return DigestUtils.sha256Hex(fileContent);
        } catch (IOException e) {
            throw new RuntimeException("Failed to calculate checksum for file: " + filePath, e);
        }
    }

    private void deleteFileQuietly(Path filePath) {
        try {
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            log.warn("Failed to delete file: {}", filePath, e);
        }
    }
}
