package app.run.fitter.file.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "file", name = "metadata")
public class Metadata {
    @Id
    private UUID metadataId;
    private String originalFileName;
    private String storedFileName;
    private String mimeType;
    private Long fileSize;
    private String checksum;
    private ZonedDateTime uploadTime;
    private ZonedDateTime lastAccessed;
    private UUID uploadedBy;
    private String status;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
