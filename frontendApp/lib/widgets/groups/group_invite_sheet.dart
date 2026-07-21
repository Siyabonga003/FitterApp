import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/friendship_model.dart';
import '../../services/auth_service.dart';
import '../../services/friendship_service.dart';
import '../../services/groups_services.dart';
import '../../theme/app_theme.dart';

String? _decodeCurrentUserIdFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    String payload = parts[1];
    payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
    final decoded = utf8.decode(base64Url.decode(payload));
    final map = json.decode(decoded) as Map<String, dynamic>;
    return map['sub'] as String?;
  } catch (_) {
    return null;
  }
}

class GroupInviteSheet extends StatefulWidget {
  final String groupId;
  final GroupsApiService apiService;
  final Set<String> existingMemberIds;
  final VoidCallback onGenerateLink;
  final VoidCallback onInvited;

  const GroupInviteSheet({
    super.key,
    required this.groupId,
    required this.apiService,
    required this.existingMemberIds,
    required this.onGenerateLink,
    required this.onInvited,
  });

  @override
  State<GroupInviteSheet> createState() => _GroupInviteSheetState();
}

class _GroupInviteSheetState extends State<GroupInviteSheet> {
  Future<List<FriendshipResponse>>? _friendsFuture;
  String? _currentUserId;
  final Set<String> _invitedInThisSession = {};
  String? _busyFriendId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _currentUserId = _decodeCurrentUserIdFromToken(token);
    }
    setState(() {
      _friendsFuture = FriendshipService.getFriends();
    });
  }

  String _friendIdFor(FriendshipResponse f) {
    if (_currentUserId == null) return f.friendId.toString();
    return f.userId.toString() == _currentUserId ? f.friendId.toString() : f.userId.toString();
  }

  Future<void> _invite(String friendUserId) async {
    setState(() => _busyFriendId = friendUserId);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No active session token found.');
      await widget.apiService.inviteFriend(token, widget.groupId, friendUserId);
      setState(() => _invitedInThisSession.add(friendUserId));
      widget.onInvited();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busyFriendId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite people',
            style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: FutureBuilder<List<FriendshipResponse>>(
              future: _friendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Text('Could not load friends.', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                  );
                }

                final friends = snapshot.data!;
                if (friends.isEmpty) {
                  return const Center(
                    child: Text('No friends yet to invite.', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                  );
                }

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final friendId = _friendIdFor(friend);
                    final alreadyInGroup = widget.existingMemberIds.contains(friendId);
                    final justInvited = _invitedInThisSession.contains(friendId);
                    final isBusy = _busyFriendId == friendId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white10,
                            child: Text(
                              friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(friend.displayName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14)),
                          ),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (alreadyInGroup || justInvited)
                                    ? Colors.white10
                                    : AppTheme.primaryNeon,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: (alreadyInGroup || justInvited || isBusy) ? null : () => _invite(friendId),
                              child: isBusy
                                  ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                                  : Text(
                                alreadyInGroup ? 'Member' : (justInvited ? 'Invited' : 'Invite'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (alreadyInGroup || justInvited) ? AppTheme.textLight : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryNeon, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.link, size: 16, color: AppTheme.primaryNeon),
              label: const Text(
                'Generate Invite Link',
                style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: widget.onGenerateLink,
            ),
          ),
        ],
      ),
    );
  }
}