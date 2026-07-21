class GroupModel {
  final String id;
  final String name;
  final double? distanceKm;
  final int? activitiesCount;
  final int? streakDays;
  final int memberCount;
  final String progressLabel;
  final double progressValue;
  final double targetDistanceKm;
  final double currentDistanceKm;

  GroupModel({
    required this.id,
    required this.name,
    this.distanceKm,
    this.activitiesCount,
    this.streakDays,
    required this.memberCount,
    required this.progressLabel,
    required this.progressValue,
    required this.targetDistanceKm,
    required this.currentDistanceKm,
  });

  String get percentageText => '${(progressValue * 100).toInt()}%';
  bool get hasGoal => targetDistanceKm > 0;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceKm: (json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble(),
      activitiesCount: (json['activities_count'] ?? json['activitiesCount'] as num?)?.toInt(),
      streakDays: (json['streak_days'] ?? json['streakDays'] as num?)?.toInt(),
      memberCount: (json['member_count'] ?? json['memberCount'] as num?)?.toInt() ?? 0,
      progressLabel: json['progress_label'] ?? json['progressLabel'] ?? '',
      progressValue: (json['progress_value'] ?? json['progressValue'] as num?)?.toDouble() ?? 0.0,
      targetDistanceKm: (json['target_distance_km'] ?? json['targetDistanceKm'] as num?)?.toDouble() ?? 0.0,
      currentDistanceKm: (json['current_distance_km'] ?? json['currentDistanceKm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance_km': distanceKm,
      'activities_count': activitiesCount,
      'streak_days': streakDays,
      'member_count': memberCount,
      'progress_label': progressLabel,
      'progress_value': progressValue,
      'target_distance_km': targetDistanceKm,
      'current_distance_km': currentDistanceKm,
    };
  }
}

class GroupMemberModel {
  final String userId;
  final String displayName;
  final String? profilePicUrl;
  final String role;
  final String status;
  final double? distanceKm;
  final int? activitiesCount;
  final int? streakDays;

  GroupMemberModel({
    required this.userId,
    required this.displayName,
    this.profilePicUrl,
    required this.role,
    required this.status,
    this.distanceKm,
    this.activitiesCount,
    this.streakDays,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      displayName: (json['display_name'] ?? json['displayName'])?.toString() ?? 'Unknown',
      profilePicUrl: (json['profile_pic_url'] ?? json['profilePicUrl'])?.toString(),
      role: json['role']?.toString() ?? 'MEMBER',
      status: json['status']?.toString() ?? 'ACTIVE',
      distanceKm: ((json['distance_km'] ?? json['distanceKm']) as num?)?.toDouble(),
      activitiesCount: ((json['activities_count'] ?? json['activitiesCount']) as num?)?.toInt(),
      streakDays: ((json['streak_days'] ?? json['streakDays']) as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_pic_url': profilePicUrl,
      'role': role,
      'status': status,
      'distance_km': distanceKm,
      'activities_count': activitiesCount,
      'streak_days': streakDays,
    };
  }
}

class GroupDetailModel {
  final String id;
  final String name;
  final String description;
  final String privacyCode;
  final int memberCount;
  final String progressLabel;
  final double progressValue;
  final double targetDistanceKm;
  final double currentDistanceKm;
  final bool isCurrentUserMember;
  final String? currentUserRole;
  final String? currentUserStatus;
  final List<GroupMemberModel> members;

  GroupDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.privacyCode,
    required this.memberCount,
    required this.progressLabel,
    required this.progressValue,
    required this.targetDistanceKm,
    required this.currentDistanceKm,
    required this.isCurrentUserMember,
    this.currentUserRole,
    this.currentUserStatus,
    required this.members,
  });

  bool get hasGoal => targetDistanceKm > 0;
  String get percentageText => '${(progressValue * 100).toInt()}%';
  bool get canInvite => currentUserRole == 'ADMIN' || currentUserRole == 'MODERATOR';
  bool get hasPendingInvite => currentUserStatus == 'INVITED';

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      privacyCode: json['privacy_code'] ?? json['privacyCode'] ?? 'OPEN',
      memberCount: (json['member_count'] ?? json['memberCount'] as num?)?.toInt() ?? 0,
      progressLabel: json['progress_label'] ?? json['progressLabel'] ?? '',
      progressValue: (json['progress_value'] ?? json['progressValue'] as num?)?.toDouble() ?? 0.0,
      targetDistanceKm: (json['target_distance_km'] ?? json['targetDistanceKm'] as num?)?.toDouble() ?? 0.0,
      currentDistanceKm: (json['current_distance_km'] ?? json['currentDistanceKm'] as num?)?.toDouble() ?? 0.0,
      isCurrentUserMember: json['is_current_user_member'] ?? json['isCurrentUserMember'] ?? false,
      currentUserRole: (json['current_user_role'] ?? json['currentUserRole'])?.toString(),
      currentUserStatus: (json['current_user_status'] ?? json['currentUserStatus'])?.toString(),
      members: (json['members'] as List<dynamic>? ?? [])
          .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'privacy_code': privacyCode,
      'member_count': memberCount,
      'progress_label': progressLabel,
      'progress_value': progressValue,
      'target_distance_km': targetDistanceKm,
      'current_distance_km': currentDistanceKm,
      'is_current_user_member': isCurrentUserMember,
      'current_user_role': currentUserRole,
      'current_user_status': currentUserStatus,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}