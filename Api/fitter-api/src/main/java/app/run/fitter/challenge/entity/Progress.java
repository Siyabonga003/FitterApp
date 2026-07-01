package app.run.fitter.challenge.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "challenge", name = "progress")
public class Progress {
    @Id
    private UUID progressId;
    private UUID challengeId;
    private UUID userId;
    private BigDecimal totalKm;
    private Integer sessionCount;
    private ZonedDateTime lastUpdated;
}
