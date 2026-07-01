package app.run.fitter.gamification.controller;

import app.run.fitter.gamification.dto.BadgeDto;
import app.run.fitter.gamification.repository.BadgeAwardedView;
import app.run.fitter.gamification.repository.BadgesAwardedRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/badges")
public class BadgeController {

    private final BadgesAwardedRepository badgesAwardedRepository;

    public BadgeController(BadgesAwardedRepository badgesAwardedRepository) {
        this.badgesAwardedRepository = badgesAwardedRepository;
    }

    @GetMapping
    public Mono<ResponseEntity<Flux<BadgeDto>>> getMyBadges() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> auth.getName())
                .map(userId -> ResponseEntity.ok(
                        badgesAwardedRepository.findAllByUserId(UUID.fromString(userId))
                                .map(view -> new BadgeDto(
                                        view.code(),
                                        view.name(),
                                        view.description(),
                                        view.awardedAt(),
                                        false 
                                ))
                ));
    }
}