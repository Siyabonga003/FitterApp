package app.run.fitter.app.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

public interface UsersDTO {
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class CreateUserRequest {
        @NotNull(message = "keycloak user id is required")
        private UUID kcUserId;
        @NotNull(message = "email is required")
        private String email;
        @NotNull(message = "password is required") // ✅ Added — required for Keycloak provisioning
        private String password;
        @NotNull(message = "display name is required")
        private String displayName;
        @NotNull(message = "first name is required")
        private String firstName;
        @NotNull(message = "last name is required")
        private String lastName;
        @NotNull(message = "gender is required")
        private String gender;
        @NotNull(message = "birth date is required")
        private LocalDate birthDate;
        private String bio;
        @NotNull(message = "default activity visibility id is required")
        private Short defaultActivityVisibilityId;
        @Builder.Default
        private Boolean defaultRouteVisible = true;
        @Builder.Default
        private Boolean defaultLiveLocationShare = false;
        @Builder.Default
        private Boolean isActive = true;
        @Builder.Default
        private Boolean isDeleted = false;
        @Builder.Default
        private ZonedDateTime createdAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class UpdateUserRequest {
        private UUID kcUserId;
        private String email;
        private String displayName;
        private String firstName;
        private String lastName;
        private String gender;
        private LocalDate birthDate;
        private String bio;
        private Boolean isActive;
        @Builder.Default
        private ZonedDateTime updatedAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class UpdateUserPrivacyRequest {
        private Short defaultActivityVisibilityId;
        private Boolean defaultRouteVisible;
        private Boolean defaultLiveLocationShare;
        @Builder.Default
        private ZonedDateTime updatedAt = ZonedDateTime.now();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class SearchUsersRequest {
        private String email;
        private String displayName;
        private String firstName;
        private String lastName;
        private String gender;
        private LocalDate birthDate;
        private LocalDate birthDateFrom;
        private LocalDate birthDateTo;
        private String bio;
        private Short defaultActivityVisibilityId;
        private Boolean defaultRouteVisible;
        private Boolean defaultLiveLocationShare;
        private Boolean isActive;
        private String sortBy;
        private String sortDir;
        private Integer page;
        private Integer size;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class UserResponse {
        private UUID userId;   // ✅ Lombok generates getUserId(), not getId()
        private UUID kcUserId;
        private String email;
        private String displayName;
        private String firstName;
        private String lastName;
        private String gender;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        private LocalDate birthDate;
        private String bio;
        private Short defaultActivityVisibilityId;
        private Boolean defaultRouteVisible;
        private Boolean defaultLiveLocationShare;
        private Boolean isActive;
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
    class PublicUserResponse {
        private String email;
        private String displayName;
        private String firstName;
        private String lastName;
        private String gender;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        private LocalDate birthDate;
        private String bio;
    }
}