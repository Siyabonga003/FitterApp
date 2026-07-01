package app.run.fitter.analytics.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "analytics", name = "user_daily_stats")
public class UserDailyStats {
    @Id
    private UUID userDailyStatsId;
    private UUID userId;
    private LocalDate statDate;
    private BigDecimal totalDistanceKm;
    private Integer totalDurationSec;
    private Integer sessionCount;
    private Integer avgPaceSecPerKm;
}
