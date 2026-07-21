import 'package:flutter/material.dart';
import 'package:frontend_app/models/group_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_url.dart';
import '../leaderboard/avatar_with_progress.dart';

class GroupLeaderboardSection extends StatelessWidget {
  final List<GroupMemberModel> members;

  const GroupLeaderboardSection({
    super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No leaderboard activity yet.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),
        ),
      );
    }

    // Sort members by highest kilometers descending
    final sortedMembers = List<GroupMemberModel>.from(members)
      ..sort((a, b) => (b.distanceKm ?? 0.0).compareTo(a.distanceKm ?? 0.0));

    final leader = sortedMembers.first;
    final runnersUp = sortedMembers.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('🏆', style: TextStyle(fontSize: 16)),
            SizedBox(width: 6),
            Text(
              'Group Leaderboard',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 🥇 1st Place Spotlight Card
        _buildLeaderCard(context, leader),

        if (runnersUp.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...runnersUp.asMap().entries.map((entry) {
            final rank = entry.key + 2;
            final member = entry.value;
            return _buildRunnerUpTile(context, member, rank);
          }),
        ],
      ],
    );
  }

  Widget _buildLeaderCard(BuildContext context, GroupMemberModel leader) {
    final distance = leader.distanceKm ?? 0.0;
    final runs = leader.activitiesCount ?? 0;
    final streak = leader.streakDays ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeon.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          AvatarWithProgress(
            imageUrl: resolveImageUrl(leader.profilePicUrl),
            progress: 1.0, // Full ring for #1 leader
            size: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        leader.displayName,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🥇', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '🏃 $runs Runs',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🔥 ${streak}d Streak',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNeon,
                ),
              ),
              const Text(
                'km',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRunnerUpTile(BuildContext context, GroupMemberModel member, int rank) {
    final distance = member.distanceKm ?? 0.0;
    final runs = member.activitiesCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          AvatarWithProgress(
            imageUrl: resolveImageUrl(member.profilePicUrl),
            progress: 0.8,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '🏃 $runs Runs',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: distance.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
                const TextSpan(
                  text: ' km',
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}