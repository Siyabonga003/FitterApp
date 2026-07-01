package app.run.fitter.file.service;

import app.run.fitter.constant.PagedResponse;
import app.run.fitter.file.dto.MetadataDTO;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.data.domain.Pageable;
import org.springframework.http.codec.multipart.FilePart;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface MetadataService {
    Mono<MetadataDTO.MetadataResponse> storeFile(FilePart filePart, UUID uploadedBy);

    Flux<MetadataDTO.MetadataResponse> storeFiles(Flux<FilePart> fileParts, UUID uploadedBy);

    Mono<DataBuffer> getFile(UUID fieldId, UUID requestedBy);

    Mono<Void> deleteFile(UUID fieldId, UUID requestedBy);

    Mono<MetadataDTO.MetadataResponse> getFileMetadata(UUID fieldId);
}
