import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_app/screens/home/home_screen.dart';
import 'package:frontend_app/screens/activity/start_activity_screen.dart';
import 'package:frontend_app/screens/profile/profile_screen.dart';
import 'package:frontend_app/screens/groups/groups_screen.dart';
import 'package:frontend_app/screens/map/live_map_screen.dart';
import 'package:frontend_app/providers/badge_provider.dart';
import 'package:frontend_app/models/badge_model.dart';
import 'package:frontend_app/widgets/badge_unlock_overlay.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
      ),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  Badges? _currentBadge; // changed from Badge

  final List<Widget> _screens = [
    const HomeScreen(),
    const StartActivityScreen(),
    const LiveMapScreen(),
    const GroupsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(badgeProvider, (previous, next) {
        final notifier = ref.read(badgeProvider.notifier);
        if (notifier.hasNewBadge && mounted) {
          setState(() => _currentBadge = notifier.popNewBadge());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_currentBadge != null)
            BadgeUnlockOverlay(
              badge: _currentBadge!,
              onDismiss: () => setState(() => _currentBadge = null),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          selectedItemColor: AppTheme.primaryOrange,
          unselectedItemColor: AppTheme.textLight,
          selectedLabelStyle:
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_run_rounded), label: 'Run'),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded), label: 'Live'),
            BottomNavigationBarItem(
                icon: Icon(Icons.groups_rounded), label: 'Groups'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Me'),
          ],
        ),
      ),
    );
  }
}