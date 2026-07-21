package app.run.fitter.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.UUID;

public class GroupsDTO {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroupResponse {
        private UUID id;
        private String name;
        private long memberCount;
        private String progressLabel;
        private double progressValue;
        private double targetDistanceKm;
        private double currentDistanceKm;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateGroupRequest {
        private String name;
        private String description;
        private String privacy;
        private Double targetDistanceKm;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroupMemberResponse {
        private UUID userId;
        private String displayName;
        private String profilePicUrl;
        private String role;
        private String status;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroupDetailResponse {
        private UUID id;
        private String name;
        private String description;
        private String privacyCode;
        private long memberCount;
        private String progressLabel;
        private double progressValue;
        private double targetDistanceKm;
        private double currentDistanceKm;
        private boolean isCurrentUserMember;
        private String currentUserRole;
        private String currentUserStatus;
        private List<GroupMemberResponse> members;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InviteResponse {
        private String code;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InviteFriendRequest {
        private UUID friendUserId;
    }
}