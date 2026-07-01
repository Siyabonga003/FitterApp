package app.run.fitter.social.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;

@Table("social.runner_locations")
public class RunnerLocation {

    @Id
    @Column("user_id")
    private String userId;

    @Column("latitude")
    private double latitude;

    @Column("longitude")
    private double longitude;

    @Column("pace_km_per_min")
    private double paceKmPerMin;

    @Column("distance_km")
    private double distanceKm;

    @Column("sharing_live")
    private boolean sharingLive;

    @Column("updated_at")
    private Instant updatedAt;

    @Transient
    private String displayName;

    public RunnerLocation() {}

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public double getPaceKmPerMin() { return paceKmPerMin; }
    public void setPaceKmPerMin(double paceKmPerMin) { this.paceKmPerMin = paceKmPerMin; }

    public double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }

    public boolean isSharingLive() { return sharingLive; }
    public void setSharingLive(boolean sharingLive) { this.sharingLive = sharingLive; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
}