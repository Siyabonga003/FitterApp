package app.run.fitter.app.service;

import app.run.fitter.app.dto.FriendshipsDTO;
import app.run.fitter.constant.PagedResponse;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface FriendshipsService {
    Mono<PagedResponse<FriendshipsDTO.FriendshipResponse>> getFriendships(UUID userId);

    Mono<FriendshipsDTO.FriendshipResponse> sendFriendRequest(UUID userId, UUID friendId);

    Mono<FriendshipsDTO.FriendshipResponse> acceptFriendRequest(UUID userId, UUID friendId);

    Mono<FriendshipsDTO.FriendshipResponse> declineFriendRequest(UUID userId, UUID friendId);

    Mono<FriendshipsDTO.FriendshipResponse> removeFriend(UUID userId, UUID friendId);

    Mono<PagedResponse<FriendshipsDTO.FriendshipResponse>> getFriendRequests(UUID userId);
}
