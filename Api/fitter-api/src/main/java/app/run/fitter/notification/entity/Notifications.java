package app.run.fitter.notification.entity;

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
@Table(schema = "notification", name = "notifications")
public class Notifications {
    @Id
    private UUID notificationId;
    private UUID userId;
    private UUID senderUserId;
    private Short notificationTypeId;
    private String title;
    private String body;
    private String dataJson;
    private Boolean isRead;
    private ZonedDateTime deliveredAt;
    @CreatedDate
    private ZonedDateTime createdAt;
}
