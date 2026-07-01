package app.run.fitter.app.service.impl;

import app.run.fitter.app.dto.UserGoalsDTO;
import app.run.fitter.app.service.UserGoalsService;
import app.run.fitter.constant.PagedResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserGoalsServiceImpl implements UserGoalsService {
    @Override
    public Mono<UserGoalsDTO.UserGoalResponse> createUserGoal(UUID userId, UserGoalsDTO.CreateUserGoalRequest createUserGoalRequest) {
        return null;
    }

    @Override
    public Mono<UserGoalsDTO.UserGoalResponse> updateUserGoal(UUID userId, UserGoalsDTO.UpdateUserGoalRequest updateUserGoalRequest) {
        return null;
    }

    @Override
    public Mono<PagedResponse<UserGoalsDTO>> getUserGoals(UUID userId) {
        return null;
    }

    @Override
    public Mono<Void> deleteUserGoal(UUID userId, UUID goalId) {
        return null;
    }
}
