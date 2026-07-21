import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_url.dart';

class GroupMembersSection extends StatelessWidget {
  final List<GroupMemberModel> members;
  final int memberCount;

  const GroupMembersSection({
    super.key,
    required this.members,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members ($memberCount)',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...members.map(
              (member) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white10,
                  backgroundImage: resolveImageUrl(member.profilePicUrl) != null
                      ? NetworkImage(resolveImageUrl(member.profilePicUrl)!)
                      : null,
                  child: member.profilePicUrl == null || member.profilePicUrl!.isEmpty
                      ? Text(
                    member.displayName.isNotEmpty
                        ? member.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppTheme.textWhite),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    member.displayName,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    member.role,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}