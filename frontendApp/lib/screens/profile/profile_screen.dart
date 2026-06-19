import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isMetric = true; // State tracker for Metric (km) vs Imperial (mi) toggles

  // 🛠️ BOTTOM PANEL SHEET LOGIC: Renders slide-up system preferences options
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Slide Drawer Drag Indicator Handle Bar
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

                  // Setting Row 1: Active Measurement Units Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Metric Units (km)', style: TextStyle(color: AppTheme.textWhite)),
                    subtitle: const Text('Toggle between kilometers and miles metrics', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    activeColor: AppTheme.primaryOrange,
                    value: _isMetric,
                    onChanged: (value) {
                      setState(() => _isMetric = value);
                      setSheetState(() {}); // Triggers explicit state mutation layout redraw within sheet context
                    },
                  ),
                  const Divider(color: Colors.white10),

                  // Setting Row 2: User profile customization sheet placeholder hook
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline_rounded, color: AppTheme.textLight),
                    title: const Text('Edit Profile', style: TextStyle(color: AppTheme.textWhite)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                    onTap: () {},
                  ),

                  // Setting Row 3: Security Session Drop Gate Interceptor Log Out
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                    title: const Text('Log Out', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Flush navigation routing memory tables back down to login gateway screen components
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
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
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textWhite),
            onPressed: _showSettingsSheet, // Interactive modal panel anchor trigger callback
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 12),

          // 1. USER PROFILE CARD HEADLINER
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: const Text(
                  'S',
                  style: TextStyle(color: AppTheme.primaryOrange, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siya', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 26, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Member since June 2026', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 2. OVERALL ALL-TIME METRIC COUNTERS (Dynamic Display Unit Toggles Mapping)
          Text('ALL-TIME METRICS', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricBlock(
                  context,
                  '🏃 TOTAL DISTANCE',
                  _isMetric ? '52.4' : '32.5', // Changes values dynamically based on choice
                  _isMetric ? 'km' : 'mi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricBlock(context, '⏱️ ACTIVE TIME', '312', 'min')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricBlock(context, '🔥 TOTAL CALORIES', '4,250', 'kcal')),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricBlock(context, '📅 WORKOUTS', '12', 'sessions')),
            ],
          ),
          const SizedBox(height: 28),

          // 3. WEEKLY CONSISTENCY GOALS CARD
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
                      Text('Weekly Goal Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: Colors.white)),
                      const Text('3 of 4 Days', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
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

          // 4. ACHIEVEMENT MILESTONES (Horizontal Scrolling Track)
          Text('UNLOCKED ACHIEVEMENTS', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight, letterSpacing: 1)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                BadgeWidget(emoji: '🥇', title: 'First Run'),
                BadgeWidget(emoji: '⚡', title: 'Speed Demon'),
                BadgeWidget(emoji: '🔋', title: '10K Club'),
                BadgeWidget(emoji: '🔥', title: '5 Day Streak'),
                BadgeWidget(emoji: '🌍', title: 'Explorer'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricBlock(BuildContext context, String title, String value, String unit) {
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
          Text(title, style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
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
            color: isCompleted ? AppTheme.primaryOrange : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? Colors.transparent : Colors.white10),
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
        Text(dayLabel, style: TextStyle(color: isCompleted ? AppTheme.textWhite : AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String emoji;
  final String title;

  const BadgeWidget({required this.emoji, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
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
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}