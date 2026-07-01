package app.run.fitter.app.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.UUID;

public interface DevicesDTO {
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class RegisterPushTokenRequest {
        @NotNull(message = "Platform is required")
        private String platform;
        @NotNull(message = "Push token is required")
        private String pushToken;
        @Builder.Default
        private Boolean isActive = true;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class DeviceResponse {
        private UUID deviceId;
        private UUID userId;
        private String platform;
        private String pushToken;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime lastSeenAt;
        private Boolean isActive;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime updatedAt;
    }
}
