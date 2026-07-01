package app.run.fitter.activity.entity;

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
@Table(schema = "activity", name = "activity_photos")
public class ActivityPhotos {
    @Id
    private UUID photoId;
    private UUID activityId;
    private String url;
    private String caption;
    @CreatedDate
    private ZonedDateTime createdAt;
}
