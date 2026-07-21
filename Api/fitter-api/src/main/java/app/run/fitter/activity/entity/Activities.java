package app.run.fitter.activity.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.ReadOnlyProperty;
import org.springframework.data.annotation.Transient;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Column;
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
    @Column("activity_id")
    private UUID activityId;

    @Column("user_id")
    private UUID userId;

    @Column("activity_type_id")
    private Short activityTypeId;

    @Column("started_at")
    private ZonedDateTime startedAt;

    @Column("ended_at")
    private ZonedDateTime endedAt;

    @ReadOnlyProperty
    @Column("duration_sec")
    private Integer durationSec;

    @Column("distance_km")
    private BigDecimal distanceKm;

    @Column("avg_pace_sec_per_km")
    private Integer avgPaceSecPerKm;

    @Column("avg_speed_kmh")
    private BigDecimal avgSpeedKmh;

    @Column("calories")
    private Integer calories;

    @Column("route_geojson")
    private String routeGeoJson;

    @Column("start_lat")
    private BigDecimal startLat;

    @Column("start_lng")
    private BigDecimal startLng;

    @Column("end_lat")
    private BigDecimal endLat;

    @Column("end_lng")
    private BigDecimal endLng;

    @Column("route_visible")
    private Boolean routeVisible;

    @Column("visibility_id")
    private Short visibilityId;

    @Column("is_live")
    private Boolean isLive;

    @Column("notes")
    private String notes;

    @Column("is_deleted")
    private Boolean isDeleted;

    @Column("deleted_at")
    private ZonedDateTime deletedAt;

    @CreatedDate
    @Column("created_at")
    private ZonedDateTime createdAt;

    @Column("updated_at")
    private ZonedDateTime updatedAt;

    @Transient
    private boolean isNew;

    @Override
    public UUID getId() {
        return activityId;
    }

    @Override
    public boolean isNew() {
        return isNew;
    }
}