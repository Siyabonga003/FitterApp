package app.run.fitter.audit.entity;

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
@Table(schema = "audit", name = "event_logs")
public class EventLogs {
    @Id
    private UUID eventId;
    private UUID userId;
    private String eventType;
    private String entityTable;
    private UUID entityId;
    private String payload;
    @CreatedDate
    private ZonedDateTime createdAt;
}
