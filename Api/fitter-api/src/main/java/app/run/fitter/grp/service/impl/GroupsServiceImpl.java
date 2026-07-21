package app.run.fitter.grp.service.impl;

import app.run.fitter.activity.repository.ActivitiesRepository;
import app.run.fitter.app.dto.GroupsDTO;
import app.run.fitter.app.entity.Users;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.exception.BadRequestException;
import app.run.fitter.exception.ConflictException;
import app.run.fitter.exception.ForbiddenException;
import app.run.fitter.exception.ResourceNotFoundException;
import app.run.fitter.grp.entity.GroupInvites;
import app.run.fitter.grp.entity.GroupMembers;
import app.run.fitter.grp.entity.Groups;
import app.run.fitter.grp.repository.GroupInvitesRepository;
import app.run.fitter.grp.repository.GroupMembersRepository;
import app.run.fitter.grp.repository.GroupsRepository;
import app.run.fitter.grp.service.GroupsService;
import app.run.fitter.lookup.entity.GroupPrivacies;
import app.run.fitter.lookup.repository.GroupPrivaciesRepository;
import app.run.fitter.notification.service.NotificationsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupsServiceImpl implements GroupsService {

    private static final String INVITE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final GroupsRepository groupsRepository;
    private final GroupMembersRepository groupMembersRepository;
    private final ActivitiesRepository activitiesRepository;
    private final GroupPrivaciesRepository groupPrivaciesRepository;
    private final GroupInvitesRepository groupInvitesRepository;
    private final UsersRepository usersRepository;
    private final NotificationsService notificationsService;

    @Override
    public Flux<GroupsDTO.GroupResponse> getAllActiveGroups() {
        ZonedDateTime periodStart = periodStart();

        return groupsRepository.findAll()
                .filter(group -> group.getIsActive() != null && group.getIsActive())
                .flatMap(group -> buildProgress(group, periodStart)
                        .map(p -> GroupsDTO.GroupResponse.builder()
                                .id(group.getGroupId())
                                .name(group.getName())
                                .memberCount(p.memberCount())
                                .progressLabel(p.label())
                                .progressValue(p.value())
                                .targetDistanceKm(p.target())
                                .currentDistanceKm(p.current())
                                .build()));
    }

    @Override
    public Mono<GroupsDTO.GroupResponse> createGroup(GroupsDTO.CreateGroupRequest request) {
        return Mono.zip(getCurrentUserId(), resolvePrivacyId(request.getPrivacy()))
                .flatMap(tuple -> {
                    UUID ownerId = tuple.getT1();
                    Short privacyId = tuple.getT2();

                    BigDecimal target = request.getTargetDistanceKm() != null
                            ? BigDecimal.valueOf(request.getTargetDistanceKm())
                            : null;

                    Groups newGroup = Groups.builder()
                            .groupId(UUID.randomUUID())
                            .ownerUserId(ownerId)
                            .name(request.getName())
                            .description(request.getDescription())
                            .groupPrivacyId(privacyId)
                            .isActive(true)
                            .targetDistanceKm(target)
                            .isNewRecord(true)
                            .build();

                    return groupsRepository.save(newGroup)
                            .flatMap(saved -> addMember(saved.getGroupId(), ownerId, "ADMIN")
                                    .map(m -> GroupsDTO.GroupResponse.builder()
                                            .id(saved.getGroupId())
                                            .name(saved.getName())
                                            .memberCount(1)
                                            .progressLabel(saved.getTargetDistanceKm() != null
                                                    ? String.format("0.0 / %.1f km this month", saved.getTargetDistanceKm().doubleValue())
                                                    : "No group goal set")
                                            .progressValue(0.0)
                                            .targetDistanceKm(saved.getTargetDistanceKm() != null
                                                    ? saved.getTargetDistanceKm().doubleValue() : 0.0)
                                            .currentDistanceKm(0.0)
                                            .build()));
                });
    }

    @Override
    public Mono<GroupsDTO.GroupDetailResponse> getGroupDetail(UUID groupId) {
        ZonedDateTime periodStart = periodStart();

        return Mono.zip(findGroupOrThrow(groupId), getCurrentUserId())
                .flatMap(tuple -> {
                    Groups group = tuple.getT1();
                    UUID currentUserId = tuple.getT2();

                    Mono<Progress> progressMono = buildProgress(group, periodStart);
                    Mono<GroupPrivacies> privacyMono = groupPrivaciesRepository.findById(group.getGroupPrivacyId())
                            .switchIfEmpty(Mono.error(new ResourceNotFoundException("GroupPrivacy", String.valueOf(group.getGroupPrivacyId()))));
                    Mono<List<GroupMembers>> membersMono = groupMembersRepository
                            .findByGroupIdAndStatus(groupId, "ACTIVE").collectList();
                    Mono<GroupMembers> currentMembershipMono = groupMembersRepository
                            .findByGroupIdAndUserId(groupId, currentUserId)
                            .defaultIfEmpty(GroupMembers.builder().build());

                    return Mono.zip(progressMono, privacyMono, membersMono, currentMembershipMono)
                            .flatMap(z -> {
                                Progress progress = z.getT1();
                                GroupPrivacies privacy = z.getT2();
                                List<GroupMembers> members = z.getT3();
                                GroupMembers currentMembership = z.getT4();

                                List<UUID> memberUserIds = members.stream()
                                        .map(GroupMembers::getUserId)
                                        .collect(Collectors.toList());

                                return usersRepository.findAllById(memberUserIds)
                                        .collectMap(Users::getUserId)
                                        .map(usersById -> {
                                            List<GroupsDTO.GroupMemberResponse> memberResponses = members.stream()
                                                    .map(m -> {
                                                        Users u = usersById.get(m.getUserId());
                                                        return GroupsDTO.GroupMemberResponse.builder()
                                                                .userId(m.getUserId())
                                                                .displayName(u != null ? u.getDisplayName() : "Unknown")
                                                                .profilePicUrl(u != null ? u.getProfilePictureUrl() : null)
                                                                .role(m.getRole())
                                                                .status(m.getStatus())
                                                                .build();
                                                    })
                                                    .collect(Collectors.toList());

                                            boolean isActiveMember = "ACTIVE".equals(currentMembership.getStatus());

                                            return GroupsDTO.GroupDetailResponse.builder()
                                                    .id(group.getGroupId())
                                                    .name(group.getName())
                                                    .description(group.getDescription())
                                                    .privacyCode(privacy.getCode())
                                                    .memberCount(progress.memberCount())
                                                    .progressLabel(progress.label())
                                                    .progressValue(progress.value())
                                                    .targetDistanceKm(progress.target())
                                                    .currentDistanceKm(progress.current())
                                                    .isCurrentUserMember(isActiveMember)
                                                    .currentUserRole(currentMembership.getRole())
                                                    .currentUserStatus(currentMembership.getStatus())
                                                    .members(memberResponses)
                                                    .build();
                                        });
                            });
                });
    }

    @Override
    public Mono<GroupsDTO.GroupResponse> joinGroup(UUID groupId) {
        return Mono.zip(findGroupOrThrow(groupId), getCurrentUserId())
                .flatMap(tuple -> {
                    Groups group = tuple.getT1();
                    UUID userId = tuple.getT2();

                    return groupPrivaciesRepository.findById(group.getGroupPrivacyId())
                            .switchIfEmpty(Mono.error(new ResourceNotFoundException("GroupPrivacy", String.valueOf(group.getGroupPrivacyId()))))
                            .flatMap(privacy -> {
                                if (!"OPEN".equals(privacy.getCode())) {
                                    return Mono.error(new ForbiddenException(
                                            "This group requires an invite to join."));
                                }
                                return groupMembersRepository.findByGroupIdAndUserId(groupId, userId)
                                        .flatMap(existing -> Mono.<GroupsDTO.GroupResponse>error(
                                                new ConflictException("You are already a member of this group.")))
                                        .switchIfEmpty(addMember(groupId, userId, "MEMBER")
                                                .then(refreshGroupResponse(group)));
                            });
                });
    }

    @Override
    public Mono<GroupsDTO.InviteResponse> createInvite(UUID groupId) {
        return Mono.zip(findGroupOrThrow(groupId), getCurrentUserId())
                .flatMap(tuple -> {
                    UUID userId = tuple.getT2();

                    return groupMembersRepository.findByGroupIdAndUserId(groupId, userId)
                            .switchIfEmpty(Mono.error(new ForbiddenException(
                                    "You must be a member of this group to create an invite.")))
                            .flatMap(membership -> {
                                if (!"ADMIN".equals(membership.getRole()) && !"MODERATOR".equals(membership.getRole())) {
                                    return Mono.error(new ForbiddenException(
                                            "Only admins or moderators can create invites."));
                                }
                                String code = generateInviteCode();
                                GroupInvites invite = GroupInvites.builder()
                                        .inviteId(UUID.randomUUID())
                                        .groupId(groupId)
                                        .code(code)
                                        .createdBy(userId)
                                        .useCount(0)
                                        .isActive(true)
                                        .createdAt(ZonedDateTime.now())
                                        .isNewRecord(true)
                                        .build();

                                return groupInvitesRepository.save(invite)
                                        .map(saved -> GroupsDTO.InviteResponse.builder()
                                                .code(saved.getCode())
                                                .build());
                            });
                });
    }

    @Override
    public Mono<GroupsDTO.GroupResponse> joinViaInvite(String code) {
        return Mono.zip(
                        groupInvitesRepository.findByCodeAndIsActiveTrue(code)
                                .switchIfEmpty(Mono.error(new BadRequestException("Invalid or expired invite code."))),
                        getCurrentUserId())
                .flatMap(tuple -> {
                    GroupInvites invite = tuple.getT1();
                    UUID userId = tuple.getT2();

                    if (invite.getExpiresAt() != null && invite.getExpiresAt().isBefore(ZonedDateTime.now())) {
                        return Mono.error(new BadRequestException("This invite code has expired."));
                    }
                    if (invite.getMaxUses() != null && invite.getUseCount() >= invite.getMaxUses()) {
                        return Mono.error(new BadRequestException("This invite code has reached its usage limit."));
                    }

                    return findGroupOrThrow(invite.getGroupId())
                            .flatMap(group -> groupMembersRepository
                                    .findByGroupIdAndUserId(group.getGroupId(), userId)
                                    .flatMap(existing -> Mono.<GroupsDTO.GroupResponse>error(
                                            new ConflictException("You are already a member of this group.")))
                                    .switchIfEmpty(addMember(group.getGroupId(), userId, "MEMBER")
                                            .then(incrementInviteUse(invite))
                                            .then(refreshGroupResponse(group))));
                });
    }

    @Override
    public Mono<Void> inviteFriend(UUID groupId, UUID friendUserId) {
        return Mono.zip(findGroupOrThrow(groupId), getCurrentUserId())
                .flatMap(tuple -> {
                    Groups group = tuple.getT1();
                    UUID inviterId = tuple.getT2();

                    return groupMembersRepository.findByGroupIdAndUserId(groupId, inviterId)
                            .switchIfEmpty(Mono.error(new ForbiddenException(
                                    "You must be a member of this group to invite others.")))
                            .flatMap(inviterMembership -> groupMembersRepository
                                    .findByGroupIdAndUserId(groupId, friendUserId)
                                    .flatMap(existing -> Mono.<Void>error(new ConflictException(
                                            "This person is already a member or has a pending invite.")))
                                    .switchIfEmpty(Mono.defer(() -> {
                                        GroupMembers pending = GroupMembers.builder()
                                                .groupMemberId(UUID.randomUUID())
                                                .groupId(groupId)
                                                .userId(friendUserId)
                                                .role("MEMBER")
                                                .status("INVITED")
                                                .joinedAt(ZonedDateTime.now())
                                                .isNewRecord(true)
                                                .build();
                                        return groupMembersRepository.save(pending)
                                                .doOnSuccess(saved -> sendGroupInviteNotification(group, inviterId, friendUserId))
                                                .then();
                                    })));
                });
    }

    @Override
    public Mono<GroupsDTO.GroupResponse> acceptGroupInvite(UUID groupId) {
        return Mono.zip(findGroupOrThrow(groupId), getCurrentUserId())
                .flatMap(tuple -> {
                    Groups group = tuple.getT1();
                    UUID userId = tuple.getT2();

                    return groupMembersRepository.findByGroupIdAndUserId(groupId, userId)
                            .switchIfEmpty(Mono.error(new ResourceNotFoundException("GroupInvite", groupId.toString())))
                            .flatMap(membership -> {
                                if (!"INVITED".equals(membership.getStatus())) {
                                    return Mono.error(new ConflictException("No pending invite found for this group."));
                                }
                                membership.setStatus("ACTIVE");
                                membership.setNewRecord(false);
                                return groupMembersRepository.save(membership)
                                        .then(refreshGroupResponse(group));
                            });
                });
    }

    @Override
    public Mono<Void> declineGroupInvite(UUID groupId) {
        return getCurrentUserId().flatMap(userId ->
                groupMembersRepository.findByGroupIdAndUserId(groupId, userId)
                        .switchIfEmpty(Mono.error(new ResourceNotFoundException("GroupInvite", groupId.toString())))
                        .flatMap(membership -> {
                            if (!"INVITED".equals(membership.getStatus())) {
                                return Mono.error(new ConflictException("No pending invite found for this group."));
                            }
                            return groupMembersRepository.deleteById(membership.getGroupMemberId());
                        }));
    }

    // ---------- helpers ----------

    private void sendGroupInviteNotification(Groups group, UUID inviterId, UUID friendUserId) {
        notificationsService.notify(
                        friendUserId,
                        inviterId,
                        "GROUP_INVITE",
                        "Group invite",
                        String.format("You've been invited to join \"%s\"", group.getName()),
                        String.format("{\"groupId\":\"%s\"}", group.getGroupId())
                )
                .onErrorResume(e -> {
                    log.warn("Failed to send group invite notification for group {}: {}", group.getGroupId(), e.getMessage());
                    return Mono.empty();
                })
                .subscribe();
    }

    private Mono<Groups> findGroupOrThrow(UUID groupId) {
        return groupsRepository.findById(groupId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("Group", groupId.toString())));
    }

    private Mono<GroupMembers> addMember(UUID groupId, UUID userId, String role) {
        GroupMembers membership = GroupMembers.builder()
                .groupMemberId(UUID.randomUUID())
                .groupId(groupId)
                .userId(userId)
                .role(role)
                .status("ACTIVE")
                .joinedAt(ZonedDateTime.now())
                .isNewRecord(true)
                .build();
        return groupMembersRepository.save(membership);
    }

    private Mono<Void> incrementInviteUse(GroupInvites invite) {
        invite.setUseCount(invite.getUseCount() + 1);
        invite.setNewRecord(false);
        return groupInvitesRepository.save(invite).then();
    }

    private Mono<GroupsDTO.GroupResponse> refreshGroupResponse(Groups group) {
        return buildProgress(group, periodStart())
                .map(p -> GroupsDTO.GroupResponse.builder()
                        .id(group.getGroupId())
                        .name(group.getName())
                        .memberCount(p.memberCount())
                        .progressLabel(p.label())
                        .progressValue(p.value())
                        .targetDistanceKm(p.target())
                        .currentDistanceKm(p.current())
                        .build());
    }

    private Mono<Progress> buildProgress(Groups group, ZonedDateTime periodStart) {
        Mono<Long> countMono = groupMembersRepository.countByGroupIdAndStatus(group.getGroupId(), "ACTIVE");
        Mono<BigDecimal> distanceMono = activitiesRepository
                .sumDistanceForGroupSince(group.getGroupId(), periodStart);

        return Mono.zip(countMono, distanceMono).map(tuple -> {
            long count = tuple.getT1();
            double totalDistance = tuple.getT2().doubleValue();
            double target = group.getTargetDistanceKm() != null ? group.getTargetDistanceKm().doubleValue() : 0.0;
            double progressValue = target > 0 ? Math.min(totalDistance / target, 1.0) : 0.0;

            String label = target > 0
                    ? String.format("%.1f / %.1f km this month", totalDistance, target)
                    : (group.getDescription() != null && !group.getDescription().isBlank()
                        ? group.getDescription()
                        : "No group goal set");

            return new Progress(count, label, progressValue, target, totalDistance);
        });
    }

    private String generateInviteCode() {
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(INVITE_CHARS.charAt(RANDOM.nextInt(INVITE_CHARS.length())));
        }
        return sb.toString();
    }

    private ZonedDateTime periodStart() {
        return ZonedDateTime.now().withDayOfMonth(1).toLocalDate().atStartOfDay(ZonedDateTime.now().getZone());
    }

    private Mono<UUID> getCurrentUserId() {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(Authentication::getPrincipal)
                .cast(Jwt.class)
                .map(jwt -> UUID.fromString(jwt.getSubject()));
    }

    private Mono<Short> resolvePrivacyId(String privacyCode) {
        String code = (privacyCode == null || privacyCode.isBlank()) ? "OPEN" : privacyCode.toUpperCase();
        return groupPrivaciesRepository.findByCode(code)
                .map(GroupPrivacies::getGroupPrivacyId)
                .switchIfEmpty(Mono.error(new BadRequestException("Unknown group privacy code: " + code)));
    }

    private record Progress(long memberCount, String label, double value, double target, double current) {}
}