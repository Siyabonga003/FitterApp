package app.run.fitter.social.controller;

import app.run.fitter.app.service.FriendshipService;
import app.run.fitter.social.entity.RunnerLocation;
import app.run.fitter.social.service.RunnerLocationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/live")
public class RunnerLocationController {

    private final RunnerLocationService locationService;
    private final FriendshipService friendshipService;

    public RunnerLocationController(RunnerLocationService locationService,
                                    FriendshipService friendshipService) {
        this.locationService = locationService;
        this.friendshipService = friendshipService;
    }

    @GetMapping("/friends")
    public Mono<ResponseEntity<Flux<RunnerLocation>>> getLiveFriends() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> auth.getName())
                .flatMap(userId -> {
                    System.out.println("DEBUG current userId: " + userId);
                    return friendshipService.getAcceptedFriends(UUID.fromString(userId))
                            .doOnNext(f -> System.out.println("DEBUG friendship: userId=" + f.getUserId() + " friendId=" + f.getFriendId()))
                            .map(f -> {
                                String other = userId.equals(f.getUserId().toString())
                                        ? f.getFriendId().toString()
                                        : f.getUserId().toString();
                                System.out.println("DEBUG resolved friendId: " + other);
                                return other;
                            })
                            .collectList()
                            .doOnNext(ids -> System.out.println("DEBUG final friendIds list: " + ids));
                })
                .map(friendIds -> ResponseEntity.ok(
                        locationService.getLiveFriendLocations(friendIds)
                ));
    }

    @GetMapping("/presence")
    public Mono<ResponseEntity<Flux<RunnerLocation>>> getLivePresence() {
        return Mono.just(ResponseEntity.ok(
                locationService.getAllLivePresence()
        ));
    }

    @GetMapping("/presence/count")
    public Mono<ResponseEntity<Long>> getLiveCount() {
        return locationService.getLivePresenceCount()
                .map(ResponseEntity::ok);
    }
    
}