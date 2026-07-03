package app.run.fitter.activity.service.impl;

import app.run.fitter.activity.dto.ActivitiesDTO;
import app.run.fitter.activity.entity.Activities;
import app.run.fitter.activity.repository.ActivitiesRepository;
import app.run.fitter.activity.service.ActivitiesService;
import app.run.fitter.activity.dto.ActivityStatsDto;
import app.run.fitter.activity.repository.ActivityStatsProjection;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.gamification.service.BadgeEvaluationService;
import app.run.fitter.activity.entity.JsonbValue;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;
import java.math.BigDecimal;
import java.util.List;

import java.time.ZonedDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ActivitiesServiceImpl implements ActivitiesService {

    private final ActivitiesRepository activitiesRepository;
    private final BadgeEvaluationService badgeEvaluationService;

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
                        existing.setRouteGeoJson(JsonbValue.of(request.getRouteGeoJson()));
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
                .routeGeoJson(a.getRouteGeoJson() != null ? a.getRouteGeoJson().value() : null)
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
} 