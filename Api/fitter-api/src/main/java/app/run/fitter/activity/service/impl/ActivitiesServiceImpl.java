package app.run.fitter.activity.service.impl;

import app.run.fitter.activity.dto.ActivitiesDTO;
import app.run.fitter.activity.entity.Activities;
import app.run.fitter.activity.repository.ActivitiesRepository;
import app.run.fitter.activity.service.ActivitiesService;
import app.run.fitter.activity.dto.ActivityStatsDto;
import app.run.fitter.app.entity.Friendships;
import app.run.fitter.app.entity.Users;
import app.run.fitter.app.repository.FriendshipsRepository;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.gamification.service.BadgeEvaluationService;
import app.run.fitter.lookup.repository.ReactionsRepository;
import app.run.fitter.notification.service.NotificationsService;
import app.run.fitter.social.entity.PostReactions;
import app.run.fitter.social.repository.FeedPostsRepository;
import app.run.fitter.social.repository.PostCommentsRepository;
import app.run.fitter.social.repository.PostReactionsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import java.time.ZonedDateTime;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
public class ActivitiesServiceImpl implements ActivitiesService {

    private final ActivitiesRepository activitiesRepository;
    private final BadgeEvaluationService badgeEvaluationService;
    private final UsersRepository usersRepository;
    private final FeedPostsRepository feedPostsRepository;
    private final PostReactionsRepository postReactionsRepository;
    private final PostCommentsRepository postCommentsRepository;
    private final ReactionsRepository reactionsRepository;
    private final FriendshipsRepository friendshipsRepository;
    private final NotificationsService notificationsService;

    @Override
    public Mono<ActivitiesDTO.ActivityResponse> createActivity(UUID userId,
            ActivitiesDTO.CreateActivityRequest request) {
        Activities activity = Activities.builder()
                .userId(userId)
                .activityTypeId(request.getActivityTypeId())
                .startedAt(request.getStartedAt())
                .visibilityId(request.getVisibilityId())
                .routeVisible(request.getRouteVisible())
                .isLive(request.getIsLive())
                .isDeleted(false)
                .createdAt(ZonedDateTime.now())
                .updatedAt(ZonedDateTime.now())
                .isNew(true)
                .build();

        return activitiesRepository.save(activity)
                .doOnSuccess(saved -> {
                    if (Boolean.TRUE.equals(saved.getIsLive())) {
                        notifyFriends(userId, "FRIEND_STARTED_RUN", "Live run started",
                                " started a live run", saved.getActivityId());
                    }
                })
                .map(this::toResponse);
    }

    @Override
    public Mono<ActivitiesDTO.ActivityResponse> updateActivity(UUID userId,
            UUID activityId,
            ActivitiesDTO.UpdateActivityRequest request) {
        return activitiesRepository.findById(activityId)
                .flatMap(existing -> {
                    if (request.getDurationSec() != null)
                        existing.setDurationSec(request.getDurationSec());
                    if (request.getAvgPaceSecPerKm() != null)
                        existing.setAvgPaceSecPerKm(request.getAvgPaceSecPerKm());
                    if (request.getAvgSpeedKmh() != null)
                        existing.setAvgSpeedKmh(request.getAvgSpeedKmh());
                    if (request.getRouteGeoJson() != null)
                        existing.setRouteGeoJson(request.getRouteGeoJson());
                    if (request.getStartLat() != null)
                        existing.setStartLat(request.getStartLat());
                    if (request.getStartLng() != null)
                        existing.setStartLng(request.getStartLng());
                    if (request.getEndLat() != null)
                        existing.setEndLat(request.getEndLat());
                    if (request.getEndLng() != null)
                        existing.setEndLng(request.getEndLng());
                    if (request.getRouteVisible() != null)
                        existing.setRouteVisible(request.getRouteVisible());
                    if (request.getVisibilityId() != null)
                        existing.setVisibilityId(request.getVisibilityId());
                    if (request.getIsLive() != null)
                        existing.setIsLive(request.getIsLive());
                    if (request.getNotes() != null)
                        existing.setNotes(request.getNotes());
                    existing.setUpdatedAt(ZonedDateTime.now());
                    return activitiesRepository.save(existing);
                })
                .map(this::toResponse);
    }

    @Override
    public Mono<ActivitiesDTO.ActivityResponse> endActivity(UUID userId,
            UUID activityId,
            ActivitiesDTO.EndActivityRequest request) {
        return activitiesRepository.findById(activityId)
                .flatMap(existing -> {
                    existing.setEndedAt(request.getEndedAt());
                    existing.setDistanceKm(request.getDistanceKm());
                    existing.setCalories(request.getCalories());
                    existing.setIsLive(false);
                    existing.setUpdatedAt(ZonedDateTime.now());
                    return activitiesRepository.save(existing);
                })
                .flatMap(saved -> {
                    badgeEvaluationService
                            .evaluateAndAward(userId)
                            .subscribe();

                    notifyFriends(userId, "ACTIVITY_POSTED", "New activity",
                            " logged a new activity", saved.getActivityId());

                    return Mono.just(toResponse(saved));
                });
    }

    @Override
    public Mono<ActivitiesDTO.ActivityResponse> deleteActivity(UUID userId, UUID activityId) {
        return activitiesRepository.findById(activityId)
                .flatMap(existing -> {
                    existing.setIsDeleted(true);
                    existing.setDeletedAt(ZonedDateTime.now());
                    existing.setUpdatedAt(ZonedDateTime.now());
                    return activitiesRepository.save(existing);
                })
                .map(this::toResponse);
    }

    @Override
    public Mono<ActivitiesDTO.ActivityResponse> getActivity(UUID userId, UUID activityId) {
        return activitiesRepository.findById(activityId)
                .map(this::toResponse);
    }

    @Override
    public Mono<PagedResponse<ActivitiesDTO.ActivityResponse>> getActivities(UUID userId) {
        return activitiesRepository.findByUserIdAndIsDeletedFalse(userId)
                .map(this::toResponse)
                .collectList()
                .map(list -> PagedResponse.<ActivitiesDTO.ActivityResponse>builder()
                        .content(list)
                        .build());
    }

    @Override
    public Mono<PagedResponse<ActivitiesDTO.ActivityResponse>> getPublicActivities(UUID userId) {
        return activitiesRepository.findAllPublicActivities()
                .map(this::toResponse)
                .collectList()
                .map(list -> PagedResponse.<ActivitiesDTO.ActivityResponse>builder()
                        .content(list)
                        .build());
    }

    @Override
    public Mono<PagedResponse<ActivitiesDTO.FeedActivityResponse>> getFriendsFeed(UUID userId, int page, int size) {
        int offset = page * size;

        return activitiesRepository.findFriendsFeed(userId, size, offset)
                .collectList()
                .flatMap(activities -> {
                    List<UUID> posterIds = activities.stream()
                            .map(Activities::getUserId)
                            .distinct()
                            .collect(Collectors.toList());

                    return usersRepository.findAllById(posterIds)
                            .collectMap(Users::getUserId)
                            .flatMap(usersById -> Flux.fromIterable(activities)
                                    .flatMap(a -> enrichActivity(a, usersById.get(a.getUserId()), userId))
                                    .collectList()
                                    .map(responses -> PagedResponse.<ActivitiesDTO.FeedActivityResponse>builder()
                                            .content(responses)
                                            .build()));
                });
    }

    private Mono<ActivitiesDTO.FeedActivityResponse> enrichActivity(Activities a, Users poster, UUID currentUserId) {
        ActivitiesDTO.FeedActivityResponse.FeedActivityResponseBuilder builder = ActivitiesDTO.FeedActivityResponse.builder()
                .activityId(a.getActivityId())
                .userId(a.getUserId())
                .displayName(poster != null ? poster.getDisplayName() : "Unknown")
                .profilePicUrl(poster != null ? poster.getProfilePictureUrl() : null)
                .activityTypeId(a.getActivityTypeId())
                .startedAt(a.getStartedAt())
                .endedAt(a.getEndedAt())
                .durationSec(a.getDurationSec())
                .distanceKm(a.getDistanceKm())
                .avgPaceSecPerKm(a.getAvgPaceSecPerKm())
                .avgSpeedKmh(a.getAvgSpeedKmh())
                .calories(a.getCalories())
                .routeGeoJson(a.getRouteGeoJson())
                .startLat(a.getStartLat())
                .startLng(a.getStartLng())
                .endLat(a.getEndLat())
                .endLng(a.getEndLng())
                .notes(a.getNotes());

        return feedPostsRepository.findByActivityId(a.getActivityId())
                .flatMap(post -> Mono.zip(
                                postReactionsRepository.findByPostId(post.getPostId()).collectList(),
                                postCommentsRepository.countByPostIdAndIsDeletedFalse(post.getPostId()),
                                reactionsRepository.findByCode("LIKE"),
                                reactionsRepository.findByCode("CHEER")
                        )
                        .map(tuple -> {
                            List<PostReactions> reactions = tuple.getT1();
                            long commentCount = tuple.getT2();
                            Short likeId = tuple.getT3().getReactionId();
                            Short cheerId = tuple.getT4().getReactionId();

                            long likeCount = reactions.stream().filter(r -> likeId.equals(r.getReactionId())).count();
                            long cheerCount = reactions.stream().filter(r -> cheerId.equals(r.getReactionId())).count();
                            boolean userLiked = reactions.stream()
                                    .anyMatch(r -> likeId.equals(r.getReactionId()) && currentUserId.equals(r.getUserId()));
                            boolean userCheered = reactions.stream()
                                    .anyMatch(r -> cheerId.equals(r.getReactionId()) && currentUserId.equals(r.getUserId()));

                            return builder
                                    .likeCount(likeCount)
                                    .cheerCount(cheerCount)
                                    .commentCount(commentCount)
                                    .currentUserLiked(userLiked)
                                    .currentUserCheered(userCheered)
                                    .build();
                        }))
                .switchIfEmpty(Mono.just(builder
                        .likeCount(0).cheerCount(0).commentCount(0)
                        .currentUserLiked(false).currentUserCheered(false)
                        .build()));
    }

    private ActivitiesDTO.ActivityResponse toResponse(Activities a) {
        return ActivitiesDTO.ActivityResponse.builder()
                .activityId(a.getActivityId())
                .userId(a.getUserId())
                .activityTypeId(a.getActivityTypeId())
                .startedAt(a.getStartedAt())
                .endedAt(a.getEndedAt())
                .durationSec(a.getDurationSec())
                .distanceKm(a.getDistanceKm())
                .avgPaceSecPerKm(a.getAvgPaceSecPerKm())
                .avgSpeedKmh(a.getAvgSpeedKmh())
                .calories(a.getCalories())
                .routeGeoJson(a.getRouteGeoJson())
                .startLat(a.getStartLat())
                .startLng(a.getStartLng())
                .endLat(a.getEndLat())
                .endLng(a.getEndLng())
                .routeVisible(a.getRouteVisible())
                .visibilityId(a.getVisibilityId())
                .isLive(a.getIsLive())
                .notes(a.getNotes())
                .isDeleted(a.getIsDeleted())
                .deletedAt(a.getDeletedAt())
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    @Override
    public Mono<ActivityStatsDto> getStats(UUID userId) {
        return activitiesRepository.findStatsByUserId(userId)
                .map(p -> new ActivityStatsDto(
                        p.totalDistanceKm(),
                        p.totalDurationSec(),
                        p.totalCalories(),
                        p.totalSessions()
                ))
                .defaultIfEmpty(new ActivityStatsDto(
                        BigDecimal.ZERO, 0, 0, 0L
                ));
    }

    @Override
    public Mono<List<Integer>> getActiveDaysThisWeek(UUID userId) {
        return activitiesRepository.findActiveDaysThisWeek(userId)
                .collectList();
    }

    private void notifyFriends(UUID posterId, String typeCode, String title, String bodySuffix, UUID activityId) {
        usersRepository.findById(posterId)
                .flatMapMany(poster -> friendshipsRepository.findAcceptedFriends(posterId)
                        .map(f -> f.getUserId().equals(posterId) ? f.getFriendId() : f.getUserId())
                        .flatMap(friendId -> notificationsService.notify(
                                friendId,
                                posterId,
                                typeCode,
                                title,
                                poster.getDisplayName() + bodySuffix,
                                String.format("{\"activityId\":\"%s\"}", activityId)
                        )))
                .onErrorResume(e -> {
                    log.warn("Failed to notify friends of {} for activity {}: {}", typeCode, activityId, e.getMessage());
                    return Mono.empty();
                })
                .subscribe();
    }
}