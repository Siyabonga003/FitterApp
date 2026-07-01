package app.run.fitter.social.entity;

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
@Table(schema = "social", name = "post_reactions")
public class PostReactions {
    @Id
    private UUID postReactionId;
    private UUID postId;
    private UUID userId;
    private Short reactionId;
    @CreatedDate
    private ZonedDateTime createdAt;
}
