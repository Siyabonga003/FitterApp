import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app/models/group_model.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/services/groups_services.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/widgets/groups/group_action_buttons.dart';
import 'package:frontend_app/widgets/groups/group_header_section.dart';
import 'package:frontend_app/widgets/groups/group_invite_sheet.dart';
import 'package:frontend_app/widgets/groups/group_leaderboard_section.dart';
import 'package:frontend_app/widgets/groups/group_members_section.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({required this.groupId, super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupsApiService _apiService = GroupsApiService();
  Future<GroupDetailModel>? _detailFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      _detailFuture = _fetchDetail();
    });
  }

  Future<GroupDetailModel> _fetchDetail() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No active session token found.');
    return _apiService.fetchGroupDetail(token, widget.groupId);
  }

  Future<void> _runAction(
      Future<void> Function(String token) action, {
        String? successMessage,
      }) async {
    setState(() => _isBusy = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No active session token found.');
      await action(token);
      _loadDetail();
      if (mounted && successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _joinGroup() => _runAction(
        (token) => _apiService.joinGroup(token, widget.groupId),
    successMessage: 'You joined the group!',
  );

  Future<void> _acceptInvite() => _runAction(
        (token) => _apiService.acceptGroupInvite(token, widget.groupId),
    successMessage: 'Invite accepted!',
  );

  Future<void> _declineInvite() => _runAction(
        (token) => _apiService.declineGroupInvite(token, widget.groupId),
    successMessage: 'Invite declined.',
  );

  Future<void> _generateInviteLink() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No active session token found.');
      final code = await _apiService.createInvite(token, widget.groupId);
      if (mounted) {
        Navigator.of(context).pop();
        _showInviteCodeDialog(code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _showInviteCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Invite Link Code',
          style: TextStyle(color: AppTheme.textWhite, fontSize: 16),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                color: AppTheme.primaryNeon,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: AppTheme.textLight),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done', style: TextStyle(color: AppTheme.primaryNeon, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _openInviteSheet(GroupDetailModel detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GroupInviteSheet(
        groupId: widget.groupId,
        apiService: _apiService,
        existingMemberIds: detail.members.map((m) => m.userId).toSet(),
        onGenerateLink: _generateInviteLink,
        onInvited: _loadDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GROUP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: FutureBuilder<GroupDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}'.replaceFirst('Exception: ', ''),
                style: TextStyle(color: Colors.redAccent.shade100),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Group not found.', style: TextStyle(color: AppTheme.textLight)));
          }

          final detail = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GroupHeaderSection(detail: detail),
              const SizedBox(height: 16),
              GroupActionButtons(
                detail: detail,
                isBusy: _isBusy,
                onJoin: _joinGroup,
                onAccept: _acceptInvite,
                onDecline: _declineInvite,
                onInvite: () => _openInviteSheet(detail),
              ),
              const SizedBox(height: 24),
              // Leaderboard section showing top members by kilometers
              GroupLeaderboardSection(members: detail.members),
              const SizedBox(height: 28),
              // General member roster list
              GroupMembersSection(
                members: detail.members,
                memberCount: detail.memberCount,
              ),
            ],
          );
        },
      ),
    );
  }
}