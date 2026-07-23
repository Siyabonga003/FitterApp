package app.run.fitter.social.service.impl;

import app.run.fitter.activity.entity.Activities;
import app.run.fitter.activity.repository.ActivitiesRepository;
import app.run.fitter.app.entity.Users;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.exception.BadRequestException;
import app.run.fitter.exception.ForbiddenException;
import app.run.fitter.exception.ResourceNotFoundException;
import app.run.fitter.lookup.entity.Reactions;
import app.run.fitter.lookup.repository.ReactionsRepository;
import app.run.fitter.notification.service.NotificationsService;
import app.run.fitter.social.dto.SocialDTO;
import app.run.fitter.social.entity.FeedPosts;
import app.run.fitter.social.entity.PostComments;
import app.run.fitter.social.entity.PostReactions;
import app.run.fitter.social.repository.FeedPostsRepository;
import app.run.fitter.social.repository.PostCommentsRepository;
import app.run.fitter.social.repository.PostReactionsRepository;
import app.run.fitter.social.service.SocialService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SocialServiceImpl implements SocialService {

    private final FeedPostsRepository feedPostsRepository;
    private final PostReactionsRepository postReactionsRepository;
    private final PostCommentsRepository postCommentsRepository;
    private final ReactionsRepository reactionsRepository;
    private final UsersRepository usersRepository;
    private final ActivitiesRepository activitiesRepository;
    private final NotificationsService notificationsService;

    @Override
    public Mono<SocialDTO.ReactionSummaryResponse> toggleReaction(UUID activityId, String reactionCode) {
        return Mono.zip(findOrCreatePost(activityId), getCurrentUserId(), resolveReaction(reactionCode))
                .flatMap(tuple -> {
                    FeedPosts post = tuple.getT1();
                    UUID userId = tuple.getT2();
                    Reactions reaction = tuple.getT3();

                    return postReactionsRepository
                            .findByPostIdAndUserIdAndReactionId(post.getPostId(), userId, reaction.getReactionId())
                            .flatMap(existing -> postReactionsRepository.delete(existing).thenReturn(false))
                            .switchIfEmpty(Mono.defer(() -> {
                                PostReactions newReaction = PostReactions.builder()
                                        .postReactionId(UUID.randomUUID())
                                        .postId(post.getPostId())
                                        .userId(userId)
                                        .reactionId(reaction.getReactionId())
                                        .createdAt(ZonedDateTime.now())
                                        .isNewRecord(true)
                                        .build();
                                return postReactionsRepository.save(newReaction).thenReturn(true);
                            }))
                            .flatMap(wasAdded -> {
                                if (wasAdded) {
                                    sendReactionNotification(post, userId, reaction.getCode());
                                }
                                return buildReactionSummary(post.getPostId(), userId);
                            });
                });
    }

    @Override
    public Mono<SocialDTO.ReactionSummaryResponse> getReactionSummary(UUID activityId) {
        return Mono.zip(findOrCreatePost(activityId), getCurrentUserId())
                .flatMap(tuple -> buildReactionSummary(tuple.getT1().getPostId(), tuple.getT2()));
    }

    @Override
    public Mono<SocialDTO.CommentResponse> addComment(UUID activityId, String content) {
        return Mono.zip(findOrCreatePost(activityId), getCurrentUserId())
                .flatMap(tuple -> {
                    FeedPosts post = tuple.getT1();
                    UUID userId = tuple.getT2();

                    PostComments comment = PostComments.builder()
                            .commentId(UUID.randomUUID())
                            .postId(post.getPostId())
                            .userId(userId)
                            .content(content)
                            .isDeleted(false)
                            .createdAt(ZonedDateTime.now())
                            .isNewRecord(true)
                            .build();

                    return postCommentsRepository.save(comment)
                            .flatMap(saved -> usersRepository.findById(userId)
                                    .map(u -> {
                                        sendCommentNotification(post, userId);
                                        return SocialDTO.CommentResponse.builder()
                                                .commentId(saved.getCommentId())
                                                .userId(userId)
                                                .displayName(u.getDisplayName())
                                                .profilePicUrl(u.getProfilePictureUrl())
                                                .content(saved.getContent())
                                                .createdAt(saved.getCreatedAt())
                                                .build();
                                    }));
                });
    }

    @Override
    public Mono<PagedResponse<SocialDTO.CommentResponse>> getComments(UUID activityId, int page, int size) {
        return findOrCreatePost(activityId).flatMap(post ->
                postCommentsRepository.findByPostIdAndIsDeletedFalse(post.getPostId(), size, page * size)
                        .collectList()
                        .flatMap(comments -> {
                            List<UUID> userIds = comments.stream()
                                    .map(PostComments::getUserId)
                                    .distinct()
                                    .collect(Collectors.toList());

                            return usersRepository.findAllById(userIds)
                                    .collectMap(Users::getUserId)
                                    .map(usersById -> {
                                        List<SocialDTO.CommentResponse> responses = comments.stream()
                                                .map(c -> {
                                                    Users u = usersById.get(c.getUserId());
                                                    return SocialDTO.CommentResponse.builder()
                                                            .commentId(c.getCommentId())
                                                            .userId(c.getUserId())
                                                            .displayName(u != null ? u.getDisplayName() : "Unknown")
                                                            .profilePicUrl(u != null ? u.getProfilePictureUrl() : null)
                                                            .content(c.getContent())
                                                            .createdAt(c.getCreatedAt())
                                                            .build();
                                                })
                                                .collect(Collectors.toList());

                                        return PagedResponse.<SocialDTO.CommentResponse>builder()
                                                .content(responses)
                                                .build();
                                    });
                        }));
    }

    @Override
    public Mono<Void> deleteComment(UUID activityId, UUID commentId) {
        return Mono.zip(findOrCreatePost(activityId), getCurrentUserId())
                .flatMap(tuple -> postCommentsRepository.findById(commentId)
                        .switchIfEmpty(Mono.error(new ResourceNotFoundException("Comment", commentId.toString())))
                        .flatMap(comment -> {
                            if (!comment.getUserId().equals(tuple.getT2())) {
                                return Mono.error(new ForbiddenException("You can only delete your own comments."));
                            }
                            comment.setIsDeleted(true);
                            comment.setDeletedAt(ZonedDateTime.now());
                            comment.setNewRecord(false);
                            return postCommentsRepository.save(comment);
                        }))
                .then();
    }

    private Mono<FeedPosts> findOrCreatePost(UUID activityId) {
        return feedPostsRepository.findByActivityId(activityId)
                .switchIfEmpty(Mono.defer(() -> activitiesRepository.findById(activityId)
                        .switchIfEmpty(Mono.error(new ResourceNotFoundException("Activity", activityId.toString())))
                        .flatMap(this::createPostForActivity)));
    }

    private Mono<FeedPosts> createPostForActivity(Activities activity) {
        FeedPosts post = FeedPosts.builder()
                .postId(UUID.randomUUID())
                .userId(activity.getUserId())
                .activityId(activity.getActivityId())
                .visibilityId(activity.getVisibilityId())
                .isDeleted(false)
                .createdAt(ZonedDateTime.now())
                .isNewRecord(true)
                .build();
        return feedPostsRepository.save(post);
    }

    private Mono<SocialDTO.ReactionSummaryResponse> buildReactionSummary(UUID postId, UUID currentUserId) {
        return postReactionsRepository.findByPostId(postId)
                .collectList()
                .flatMap(reactions -> Mono.zip(
                        reactionsRepository.findByCode("LIKE"),
                        reactionsRepository.findByCode("CHEER")
                ).map(codes -> {
                    Short likeId = codes.getT1().getReactionId();
                    Short cheerId = codes.getT2().getReactionId();

                    long likeCount = reactions.stream().filter(r -> likeId.equals(r.getReactionId())).count();
                    long cheerCount = reactions.stream().filter(r -> cheerId.equals(r.getReactionId())).count();
                    boolean userLiked = reactions.stream()
                            .anyMatch(r -> likeId.equals(r.getReactionId()) && currentUserId.equals(r.getUserId()));
                    boolean userCheered = reactions.stream()
                            .anyMatch(r -> cheerId.equals(r.getReactionId()) && currentUserId.equals(r.getUserId()));

                    return SocialDTO.ReactionSummaryResponse.builder()
                            .likeCount(likeCount)
                            .cheerCount(cheerCount)
                            .currentUserLiked(userLiked)
                            .currentUserCheered(userCheered)
                            .build();
                }));
    }

    private void sendReactionNotification(FeedPosts post, UUID reactorId, String reactionCode) {
        if (post.getUserId().equals(reactorId)) return;

        String verb = "CHEER".equals(reactionCode) ? "cheered on" : "liked";

        usersRepository.findById(reactorId)
                .flatMap(reactor -> notificationsService.notify(
                        post.getUserId(),
                        reactorId,
                        "REACTION",
                        "New reaction",
                        reactor.getDisplayName() + " " + verb + " your activity",
                        String.format("{\"activityId\":\"%s\"}", post.getActivityId())
                ))
                .onErrorResume(e -> Mono.empty())
                .subscribe();
    }

    private void sendCommentNotification(FeedPosts post, UUID commenterId) {
        if (post.getUserId().equals(commenterId)) return;

        usersRepository.findById(commenterId)
                .flatMap(commenter -> notificationsService.notify(
                        post.getUserId(),
                        commenterId,
                        "COMMENT",
                        "New comment",
                        commenter.getDisplayName() + " commented on your activity",
                        String.format("{\"activityId\":\"%s\"}", post.getActivityId())
                ))
                .onErrorResume(e -> Mono.empty())
                .subscribe();
    }

    private Mono<Reactions> resolveReaction(String code) {
        String normalized = code == null ? "" : code.toUpperCase();
        return reactionsRepository.findByCode(normalized)
                .switchIfEmpty(Mono.error(new BadRequestException("Unknown reaction code: " + code)));
    }

    private Mono<UUID> getCurrentUserId() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(Authentication::getPrincipal)
                .cast(Jwt.class)
                .map(jwt -> UUID.fromString(jwt.getSubject()));
    }
}