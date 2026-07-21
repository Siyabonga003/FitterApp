package app.run.fitter.grp.service;

import app.run.fitter.app.dto.GroupsDTO;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface GroupsService {
    Flux<GroupsDTO.GroupResponse> getAllActiveGroups();
    Mono<GroupsDTO.GroupResponse> createGroup(GroupsDTO.CreateGroupRequest request);
    Mono<GroupsDTO.GroupDetailResponse> getGroupDetail(UUID groupId);
    Mono<GroupsDTO.GroupResponse> joinGroup(UUID groupId);
    Mono<GroupsDTO.InviteResponse> createInvite(UUID groupId);
    Mono<GroupsDTO.GroupResponse> joinViaInvite(String code);
    Mono<Void> inviteFriend(UUID groupId, UUID friendUserId);
    Mono<GroupsDTO.GroupResponse> acceptGroupInvite(UUID groupId);
    Mono<Void> declineGroupInvite(UUID groupId);
}