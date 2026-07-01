package app.run.fitter.grp.entity;

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
@Table(schema = "grp", name = "group_posts")
public class GroupPosts {
    @Id
    private UUID groupPostId;
    private UUID groupId;
    private UUID postId;
    @CreatedDate
    private ZonedDateTime createdAt;
}
