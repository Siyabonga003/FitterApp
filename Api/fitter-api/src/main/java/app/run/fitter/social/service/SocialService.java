package app.run.fitter.social.service;

import app.run.fitter.constant.PagedResponse;
import app.run.fitter.social.dto.SocialDTO;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface SocialService {
    Mono<SocialDTO.ReactionSummaryResponse> toggleReaction(UUID activityId, String reactionCode);
    Mono<SocialDTO.ReactionSummaryResponse> getReactionSummary(UUID activityId);
    Mono<SocialDTO.CommentResponse> addComment(UUID activityId, String content);
    Mono<PagedResponse<SocialDTO.CommentResponse>> getComments(UUID activityId, int page, int size);
    Mono<Void> deleteComment(UUID activityId, UUID commentId);
}