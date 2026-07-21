package app.run.fitter.notification.service;

import app.run.fitter.constant.PagedResponse;
import app.run.fitter.notification.dto.NotificationsDTO;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface NotificationsService {

    Mono<PagedResponse<NotificationsDTO.NotificationResponse>> getNotifications(int page, int size);

    Mono<NotificationsDTO.UnreadCountResponse> getUnreadCount();

    Mono<Void> markAsRead(UUID notificationId);

    Mono<Void> markAllAsRead();

    /**
     * Internal use by other services (groups, friendships, reactions, comments, etc.)
     * to create and deliver a notification. Not exposed via any controller endpoint.
     */
    Mono<Void> notify(UUID recipientUserId, UUID senderUserId, String typeCode,
                       String title, String body, String dataJson);
}