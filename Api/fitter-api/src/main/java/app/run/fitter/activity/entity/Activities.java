package app.run.fitter.activity.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "activity", name = "activities")
public class Activities implements Persistable<UUID> {
    @Id
    private UUID activityId;
    private UUID userId;
    private Short activityTypeId;
    private ZonedDateTime startedAt;
    private ZonedDateTime endedAt;
    private Integer durationSec;
    private BigDecimal distanceKm;
    private Integer avgPaceSecPerKm;
    private BigDecimal avgSpeedKmh;
    private Integer calories;
    private String routeGeoJson;
    private BigDecimal startLat;
    private BigDecimal startLng;
    private BigDecimal endLat;
    private BigDecimal endLng;
    private Boolean routeVisible;
    private Short visibilityId;
    private Boolean isLive;
    private String notes;
    private Boolean isDeleted;
    private ZonedDateTime deletedAt;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;

    @Transient
    @Builder.Default
    private boolean newRecord = false; 

    @Override
    public UUID getId() {
        return activityId;
    }

    @Override
    public boolean isNew() {
        return newRecord;
    }
}