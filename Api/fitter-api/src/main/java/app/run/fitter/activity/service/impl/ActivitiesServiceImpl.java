package app.run.fitter.activity.service.impl;

import app.run.fitter.activity.dto.ActivitiesDTO;
import app.run.fitter.activity.entity.Activities;
import app.run.fitter.activity.repository.ActivitiesRepository;
import app.run.fitter.activity.service.ActivitiesService;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.gamification.service.BadgeEvaluationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.Collections;
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
                .activityId(UUID.randomUUID())
                .userId(userId)
                .activityTypeId(request.getActivityTypeId())
                .startedAt(request.getStartedAt())
                .visibilityId(request.getVisibilityId())
                .routeVisible(request.getRouteVisible())
                .isLive(request.getIsLive())
                .isDeleted(false)
                .createdAt(ZonedDateTime.now())
                .updatedAt(ZonedDateTime.now())
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
                    // Only update fields that were provided in the request
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
                    // Mark activity as ended
                    existing.setEndedAt(request.getEndedAt());
                    existing.setDistanceKm(request.getDistanceKm());
                    existing.setCalories(request.getCalories());
                    existing.setIsLive(false); // no longer live once ended
                    existing.setUpdatedAt(ZonedDateTime.now());
                    return activitiesRepository.save(existing);
                })
                .flatMap(saved -> {
                    // Fire badge evaluation in background after activity is saved.
                    // subscribe() makes it fire-and-forget so the response returns
                    // immediately without waiting for badge checks to complete.
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
        return activitiesRepository.findAll()
                .filter(a -> a.getUserId().equals(userId) && !Boolean.TRUE.equals(a.getIsDeleted()))
                .map(this::toResponse)