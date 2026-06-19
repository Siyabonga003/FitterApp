import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/auth/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // ⚡ Perfectly scaled brand asset (No cropping)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Keeps it beautifully framed away from screen edges
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain, // Ensures the entire logo scales cleanly without clipping edges
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.bolt_rounded, size: 80, color: AppTheme.primaryNeon);
                },
              ),
            ),
          ),

          // Clean neon loading track near the bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 64.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}