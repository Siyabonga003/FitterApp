package app.run.fitter.social.entity;

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
@Table(schema = "social", name = "post_comments")
public class PostComments {
    private UUID commentId;
    private UUID postId;
    private UUID userId;
    private String content;
    private Boolean isDeleted;
    private ZonedDateTime deletedAt;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
