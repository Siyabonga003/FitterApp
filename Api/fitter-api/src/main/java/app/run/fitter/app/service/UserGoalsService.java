package app.run.fitter.app.service;

import app.run.fitter.app.dto.UserGoalsDTO;
import app.run.fitter.constant.PagedResponse;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface UserGoalsService {
    Mono<UserGoalsDTO.UserGoalResponse> createUserGoal(UUID userId, UserGoalsDTO.CreateUserGoalRequest createUserGoalRequest);

    Mono<UserGoalsDTO.UserGoalResponse> updateUserGoal(UUID userId, UserGoalsDTO.UpdateUserGoalRequest updateUserGoalRequest);

    Mono<PagedResponse<UserGoalsDTO>> getUserGoals(UUID userId);

    Mono<Void> deleteUserGoal(UUID userId, UUID goalId);
}
