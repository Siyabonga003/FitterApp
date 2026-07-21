package app.run.fitter.app.controller;

import app.run.fitter.constant.PagedResponse;
import app.run.fitter.notification.dto.NotificationsDTO;
import app.run.fitter.notification.service.NotificationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationsController {

    private final NotificationsService notificationsService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<PagedResponse<NotificationsDTO.NotificationResponse>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return notificationsService.getNotifications(page, size);
    }

    @GetMapping("/unread-count")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<NotificationsDTO.UnreadCountResponse> getUnreadCount() {
        return notificationsService.getUnreadCount();
    }

    @PostMapping("/{notificationId}/read")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<Void> markAsRead(@PathVariable UUID notificationId) {
        return notificationsService.markAsRead(notificationId);
    }

    @PostMapping("/read-all")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<Void> markAllAsRead() {
        return notificationsService.markAllAsRead();
    }
}