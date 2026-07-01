import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/services/activity_service.dart';
import 'package:frontend_app/screens/activity/active_run_screen.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  int _selectedTypeId = 1;
  int _selectedVisibilityId = 1;
  bool _routeVisible = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _activityTypes = [
    {'id': 1, 'label': 'Running'},
    {'id': 2, 'label': 'Jogging'},
    {'id': 3, 'label': 'Walking'},
  ];

  final List<Map<String, dynamic>> _visibilityOptions = [
    {'id': 1, 'label': 'Public'},
    {'id': 2, 'label': 'Friends Only'},
    {'id': 3, 'label': 'Private'},
  ];

  Future<void> _startActivity() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _showSnackbar('Session expired. Please log in again.', isError: true);
        return;
      }

      final result = await ActivityService.createActivity(userId, {
        'activityTypeId': _selectedTypeId,
        'startedAt': DateTime.now().toUtc().toIso8601String(),
        'visibilityId': _selectedVisibilityId,
        'routeVisible': _routeVisible,
        'isLive': true,
      });

      if (result != null && mounted) {
        final activityId = result['activityId'] as String?;
        final activityLabel = _activityTypes
            .firstWhere((t) => t['id'] == _selectedTypeId)['label'] as String;

        if (activityId == null) {
          _showSnackbar('Server error: no activity ID returned.', isError: true);
          return;
        }

        // ✅ Navigate to ActiveRunScreen with the real activityId and userId
        final finished = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveRunScreen(
              activityId: activityId,
              userId: userId,
              activityType: activityLabel,
            ),
          ),
        );

        if (finished == true) {
          Navigator.pop(context, true); // Refresh home feed
        }
      } else {
        _showSnackbar('Failed to start activity. Try again.', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppTheme.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Start Activity', style: TextStyle(color: AppTheme.textWhite)),
        iconTheme: const IconThemeData(color: AppTheme.textWhite),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity Type', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedTypeId,
                  dropdownColor: AppTheme.darkCard,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight),
                  items: _activityTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'] as int,
                      child: Text(type['label'] as String,
                          style: const TextStyle(color: AppTheme.textWhite)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTypeId = value!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Visibility', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedVisibilityId,
                  dropdownColor: AppTheme.darkCard,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight),
                  items: _visibilityOptions.map((v) {
                    return DropdownMenuItem<int>(
                      value: v['id'] as int,
                      child: Text(v['label'] as String,
                          style: const TextStyle(color: AppTheme.textWhite)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedVisibilityId = value!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show Route', style: TextStyle(color: AppTheme.textWhite)),
                subtitle: const Text('Others can see your route map',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                value: _routeVisible,
                activeColor: AppTheme.primaryOrange,
                onChanged: (value) => setState(() => _routeVisible = value),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _startActivity,
                child: _isLoading
                    ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text(
                  'START',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}