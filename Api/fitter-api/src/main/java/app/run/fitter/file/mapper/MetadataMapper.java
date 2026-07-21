package app.run.fitter.file.mapper;

import app.run.fitter.file.dto.MetadataDTO;
import app.run.fitter.file.entity.Metadata;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.time.ZonedDateTime;

@Mapper(
        componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        imports = { ZonedDateTime.class }
)
public interface MetadataMapper {
    @Mapping(target = "metadataId", ignore = true)
    @Mapping(target = "checksum", ignore = true)
    @Mapping(target = "lastAccessed", ignore = true)
    @Mapping(target = "uploadTime", expression = "java(ZonedDateTime.now())")
    @Mapping(target = "createdAt", expression = "java(ZonedDateTime.now())")
    @Mapping(target = "updatedAt", ignore = true)
    Metadata toEntity(MetadataDTO.CreateMetadata createMetadataRequest);

    MetadataDTO.MetadataResponse toResponse(Metadata metadata);
}