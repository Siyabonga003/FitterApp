package app.run.fitter.social.controller;

import app.run.fitter.social.entity.RunnerLocation;
import app.run.fitter.social.service.FriendService;
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

@RestController
@RequestMapping("/api/live")
public class RunnerLocationController {

    private final RunnerLocationService locationService;
    private final FriendService friendService;

    public RunnerLocationController(RunnerLocationService locationService,
                                    FriendService friendService) {
        this.locationService = locationService;
        this.friendService = friendService;
    }

    @GetMapping("/friends")
    public Mono<ResponseEntity<Flux<RunnerLocation>>> getLiveFriends() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> auth.getName())
                .flatMap(userId -> friendService.getFriendIds(userId))
                .map((List<String> friendIds) -> ResponseEntity.ok(
                        locationService.getLiveFriendLocations(friendIds)
                ));
    }
}