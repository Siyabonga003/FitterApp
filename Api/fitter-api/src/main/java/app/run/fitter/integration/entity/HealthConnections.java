package app.run.fitter.integration.entity;

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
@Table(schema = "integration", name = "health_connections")
public class HealthConnections {
    @Id
    private UUID connectionId;
    private UUID userId;
    private String provider;
    private String providerUserId;
    private String accessToken;
    private String refreshToken;
    private ZonedDateTime tokenExpiresAt;
    private String scopes;
    private Boolean isActive;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
