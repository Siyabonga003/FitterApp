package app.run.fitter.app.controller;

import app.run.fitter.activity.dto.ActivitiesDTO;
import app.run.fitter.activity.dto.ActivityStatsDto;
import app.run.fitter.activity.service.ActivitiesService;
import app.run.fitter.constant.ErrorResponse;
import app.run.fitter.constant.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/activities")
@RequiredArgsConstructor
@Validated
@Tag(name = "activities", description = "Endpoints for Activity Tracking & Feed API")
public class ActivitiesController {

    private final ActivitiesService activitiesService;

    @Operation(summary = "Start a run session")
    @PostMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<ActivitiesDTO.ActivityResponse>> createActivity(
            @PathVariable("userId") UUID userId,
            @RequestBody ActivitiesDTO.CreateActivityRequest request
    ) {
        return activitiesService.createActivity(userId, request)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Update live run data")
    @PutMapping("/user/{userId}/{activityId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<ActivitiesDTO.ActivityResponse>> updateActivity(
            @PathVariable("userId") UUID userId,
            @PathVariable("activityId") UUID activityId,
            @RequestBody ActivitiesDTO.UpdateActivityRequest request
    ) {
        return activitiesService.updateActivity(userId, activityId, request)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "End/Complete a run session")
    @PostMapping("/user/{userId}/{activityId}/end")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<ActivitiesDTO.ActivityResponse>> endActivity(
            @PathVariable("userId") UUID userId,
            @PathVariable("activityId") UUID activityId,
            @RequestBody ActivitiesDTO.EndActivityRequest request
    ) {
        return activitiesService.endActivity(userId, activityId, request)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Get run history details")
    @GetMapping("/user/{userId}/{activityId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<ActivitiesDTO.ActivityResponse>> getActivity(
            @PathVariable("userId") UUID userId,
            @PathVariable("activityId") UUID activityId
    ) {
        return activitiesService.getActivity(userId, activityId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }

    @Operation(summary = "Get profile run history list")
    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<PagedResponse<ActivitiesDTO.ActivityResponse>>> getActivities(
            @PathVariable("userId") UUID userId
    ) {
        return activitiesService.getActivities(userId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }

    @Operation(summary = "Get all-time stats for a user")
    @GetMapping("/user/{userId}/stats")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<ActivityStatsDto>> getStats(
        @PathVariable UUID userId) {
    return activitiesService.getStats(userId)
            .map(ResponseEntity::ok);
}
   @Operation(summary = "Get active days this week")
   @GetMapping("/user/{userId}/active-days")
   @PreAuthorize("hasAnyRole('ROLE_USER')")
   public Mono<ResponseEntity<List<Integer>>> getActiveDaysThisWeek(
                @PathVariable UUID userId) {
        return activitiesService.getActiveDaysThisWeek(userId)
                .map(ResponseEntity::ok);
}


}