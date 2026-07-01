package app.run.fitter.app.dto;

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

public interface UserGoalsDTO {
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class CreateUserGoalRequest {
        @NotNull(message = "Period type is required")
        private String periodType;
        private Integer year;
        private Integer periodValue;
        private BigDecimal targetKm;
        @Builder.Default
        private ZonedDateTime createdAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class UpdateUserGoalRequest {
        private String periodType;
        private Integer year;
        private Integer periodValue;
        private BigDecimal targetKm;
        @Builder.Default
        private ZonedDateTime updatedAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class UserGoalResponse {
        private UUID userGoalId;
        private UUID userId;
        private String periodType;
        private Integer year;
        private Integer periodValue;
        private BigDecimal targetKm;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime updatedAt;
    }
}
