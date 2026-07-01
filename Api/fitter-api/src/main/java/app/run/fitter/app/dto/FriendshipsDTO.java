package app.run.fitter.app.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.UUID;

public interface FriendshipsDTO {
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class FriendshipResponse {
        private UUID friendshipId;
        private UUID userId;
        private UsersDTO.UserResponse friend;
        private String status;
        private ZonedDateTime createdAt;
    }
}
