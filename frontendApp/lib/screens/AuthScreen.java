import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/services/auth_service.dart'; // Integrated Service Call
import 'package:frontend_app/screens/main_navigation_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  // 🔐 CONNECTED TO SPRING BOOT: Process real authentication session handshake
  void _submitAuthSession(GlobalKey<FormState> activeFormKey) async {
    if (activeFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isSignIn = activeFormKey == _signInFormKey;
      dynamic authResult;

      if (isSignIn) {
        // Hit real production network database mapping
        authResult = await AuthService.login(
          _signInEmailController.text.trim(),
          _signInPasswordController.text,
        );
      } else {
        // Placeholder for Sign Up endpoint integration when your backend registration service runs
        await Future.delayed(const Duration(milliseconds: 1500));
        authResult = true; 
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (authResult != null) {
          // Handshake complete -> Route directly into core home feed shell context
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          );
        } else {
          // Fallback UI Notification alert interceptor if credentials throw 401/403 errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppTheme.danger,
              content: Text('Authentication failed. Check your network or credentials.', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'FITTER',
                      style: TextStyle(color: AppTheme.textWhite, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to track your operational workout metrics',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 15),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppTheme.primaryNeon, // Swapped to brand Neon
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.black, // Dark typography for high neon visibility contrast
                        unselectedLabelColor: AppTheme.textLight,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSignInFormView(),
                          _buildSignUpFormView(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInFormView() {
    return Form(
      key: _signInFormKey,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _buildTextFormField(
            controller: _signInEmailController,
            hintText: 'Email Address',
            icon: Icons.email_outlined,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _signInPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            isObscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryNeon, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButton('SIGN IN', () => _submitAuthSession(_signInFormKey)),
        ],
      ),
    );
  }

  Widget _buildSignUpFormView() {
    return Form(
      key: _signUpFormKey,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _buildTextFormField(
            controller: _signUpNameController,
            hintText: 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _signUpEmailController,
            hintText: 'Email Address',
            icon: Icons.email_outlined,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _signUpPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            isObscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters long';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildActionButton('CREATE ACCOUNT', () => _submitAuthSession(_signUpFormKey)),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppTheme.textWhite),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textLight, size: 20),
        filled: true,
        fillColor: AppTheme.darkCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        errorStyle: const TextStyle(color: AppTheme.danger, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.