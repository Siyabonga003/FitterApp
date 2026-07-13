package app.run.fitter.app.controller;

import app.run.fitter.app.dto.FriendshipDTO;
import app.run.fitter.app.service.FriendshipService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
@Tag(name = "friends", description = "Friend request and social connection endpoints")
public class FriendshipController {

    private final FriendshipService friendshipService;

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<List<FriendshipDTO.FriendSearchResult>>> searchUsers(
            @RequestParam String displayName) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId ->
                        friendshipService.searchUsers(userId, displayName).collectList())
                .map(ResponseEntity::ok);
    }

    // Send a friend request
    @PostMapping("/request/{toUserId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<FriendshipDTO.FriendshipResponse>> sendRequest(
            @PathVariable UUID toUserId) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.sendRequest(userId, toUserId))
                .map(ResponseEntity::ok);
    }

    // Accept an incoming request
    @PostMapping("/accept/{friendshipId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<FriendshipDTO.FriendshipResponse>> acceptRequest(
            @PathVariable UUID friendshipId) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.acceptRequest(friendshipId, userId))
                .map(ResponseEntity::ok);
    }

    // Decline an incoming request
    @DeleteMapping("/decline/{friendshipId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<Void>> declineRequest(
            @PathVariable UUID friendshipId) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.declineRequest(friendshipId, userId))
                .thenReturn(ResponseEntity.<Void>ok().build());
    }

    // Unfriend / withdraw a sent request
    @DeleteMapping("/unfriend/{friendId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<Void>> unfriend(@PathVariable UUID friendId) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.unfriend(userId, friendId))
                .thenReturn(ResponseEntity.<Void>ok().build());
    }

    // Get accepted friends list
    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<List<FriendshipDTO.FriendshipResponse>>> getFriends() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.getAcceptedFriends(userId).collectList())
                .map(ResponseEntity::ok);
    }

    // Get incoming pending requests
    @GetMapping("/requests/incoming")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<List<FriendshipDTO.FriendshipResponse>>> getIncomingRequests() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.getIncomingRequests(userId).collectList())
                .map(ResponseEntity::ok);
    }

    // Get outgoing pending requests
    @GetMapping("/requests/outgoing")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<List<FriendshipDTO.FriendshipResponse>>> getOutgoingRequests() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> UUID.fromString(auth.getName()))
                .flatMap(userId -> friendshipService.getOutgoingRequests(userId).collectList())
                .map(ResponseEntity::ok);
    }
}