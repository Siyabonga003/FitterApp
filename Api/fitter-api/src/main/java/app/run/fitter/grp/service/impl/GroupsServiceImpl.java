package app.run.fitter.grp.service.impl;

import app.run.fitter.app.dto.GroupsDTO;
import app.run.fitter.grp.repository.GroupMembersRepository;
import app.run.fitter.grp.repository.GroupsRepository;
import app.run.fitter.grp.service.GroupsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class GroupsServiceImpl implements GroupsService {

    private final GroupsRepository groupsRepository;
    private final GroupMembersRepository groupMembersRepository;

    @Override
    public Flux<GroupsDTO.GroupResponse> getAllActiveGroups() {
        return groupsRepository.findAll()
                // 1️⃣ Filter to only stream out groups where isActive is true
                .filter(group -> group.getIsActive() != null && group.getIsActive())
                .flatMap(group -> {
                    // 2️⃣ Use the exact primary key getter name: getGroupId()
                    Mono<Long> countMono = groupMembersRepository.countByGroupId(group.getGroupId());
                    
                    return countMono.map(count -> GroupsDTO.GroupResponse.builder()
                            .id(group.getGroupId())
                            .name(group.getName())
                            .memberCount(count)
                            // Fallback strings parsing your open description text or dynamic default metrics
                            .progressLabel(group.getDescription() != null && !group.getDescription().isBlank() 
                                    ? group.getDescription() 
                                    : "Goal → Complete target milestones together")
                            .progressValue(0.50) // Baseline default progress percentage till we wire metrics calculations
                            .build());
                });
    }
}