import 'package:flutter/material.dart';
import 'package:frontend_app/models/leaderboard_user.dart';
import 'package:frontend_app/services/leaderboard_service.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/widgets/leaderboard/current_user_card.dart';
import 'package:frontend_app/widgets/leaderboard/leaderboard_empty_state.dart';
import 'package:frontend_app/widgets/leaderboard/leaderboard_filter_chips.dart';
import 'package:frontend_app/widgets/leaderboard/leaderboard_header.dart';
import 'package:frontend_app/widgets/leaderboard/leaderboard_loading.dart';
import 'package:frontend_app/widgets/leaderboard/leaderboard_tile.dart';
import 'package:frontend_app/widgets/leaderboard/top_athletes_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final LeaderboardService _service = LeaderboardService();

  final List<String> _filters = ['Today', 'Week', 'Month', 'All Time'];
  String _selectedFilter = 'Week';

  bool _isLoading = true;
  List<LeaderboardUser> _users = [];
  LeaderboardUser? _currentUser;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _animationController.reset();

    final results = await Future.wait([
      _service.fetchLeaderboard(_selectedFilter),
      _service.fetchCurrentUser(),
    ]);

    setState(() {
      _users = results[0] as List<LeaderboardUser>;
      _currentUser = results[1] as LeaderboardUser;
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _showUserDetailModal(LeaderboardUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 36,
                backgroundImage:
                user.profileImage != null ? NetworkImage(user.profileImage!) : null,
              ),
              const SizedBox(height: 12),
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              Text('Rank #${user.rank}', style: const TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Longest Run', '${user.longestRunKm} km'),
                  _buildStatItem('Streak', '${user.streakDays} Days'),
                  _buildStatItem('Avg Pace', user.avgPace),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topThree = _users.take(3).toList();
    final remainingUsers = _users.skip(3).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LeaderboardHeader(),
                LeaderboardFilterChips(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    if (_selectedFilter != filter) {
                      _selectedFilter = filter;
                      _loadData();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const LeaderboardLoading()
                      : _users.isEmpty
                      ? const LeaderboardEmptyState()
                      : RefreshIndicator(
                    color: AppTheme.primaryNeon,
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 110),
                      children: [
                        FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                            ),
                          ),
                          child: TopAthletesWidget(
                            topThree: topThree,
                            onUserTap: _showUserDetailModal,
                          ),
                        ),
                        ...List.generate(remainingUsers.length, (index) {
                          final user = remainingUsers[index];
                          final animation = Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                0.3 + (index * 0.08).clamp(0.0, 0.6),
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: LeaderboardTile(
                                user: user,
                                onTap: () => _showUserDetailModal(user),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_isLoading && _currentUser != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                    ),
                  ),
                  child: CurrentUserCard(
                    user: _currentUser!,
                    kmBehindNext: 6.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}