import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/main_navigation_shell.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/models/auth_model.dart';
import 'package:frontend_app/services/signup_service.dart';

import 'landing_view.dart';
import 'sign_in_form_view.dart';
import 'sign_up_form_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final signInEmailController = TextEditingController();
  final signInPasswordController = TextEditingController();
  final signUpFirstNameController = TextEditingController();
  final signUpLastNameController = TextEditingController();
  final signUpDisplayNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  String? selectedGender;
  DateTime? selectedBirthDate;
  late TabController _tabController;
  bool _isLoading = false;
  int _currentView = 0;
  int signUpStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          signUpStep = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    signUpFirstNameController.dispose();
    signUpLastNameController.dispose();
    signUpDisplayNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void navigateToTab(int tabIndex) {
    setState(() {
      _currentView = 1;
      _tabController.index = tabIndex;
    });
  }

  void submitAuthSession(bool isSignIn) async {
    final formKey = isSignIn ? signInFormKey : signUpFormKey;
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (isSignIn) {
      final authResult = await AuthService.login(
        signInEmailController.text.trim(),
        signInPasswordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (authResult != null && authResult is AuthResponse) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          );
        } else {
          _showStatusSnackbar('Authentication failed. Invalid credentials.', isError: true);
        }
      }
    } else {
      if (selectedGender == null || selectedBirthDate == null) {
        setState(() => _isLoading = false);
        _showStatusSnackbar('Please complete your profile metrics.', isError: true);
        return;
      }

      final birthDateStr =
          '${selectedBirthDate!.year}-${selectedBirthDate!.month.toString().padLeft(2, '0')}-${selectedBirthDate!.day.toString().padLeft(2, '0')}';

      final registrationSuccess = await SignupService.registerUser(
        email: signUpEmailController.text.trim(),
        password: signUpPasswordController.text,
        displayName: signUpDisplayNameController.text.trim(),
        firstName: signUpFirstNameController.text.trim(),
        lastName: signUpLastNameController.text.trim(),
        gender: selectedGender!,
        birthDate: birthDateStr,
        defaultActivityVisibilityId: 1,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (registrationSuccess) {
          _tabController.animateTo(0);
          signInEmailController.text = signUpEmailController.text;
          _showStatusSnackbar('Account provisioned successfully! Please sign in.', isError: false);
          _clearSignUpForm();
        } else {
          _showStatusSnackbar('Registration aborted. Identity profiles conflict.', isError: true);
        }
      }
    }
  }

  void _clearSignUpForm() {
    signUpEmailController.clear();
    signUpFirstNameController.clear();
    signUpLastNameController.clear();
    signUpDisplayNameController.clear();
    signUpPasswordController.clear();
    setState(() {
      selectedGender = null;
      selectedBirthDate = null;
      signUpStep = 0;
    });
  }

  void _showStatusSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppTheme.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _currentView == 0
                  ? LandingView(onNavigate: navigateToTab)
                  : _buildFormTabsView(),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTabsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text('Welcome', style: TextStyle(color: AppTheme.textWhite, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Sign in to track your operational metrics', style: TextStyle(color: AppTheme.textLight, fontSize: 15)),
        const SizedBox(height: 32),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(10)),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textLight,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SignInFormView(parentState: this),
              SignUpFormView(parentState: this),
            ],
          ),
        ),
      ],
    );
  }
}