class FriendshipResponse {
  final String friendshipId;
  final String userId;
  final String friendId;
  final String status;
  final String displayName;
  final String email;

  FriendshipResponse({
    required this.friendshipId,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.displayName,
    required this.email,
  });

  factory FriendshipResponse.fromJson(Map<String, dynamic> json) {
    return FriendshipResponse(
      friendshipId: json['friendshipId'] ?? '',
      userId: json['userId'] ?? '',
      friendId: json['friendId'] ?? '',
      status: json['status'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}

class FriendSearchResult {
  final String userId;
  final String displayName;
  final String email;
  final String? bio;
  final String? friendshipStatus;

  FriendSearchResult({
    required this.userId,
    required this.displayName,
    required this.email,
    this.bio,
    this.friendshipStatus,
  });

  factory FriendSearchResult.fromJson(Map<String, dynamic> json) {
    return FriendSearchResult(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      friendshipStatus: json['friendshipStatus'],
    );
  }

  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}