import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/auth/auth_screen.dart';

void showProfileSettingsSheet(
    BuildContext context, {
      required bool isMetric,
      required ValueChanged<bool> onMetricChanged,
      required VoidCallback onEditProfile,
    }) {
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
                const Text('SETTINGS',
                    style: TextStyle(
                        color: AppTheme.textWhite, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Metric Units (km)', style: TextStyle(color: AppTheme.textWhite)),
                  subtitle: const Text('Toggle between kilometers and miles metrics',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                  activeColor: AppTheme.primaryOrange,
                  value: isMetric,
                  onChanged: (value) {
                    onMetricChanged(value);
                    setSheetState(() {});
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline_rounded, color: AppTheme.textLight),
                  title: const Text('Edit Profile', style: TextStyle(color: AppTheme.textWhite)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                  onTap: onEditProfile,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                  title: const Text('Log Out',
                      style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                  onTap: () {
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