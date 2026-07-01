import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // add this
import 'package:frontend_app/screens/auth/splash_screen.dart';
import 'package:frontend_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FitterApp(),
    ),
  );
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