package app.run.fitter.challenge.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "challenge", name = "enrollments")
public class Enrollments {
    @Id
    private UUID enrollmentId;
    private UUID challengeId;
    private UUID userId;
    private ZonedDateTime joinedAt;
}
