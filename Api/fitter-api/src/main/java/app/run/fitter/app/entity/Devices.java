package app.run.fitter.app.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.relational.core.mapping.Table;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "app", name = "devices")
public class Devices {
    private UUID deviceId;
    private UUID userId;
    private String platform;
    private String pushToken;
    private ZonedDateTime lastSeenAt;
    private Boolean isActive;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
