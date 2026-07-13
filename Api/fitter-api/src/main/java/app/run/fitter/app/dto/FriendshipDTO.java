package app.run.fitter.app.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.UUID;

public interface FriendshipDTO {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class FriendshipResponse {
    private UUID friendshipId;
    private UUID userId;
    private UUID friendId;
    private String status;
    private String displayName;
    private String email;
    private ZonedDateTime createdAt;      
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class FriendSearchResult {
        private UUID userId;
        private String displayName;
        private String email;
        private String bio;
        private String friendshipStatus; 
    }
}