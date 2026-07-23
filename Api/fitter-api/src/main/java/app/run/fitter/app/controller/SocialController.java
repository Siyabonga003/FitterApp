package app.run.fitter.app.controller;

import app.run.fitter.constant.PagedResponse;
import app.run.fitter.social.dto.SocialDTO;
import app.run.fitter.social.service.SocialService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/activities/{activityId}")
@RequiredArgsConstructor
public class SocialController {

    private final SocialService socialService;

    @PostMapping("/reactions")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<SocialDTO.ReactionSummaryResponse> toggleReaction(
            @PathVariable UUID activityId,
            @RequestBody SocialDTO.ReactRequest request
    ) {
        return socialService.toggleReaction(activityId, request.getReactionCode());
    }

    @GetMapping("/reactions/summary")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<SocialDTO.ReactionSummaryResponse> getReactionSummary(@PathVariable UUID activityId) {
        return socialService.getReactionSummary(activityId);
    }

    @PostMapping("/comments")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<SocialDTO.CommentResponse> addComment(
            @PathVariable UUID activityId,
            @RequestBody SocialDTO.CommentRequest request
    ) {
        return socialService.addComment(activityId, request.getContent());
    }

    @GetMapping("/comments")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<PagedResponse<SocialDTO.CommentResponse>> getComments(
            @PathVariable UUID activityId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return socialService.getComments(activityId, page, size);
    }

    @DeleteMapping("/comments/{commentId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<Void> deleteComment(
            @PathVariable UUID activityId,
            @PathVariable UUID commentId
    ) {
        return socialService.deleteComment(activityId, commentId);
    }
}