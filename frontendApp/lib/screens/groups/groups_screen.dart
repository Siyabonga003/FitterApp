import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/models/group_model.dart';
import 'package:frontend_app/services/groups_services.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/screens/groups/create_group_screen.dart';
import 'package:frontend_app/screens/groups/group_detail_screen.dart';

import 'join_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  Future<List<GroupModel>>? _groupsFuture;
  final GroupsApiService _apiService = GroupsApiService();

  @override
  void initState() {
    super.initState();
    _loadGroupsWithToken();
  }

  Future<void> _loadGroupsWithToken() async {
    try {
      final String? activeSessionToken = await AuthService.getToken();

      if (activeSessionToken != null && mounted) {
        setState(() {
          _groupsFuture = _apiService.fetchGroups(activeSessionToken);
        });
      } else {
        print("Error: No active Keycloak session token found in preferences.");
      }
    } catch (e) {
      print("Error loading active token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GROUPS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryOrange, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryOrange),
                      label: const Text(
                        'Create',
                        style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      onPressed: () async {
                        final created = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                        );
                        if (created == true) {
                          _loadGroupsWithToken();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryOrange, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.qr_code_rounded, size: 18, color: AppTheme.primaryOrange),
                      label: const Text(
                        'Join with Code',
                        style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      onPressed: () async {
                        final joined = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                        );
                        if (joined == true) {
                          _loadGroupsWithToken();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Groups Vertical Scrolling Feed Layout List
            Expanded(
              child: _groupsFuture == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                  : FutureBuilder<List<GroupModel>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading groups data',
                        style: TextStyle(color: Colors.redAccent.shade100, fontSize: 14),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No active groups found.', style: TextStyle(color: AppTheme.textLight)),
                    );
                  }

                  final groups = snapshot.data!;
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(groupId: groups[index].id),
                              ),
                            );
                            if (result == true) {
                              _loadGroupsWithToken();
                            }
                          },
                          child: GroupCard(group: groups[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final GroupModel group;

  const GroupCard({
    required this.group,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textWhite, fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${group.memberCount} Members',
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(group.progressLabel, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                if (group.hasGoal)
                  Text(group.percentageText, style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            if (group.hasGoal)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: group.progressValue,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}