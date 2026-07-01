import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/auth/auth_screen.dart';
import 'package:frontend_app/providers/badge_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(badgeProvider.notifier).loadBadges());
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Metric Units (km)',
                        style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text(
                        'Toggle between kilometers and miles metrics',
                        style:
                        TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    activeColor: AppTheme.primaryOrange,
                    value: _isMetric,
                    onChanged: (value) {
                      setState(() => _isMetric = value);
                      setSheetState(() {});
                    },
                  ),
                  const Divider(color: Colors.white10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline_rounded,
                        color: AppTheme.textLight),
                    title: const Text('Edit Profile',
                        style: TextStyle(color: AppTheme.textWhite)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textLight),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: AppTheme.danger),
                    title: const Text('Log Out',
                        style: TextStyle(
                            color: AppTheme.danger,
                            fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen()),
                            (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgeProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ME',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppTheme.textWhite),
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: const Text(
                  'S',
                  style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siya',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 26, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Member since June 2026',
                      style: TextStyle(
                          color: AppTheme.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('ALL-TIME METRICS',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricBlock(
                  context,
                  '🏃 TOTAL DISTANCE',
                  _isMetric ? '52.4' : '32.5',
                  _isMetric ? 'km' : 'mi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricBlock(
                      context, '⏱️ ACTIVE TIME', '312', 'min')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildMetricBlock(
                      context, '🔥 TOTAL CALORIES', '4,250', 'kcal')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricBlock(
                      context, '📅 WORKOUTS', '12', 'sessions')),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 0,
            color: AppTheme.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weekly Goal Status',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 16, color: Colors.white)),
                      const Text('3 of 4 Days',
                          style: TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDayIndicator('M', true),
                      _buildDayIndicator('T', true),
                      _buildDayIndicator('W', true),
                      _buildDayIndicator('T', false),
                      _buildDayIndicator('F', false),
                      _buildDayIndicator('S', false),
                      _buildDayIndicator('S', false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ACHIEVEMENT MILESTONES — now driven by badgeProvider
          Text('UNLOCKED ACHIEVEMENTS',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: badges.isEmpty
                ? const Center(
              child: Text(
                'Complete runs to unlock badges',
                style:
                TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return BadgeWidget(
                  emoji: badge.emoji,
                  title: badge.name,
                  isNew: badge.isNew,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricBlock(
      BuildContext context, String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(String dayLabel, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.primaryOrange
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border:
            Border.all(color: isCompleted ? Colors.transparent : Colors.white10),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.add_rounded,
              size: 16,
              color: isCompleted ? Colors.white : Colors.white30,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(dayLabel,
            style: TextStyle(
                color: isCompleted ? AppTheme.textWhite : AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isNew;

  const BadgeWidget({
    required this.emoji,
    required this.title,
    this.isNew = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew
              ? AppTheme.primaryOrange.withOpacity(0.6)
              : Colors.white10,
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: isNew
            ? [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
          if (isNew) ...[
            const SizedBox(height: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}