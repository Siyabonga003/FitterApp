package app.run.fitter.notification.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.UUID;

public interface NotificationsDTO {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    class NotificationResponse {
        private UUID notificationId;
        private UUID senderUserId;
        private String senderDisplayName;
        private String senderProfilePicUrl;
        private String typeCode;
        private String title;
        private String body;
        private String dataJson;
        private Boolean isRead;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        private ZonedDateTime createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    class UnreadCountResponse {
        private long count;
    }
}