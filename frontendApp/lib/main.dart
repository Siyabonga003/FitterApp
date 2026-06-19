import 'package:flutter/material.dart';
import 'package:frontend_app/screens/auth/splash_screen.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/auth/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitterApp());
}

class FitterApp extends StatelessWidget {
  const FitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}