package app.run.fitter.activity.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

public interface ActivitiesDTO {
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class CreateActivityRequest {
        @NotNull(message = "Activity type id is required")
        private Short activityTypeId;
        @NotNull(message = "Started at date is required")
        private ZonedDateTime startedAt;
        @NotNull(message = "Visibility id is required")
        private Short visibilityId;
        @NotNull(message = "Route visibility is required")
        private Boolean routeVisible;
        @Builder.Default
        private Boolean isLive = false;
        @Builder.Default
        private Boolean isDeleted = false;
        @Builder.Default
        private ZonedDateTime createdAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class UpdateActivityRequest {
        private Integer durationSec;
        private Integer avgPaceSecPerKm;
        private BigDecimal avgSpeedKmh;
        private String routeGeoJson;
        private BigDecimal startLat;
        private BigDecimal startLng;
        private BigDecimal endLat;
        private BigDecimal endLng;
        private Boolean routeVisible;
        private Short visibilityId;
        private Boolean isLive;
        private String notes;
        @Builder.Default
        private ZonedDateTime updatedAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class EndActivityRequest {
        @NotNull(message = "Ended at date is required")
        private ZonedDateTime endedAt;
        private BigDecimal distanceKm;
        private Integer calories;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class ActivityResponse {
        private UUID activityId;
        private UUID userId;
        private Short activityTypeId;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime startedAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
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
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime deletedAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class PublicActivityResponse {
        private UUID userId;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime startedAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
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
        private String notes;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class FeedActivityResponse {
        private UUID activityId;
        private UUID userId;
        private String displayName;
        private String profilePicUrl;
        private Short activityTypeId;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime startedAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
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
        private String notes;
    }
}
