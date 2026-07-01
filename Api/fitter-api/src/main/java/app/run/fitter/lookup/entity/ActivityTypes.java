package app.run.fitter.lookup.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.time.ZonedDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "lookup", name = "activity_types")
public class ActivityTypes {
    @Id
    private Short activityTypeId;
    private String code;
    private String name;
    private String description;
    private Boolean isActive;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}
