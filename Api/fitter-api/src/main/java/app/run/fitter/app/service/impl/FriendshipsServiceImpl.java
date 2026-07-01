package app.run.fitter.app.service.impl;

import app.run.fitter.app.dto.FriendshipsDTO;
import app.run.fitter.app.service.FriendshipsService;
import app.run.fitter.constant.PagedResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FriendshipsServiceImpl implements FriendshipsService {
    @Override
    public Mono<PagedResponse<FriendshipsDTO.FriendshipResponse>> getFriendships(UUID userId) {
        return null;
    }

    @Override
    public Mono<FriendshipsDTO.FriendshipResponse> sendFriendRequest(UUID userId, UUID friendId) {
        return null;
    }

    @Override
    public Mono<FriendshipsDTO.FriendshipResponse> acceptFriendRequest(UUID userId, UUID friendId) {
        return null;
    }

    @Override
    public Mono<FriendshipsDTO.FriendshipResponse> declineFriendRequest(UUID userId, UUID friendId) {
        return null;
    }

    @Override
    public Mono<FriendshipsDTO.FriendshipResponse> removeFriend(UUID userId, UUID friendId) {
        return null;
    }

    @Override
    public Mono<PagedResponse<FriendshipsDTO.FriendshipResponse>> getFriendRequests(UUID userId) {
        return null;
    }
}
