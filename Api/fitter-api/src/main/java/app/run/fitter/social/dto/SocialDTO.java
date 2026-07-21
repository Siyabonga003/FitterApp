package app.run.fitter.social.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.UUID;

public interface SocialDTO {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class ReactRequest {
        private String reactionCode; // "LIKE" or "CHEER"
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class ReactionSummaryResponse {
        private long likeCount;
        private long cheerCount;
        private boolean currentUserLiked;
        private boolean currentUserCheered;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class CommentRequest {
        private String content;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class CommentResponse {
        private UUID commentId;
        private UUID userId;
        private String displayName;
        private String profilePicUrl;
        private String content;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime createdAt;
    }
}