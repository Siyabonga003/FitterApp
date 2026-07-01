package app.run.fitter.activity.entity;

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
@Table(schema = "activity", name = "live_sessions")
public class LiveSessions {
    private UUID liveSessionId;
    private UUID activityId;
    private Boolean shareEnabled;
    private ZonedDateTime shareStartedAt;
    private ZonedDateTime shareEndedAt;
    private String websocketToken;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
