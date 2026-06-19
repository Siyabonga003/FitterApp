import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/activity/active_run_screen.dart';

class StartActivityScreen extends StatefulWidget {
  const StartActivityScreen({super.key});

  @override
  State<StartActivityScreen> createState() => _StartActivityScreenState();
}

class _StartActivityScreenState extends State<StartActivityScreen> {
  String _selectedActivity = 'Running';

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Walking', 'icon': Icons.directions_walk_rounded, 'emoji': '🚶'},
    {'name': 'Running', 'icon': Icons.directions_run_rounded, 'emoji': '🏃'},
    {'name': 'Jogging', 'icon': Icons.run_circle_rounded, 'emoji': '🏃‍♂️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Choose Activity', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Large Cards Layout
            Expanded(
              child: ListView.builder(
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final isSelected = _selectedActivity == activity['name'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivity = activity['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryOrange : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                activity['icon'],
                                size: 32,
                                color: isSelected ? AppTheme.primaryOrange : AppTheme.textWhite,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                '${activity['emoji']} ${activity['name']}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isSelected ? AppTheme.primaryOrange : AppTheme.textWhite,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryOrange, size: 26),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Big Action Start Button
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveRunScreen(activityType: _selectedActivity),
                      ),
                    );
                  },
                  child: Text(
                    'START NOW',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}