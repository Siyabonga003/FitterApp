package app.run.fitter.gamification.entity;

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
@Table(schema = "gamification", name = "badges_awarded")
public class BadgesAwarded {
    @Id
    private UUID badgeAwardedId;
    private UUID userId;
    private Short badgeTypeId;
    private ZonedDateTime awardedAt;
}
