package app.run.fitter.activity.service;

import app.run.fitter.activity.dto.ActivitiesDTO;
import app.run.fitter.activity.dto.ActivityStatsDto;
import app.run.fitter.constant.PagedResponse;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

public interface ActivitiesService {
    Mono<ActivitiesDTO.ActivityResponse> createActivity(UUID userId, ActivitiesDTO.CreateActivityRequest createActivityRequest);

    Mono<ActivitiesDTO.ActivityResponse> updateActivity(UUID userId, UUID activityId, ActivitiesDTO.UpdateActivityRequest updateActivityRequest);

    Mono<ActivitiesDTO.ActivityResponse> endActivity(UUID userId, UUID activityId, ActivitiesDTO.EndActivityRequest endActivityRequest);

    Mono<ActivitiesDTO.ActivityResponse> deleteActivity(UUID userId, UUID activityId);

    Mono<ActivitiesDTO.ActivityResponse> getActivity(UUID userId, UUID activityId);

    Mono<PagedResponse<ActivitiesDTO.ActivityResponse>> getActivities(UUID userId);

    Mono<PagedResponse<ActivitiesDTO.ActivityResponse>> getPublicActivities(UUID userId);

    Mono<ActivityStatsDto> getStats(UUID userId);

    Mono<List<Integer>> getActiveDaysThisWeek(UUID userId);

    Mono<PagedResponse<ActivitiesDTO.FeedActivityResponse>> getFriendsFeed(UUID userId, int page, int size);
}
