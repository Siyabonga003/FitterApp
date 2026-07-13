package app.run.fitter.app.service;

import app.run.fitter.app.dto.FriendshipDTO;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface FriendshipService {
    Mono<FriendshipDTO.FriendshipResponse> sendRequest(UUID fromUserId, UUID toUserId);
    Mono<FriendshipDTO.FriendshipResponse> acceptRequest(UUID friendshipId, UUID currentUserId);
    Mono<Void> declineRequest(UUID friendshipId, UUID currentUserId);
    Mono<Void> unfriend(UUID userId, UUID friendId);
    Flux<FriendshipDTO.FriendshipResponse> getAcceptedFriends(UUID userId);
    Flux<FriendshipDTO.FriendshipResponse> getIncomingRequests(UUID userId);
    Flux<FriendshipDTO.FriendshipResponse> getOutgoingRequests(UUID userId);
    Flux<FriendshipDTO.FriendSearchResult> searchUsers(UUID currentUserId, String displayName);
}