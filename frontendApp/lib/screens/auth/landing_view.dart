import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class LandingView extends StatelessWidget {
  final Function(int) onNavigate;

  const LandingView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const Text('Welcome', style: TextStyle(color: AppTheme.textWhite, fontSize: 40, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Track your operational metrics and perform at your highest level.', style: TextStyle(color: AppTheme.textLight, fontSize: 16, height: 1.4)),
        const Spacer(),
        _buildActionButton('SIGN IN', () => onNavigate(0)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => onNavigate(1),
            child: const Text('SIGN UP', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}