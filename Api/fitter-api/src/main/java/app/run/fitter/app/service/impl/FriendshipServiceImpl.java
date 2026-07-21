package app.run.fitter.app.service.impl;

import app.run.fitter.app.dto.FriendshipDTO;
import app.run.fitter.app.entity.Friendships;
import app.run.fitter.app.repository.FriendshipsRepository;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.app.service.FriendshipService;
import app.run.fitter.notification.entity.Notifications;
import app.run.fitter.notification.repository.NotificationsRepository;
import app.run.fitter.lookup.repository.NotificationTypesRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FriendshipServiceImpl implements FriendshipService {

    private final FriendshipsRepository friendshipsRepository;
    private final UsersRepository usersRepository;
    private final NotificationsRepository notificationsRepository;
    private final NotificationTypesRepository notificationTypesRepository;

    @Override
    public Mono<FriendshipDTO.FriendshipResponse> sendRequest(UUID fromUserId, UUID toUserId) {
        return friendshipsRepository.findBetween(fromUserId, toUserId)
                .flatMap(existing -> Mono.<FriendshipDTO.FriendshipResponse>error(
                        new IllegalStateException("Friendship already exists with status: "
                                + existing.getStatus())))
                .switchIfEmpty(
                    friendshipsRepository.save(
                        Friendships.builder()
                            .friendshipId(UUID.randomUUID())
                            .userId(fromUserId)
                            .friendId(toUserId)
                            .status("PENDING")
                            .createdAt(ZonedDateTime.now())
                            .isNew(true)
                            .build()
                    )
                    .flatMap(saved ->
                        sendFriendRequestNotification(fromUserId, toUserId)
                        .then(usersRepository.findById(toUserId))
                        .map(targetUser -> FriendshipDTO.FriendshipResponse.builder()
                            .friendshipId(saved.getFriendshipId())
                            .userId(saved.getUserId())
                            .friendId(saved.getFriendId())
                            .status(saved.getStatus())
                            .displayName(targetUser.getDisplayName())
                            .email(targetUser.getEmail())
                            .createdAt(saved.getCreatedAt())
                            .build())
                    )
                );
    }

    @Override
    public Mono<FriendshipDTO.FriendshipResponse> acceptRequest(UUID friendshipId,
                                                                  UUID currentUserId) {
        return friendshipsRepository.findById(friendshipId)
                .switchIfEmpty(Mono.error(new IllegalArgumentException("Request not found")))
                .filter(f -> f.getFriendId().equals(currentUserId))
                .switchIfEmpty(Mono.error(new IllegalStateException("Not authorised to accept this request")))
                .flatMap(f -> {
                    f.setStatus("ACCEPTED");
                    return friendshipsRepository.save(f);
                })
                .flatMap(saved ->
                    sendFriendAcceptedNotification(saved.getFriendId(), saved.getUserId())
                    .then(usersRepository.findById(saved.getUserId()))
                    .map(sender -> FriendshipDTO.FriendshipResponse.builder()
                        .friendshipId(saved.getFriendshipId())
                        .userId(saved.getUserId())
                        .friendId(saved.getFriendId())
                        .status(saved.getStatus())
                        .displayName(sender.getDisplayName())
                        .email(sender.getEmail())
                        .createdAt(saved.getCreatedAt())
                        .build())
                );
    }

    @Override
    public Mono<Void> declineRequest(UUID friendshipId, UUID currentUserId) {
        return friendshipsRepository.findById(friendshipId)
                .filter(f -> f.getFriendId().equals(currentUserId))
                .switchIfEmpty(Mono.error(new IllegalStateException("Not authorised")))
                .flatMap(friendshipsRepository::delete);
    }

    @Override
    public Mono<Void> unfriend(UUID userId, UUID friendId) {
        return friendshipsRepository.deleteBetween(userId, friendId);
    }

    @Override
    public Flux<FriendshipDTO.FriendshipResponse> getAcceptedFriends(UUID userId) {
        return friendshipsRepository.findAcceptedFriends(userId)
                .flatMap(f -> {
                    UUID otherId = f.getUserId().equals(userId) ? f.getFriendId() : f.getUserId();
                    return usersRepository.findById(otherId)
                            .map(other -> FriendshipDTO.FriendshipResponse.builder()
                                    .friendshipId(f.getFriendshipId())
                                    .userId(f.getUserId())
                                    .friendId(f.getFriendId())
                                    .status(f.getStatus())
                                    .displayName(other.getDisplayName())
                                    .email(other.getEmail())
                                    .createdAt(f.getCreatedAt())
                                    .build());
                });
    }

    @Override
    public Flux<FriendshipDTO.FriendshipResponse> getIncomingRequests(UUID userId) {
        return friendshipsRepository.findIncomingRequests(userId)
                .flatMap(f -> usersRepository.findById(f.getUserId())
                        .map(sender -> FriendshipDTO.FriendshipResponse.builder()
                                .friendshipId(f.getFriendshipId())
                                .userId(f.getUserId())
                                .friendId(f.getFriendId())
                                .status(f.getStatus())
                                .displayName(sender.getDisplayName())
                                .email(sender.getEmail())
                                .createdAt(f.getCreatedAt())
                                .build()));
    }

    @Override
    public Flux<FriendshipDTO.FriendshipResponse> getOutgoingRequests(UUID userId) {
        return friendshipsRepository.findOutgoingRequests(userId)
                .flatMap(f -> usersRepository.findById(f.getFriendId())
                        .map(target -> FriendshipDTO.FriendshipResponse.builder()
                                .friendshipId(f.getFriendshipId())
                                .userId(f.getUserId())
                                .friendId(f.getFriendId())
                                .status(f.getStatus())
                                .displayName(target.getDisplayName())
                                .email(target.getEmail())
                                .createdAt(f.getCreatedAt())
                                .build()));
    }

    @Override
    public Flux<FriendshipDTO.FriendSearchResult> searchUsers(UUID currentUserId,
                                                               String displayName) {
        return usersRepository.findWithFilters(
                null, displayName, null, null, null,
                null, null, null, null, null, null, null,
                true, "firstName", "ASC", 20, 0
        )
        .filter(u -> !u.getUserId().equals(currentUserId))
        .flatMap(u ->
            friendshipsRepository.findBetween(currentUserId, u.getUserId())
                .map(f -> FriendshipDTO.FriendSearchResult.builder()
                        .userId(u.getUserId())
                        .displayName(u.getDisplayName())
                        .email(u.getEmail())
                        .bio(u.getBio())
                        .friendshipStatus(f.getStatus())
                        .build())
                .switchIfEmpty(Mono.just(
                        FriendshipDTO.FriendSearchResult.builder()
                                .userId(u.getUserId())
                                .displayName(u.getDisplayName())
                                .email(u.getEmail())
                                .bio(u.getBio())
                                .friendshipStatus(null) 
                                .build()
                ))
        );
    }

    private Mono<Void> sendFriendRequestNotification(UUID fromUserId, UUID toUserId) {
        return notificationTypesRepository.findAll()
                .filter(nt -> "FRIEND_REQUEST".equals(nt.getCode()))
                .next()
                .flatMap(type -> notificationsRepository.save(
                        Notifications.builder()
                                .notificationId(UUID.randomUUID())
                                .userId(toUserId)
                                .senderUserId(fromUserId)
                                .notificationTypeId(type.getNotificationTypeId())
                                .title("Friend request")
                                .body("Someone sent you a friend request")
                                .isRead(false)
                                .createdAt(ZonedDateTime.now())
                                .isNewRecord(true)
                                .build()
                ))
                .then();
    }

    private Mono<Void> sendFriendAcceptedNotification(UUID fromUserId, UUID toUserId) {
        return notificationTypesRepository.findAll()
                .filter(nt -> "FRIEND_ACCEPTED".equals(nt.getCode()))
                .next()
                .flatMap(type -> notificationsRepository.save(
                        Notifications.builder()
                                .notificationId(UUID.randomUUID())
                                .userId(toUserId)
                                .senderUserId(fromUserId)
                                .notificationTypeId(type.getNotificationTypeId())
                                .title("Friend request accepted")
                                .body("Your friend request was accepted")
                                .isRead(false)
                                .createdAt(ZonedDateTime.now())
                                .isNewRecord(true)
                                .build()
                ))
                .then();
    }
}