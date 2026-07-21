package app.run.fitter.app.controller;

import app.run.fitter.app.dto.GroupsDTO;
import app.run.fitter.grp.service.GroupsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
public class GroupsController {

    private final GroupsService groupsService;

    @GetMapping
    public Flux<GroupsDTO.GroupResponse> fetchAllGroups() {
        return groupsService.getAllActiveGroups();
    }

    @PostMapping
    public Mono<GroupsDTO.GroupResponse> createGroup(@RequestBody GroupsDTO.CreateGroupRequest request) {
        return groupsService.createGroup(request);
    }

    @GetMapping("/{groupId}")
    public Mono<GroupsDTO.GroupDetailResponse> getGroupDetail(@PathVariable UUID groupId) {
        return groupsService.getGroupDetail(groupId);
    }

    @PostMapping("/{groupId}/join")
    public Mono<GroupsDTO.GroupResponse> joinGroup(@PathVariable UUID groupId) {
        return groupsService.joinGroup(groupId);
    }

    @PostMapping("/{groupId}/invites")
    public Mono<GroupsDTO.InviteResponse> createInvite(@PathVariable UUID groupId) {
        return groupsService.createInvite(groupId);
    }

    @PostMapping("/invites/{code}/join")
    public Mono<GroupsDTO.GroupResponse> joinViaInvite(@PathVariable String code) {
        return groupsService.joinViaInvite(code);
    }

    @PostMapping("/{groupId}/invite-friend")
    public Mono<Void> inviteFriend(@PathVariable UUID groupId, @RequestBody GroupsDTO.InviteFriendRequest request) {
        return groupsService.inviteFriend(groupId, request.getFriendUserId());
    }

    @PostMapping("/{groupId}/accept-invite")
    public Mono<GroupsDTO.GroupResponse> acceptInvite(@PathVariable UUID groupId) {
        return groupsService.acceptGroupInvite(groupId);
    }

    @PostMapping("/{groupId}/decline-invite")
    public Mono<Void> declineInvite(@PathVariable UUID groupId) {
        return groupsService.declineGroupInvite(groupId);
    }
}