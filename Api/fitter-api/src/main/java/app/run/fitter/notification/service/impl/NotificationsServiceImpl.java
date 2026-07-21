package app.run.fitter.notification.service.impl;

import app.run.fitter.app.entity.Users;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.exception.ForbiddenException;
import app.run.fitter.exception.ResourceNotFoundException;
import app.run.fitter.lookup.entity.NotificationTypes;
import app.run.fitter.lookup.repository.NotificationTypesRepository;
import app.run.fitter.notification.dto.NotificationsDTO;
import app.run.fitter.notification.entity.Notifications;
import app.run.fitter.notification.repository.NotificationsRepository;
import app.run.fitter.notification.service.NotificationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationsServiceImpl implements NotificationsService {

    private final NotificationsRepository notificationsRepository;
    private final NotificationTypesRepository notificationTypesRepository;
    private final UsersRepository usersRepository;

    @Override
    public Mono<PagedResponse<NotificationsDTO.NotificationResponse>> getNotifications(int page, int size) {
        int offset = page * size;

        return getCurrentUserId().flatMap(userId ->
                notificationsRepository.findByUserId(userId, size, offset)
                        .collectList()
                        .flatMap(notifications -> {
                            List<UUID> senderIds = notifications.stream()
                                    .map(Notifications::getSenderUserId)
                                    .filter(Objects::nonNull)
                                    .distinct()
                                    .collect(Collectors.toList());

                            List<Short> typeIds = notifications.stream()
                                    .map(Notifications::getNotificationTypeId)
                                    .filter(Objects::nonNull)
                                    .distinct()
                                    .collect(Collectors.toList());

                            Mono<java.util.Map<UUID, Users>> usersMono = usersRepository
                                    .findAllById(senderIds)
                                    .collectMap(Users::getUserId);

                            Mono<java.util.Map<Short, NotificationTypes>> typesMono = notificationTypesRepository
                                    .findAllById(typeIds)
                                    .collectMap(NotificationTypes::getNotificationTypeId);

                            return Mono.zip(usersMono, typesMono).map(z -> {
                                var usersById = z.getT1();
                                var typesById = z.getT2();

                                List<NotificationsDTO.NotificationResponse> responses = notifications.stream()
                                        .map(n -> {
                                            Users sender = n.getSenderUserId() != null
                                                    ? usersById.get(n.getSenderUserId()) : null;
                                            NotificationTypes type = typesById.get(n.getNotificationTypeId());

                                            return NotificationsDTO.NotificationResponse.builder()
                                                    .notificationId(n.getNotificationId())
                                                    .senderUserId(n.getSenderUserId())
                                                    .senderDisplayName(sender != null ? sender.getDisplayName() : null)
                                                    .senderProfilePicUrl(sender != null ? sender.getProfilePictureUrl() : null)
                                                    .typeCode(type != null ? type.getCode() : null)
                                                    .title(n.getTitle())
                                                    .body(n.getBody())
                                                    .dataJson(n.getDataJson())
                                                    .isRead(n.getIsRead())
                                                    .createdAt(n.getCreatedAt())
                                                    .build();
                                        })
                                        .collect(Collectors.toList());

                                return PagedResponse.<NotificationsDTO.NotificationResponse>builder()
                                        .content(responses)
                                        .build();
                            });
                        }));
    }

    @Override
    public Mono<NotificationsDTO.UnreadCountResponse> getUnreadCount() {
        return getCurrentUserId()
                .flatMap(notificationsRepository::countByUserIdAndIsReadFalse)
                .map(count -> NotificationsDTO.UnreadCountResponse.builder().count(count).build());
    }

    @Override
    public Mono<Void> markAsRead(UUID notificationId) {
        return getCurrentUserId().flatMap(userId ->
                notificationsRepository.findById(notificationId)
                        .switchIfEmpty(Mono.error(new ResourceNotFoundException("Notification", notificationId.toString())))
                        .flatMap(n -> {
                            if (!n.getUserId().equals(userId)) {
                                return Mono.error(new ForbiddenException("This notification does not belong to you."));
                            }
                            if (Boolean.TRUE.equals(n.getIsRead())) {
                                return Mono.empty();
                            }
                            n.setIsRead(true);
                            return notificationsRepository.save(n).then();
                        }));
    }

    @Override
    public Mono<Void> markAllAsRead() {
        return getCurrentUserId().flatMap(notificationsRepository::markAllAsRead);
    }

    @Override
    public Mono<Void> notify(UUID recipientUserId, UUID senderUserId, String typeCode,
                              String title, String body, String dataJson) {
        return notificationTypesRepository.findByCode(typeCode)
                .switchIfEmpty(Mono.error(new IllegalStateException("Unknown notification type code: " + typeCode)))
                .flatMap(type -> notificationsRepository.save(
                        Notifications.builder()
                                .notificationId(UUID.randomUUID())
                                .userId(recipientUserId)
                                .senderUserId(senderUserId)
                                .notificationTypeId(type.getNotificationTypeId())
                                .title(title)
                                .body(body)
                                .dataJson(dataJson)
                                .isRead(false)
                                .createdAt(ZonedDateTime.now())
                                .isNewRecord(true)
                                .build()
                ))
                .then();
    }

    private Mono<UUID> getCurrentUserId() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(Authentication::getPrincipal)
                .cast(Jwt.class)
                .map(jwt -> UUID.fromString(jwt.getSubject()));
    }
}