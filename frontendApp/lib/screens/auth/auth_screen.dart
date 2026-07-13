import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/main_navigation_shell.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:frontend_app/models/auth_model.dart';
import 'package:frontend_app/services/signup_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign In controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up controllers
  final _signUpFirstNameController = TextEditingController();
  final _signUpLastNameController = TextEditingController();
  final _signUpDisplayNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  // Gender & birth date state
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  late TabController _tabController;
  bool _isLoading = false;

  // Password visibility state variables
  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;

  // Track autovalidate mode independently for both views
  AutovalidateMode _signInAutovalidateMode = AutovalidateMode.disabled;
  AutovalidateMode _signUpAutovalidateMode = AutovalidateMode.disabled;

  // Track root application screen state
  // 0 = Landing Selection screen, 1 = Form Tabs screen
  int _currentView = 0;

  // Multi-step sign-up state (Strava-style gradual reveal)
  int _signUpStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Reset sign up step and errors if user changes tabs manually
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _signUpStep = 0;
          _signInAutovalidateMode = AutovalidateMode.disabled;
          _signUpAutovalidateMode = AutovalidateMode.disabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpFirstNameController.dispose();
    _signUpLastNameController.dispose();
    _signUpDisplayNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Handle step-by-step navigation for Sign Up
  void _nextSignUpStep() {
    if (_signUpFormKey.currentState!.validate()) {
      if (_signUpStep < 2) {
        setState(() {
          _signUpStep++;
          _signUpAutovalidateMode = AutovalidateMode.disabled;
        });
      } else {
        _submitAuthSession(_signUpFormKey);
      }
    } else {
      setState(() {
        _signUpAutovalidateMode = AutovalidateMode.always;
      });
    }
  }

  void _previousSignUpStep() {
    if (_signUpStep > 0) {
      setState(() {
        _signUpStep--;
        _signUpAutovalidateMode = AutovalidateMode.disabled;
      });
    }
  }

  void _submitAuthSession(GlobalKey<FormState> activeFormKey) async {
    bool isSignIn = activeFormKey == _signInFormKey;

    if (activeFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      if (isSignIn) {
        final authResult = await AuthService.login(
          _signInEmailController.text.trim(),
          _signInPasswordController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          if (authResult != null && authResult is AuthResponse) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationShell()),
            );
          } else {
            _showStatusSnackbar('Authentication failed. Invalid credentials or server offline.', isError: true);
          }
        }
      } else {
        if (_selectedGender == null) {
          setState(() => _isLoading = false);
          _showStatusSnackbar('Please select your gender.', isError: true);
          return;
        }
        if (_selectedBirthDate == null) {
          setState(() => _isLoading = false);
          _showStatusSnackbar('Please select your date of birth.', isError: true);
          return;
        }

        final birthDateStr =
            '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}';

        final registrationSuccess = await SignupService.registerUser(
          email: _signUpEmailController.text.trim(),
          password: _signUpPasswordController.text,
          displayName: _signUpDisplayNameController.text.trim(),
          firstName: _signUpFirstNameController.text.trim(),
          lastName: _signUpLastNameController.text.trim(),
          gender: _selectedGender!,
          birthDate: birthDateStr,
          defaultActivityVisibilityId: 1,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          if (registrationSuccess) {
            _tabController.animateTo(0);
            _signInEmailController.text = _signUpEmailController.text;
            _showStatusSnackbar('Account provisioned successfully! Please sign in.', isError: false);
            _signUpEmailController.clear();
            _signUpFirstNameController.clear();
            _signUpLastNameController.clear();
            _signUpDisplayNameController.clear();
            _signUpPasswordController.clear();
            setState(() {
              _selectedGender = null;
              _selectedBirthDate = null;
              _signUpStep = 0;
              _signInAutovalidateMode = AutovalidateMode.disabled;
              _signUpAutovalidateMode = AutovalidateMode.disabled;
            });
          } else {
            _showStatusSnackbar('Registration aborted. User identity profile exists or network dropped.', isError: true);
          }
        }
      }
    } else {
      setState(() {
        if (isSignIn) {
          _signInAutovalidateMode = AutovalidateMode.always;
        } else {
          _signUpAutovalidateMode = AutovalidateMode.always;
        }
      });
    }
  }

  void _showStatusSnackbar(String message, {required bool isError}) {
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

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryOrange,
            surface: AppTheme.darkCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email address';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email format';
    return null;
  }

  // Set selected state and navigate forward to tabs
  void _navigateToTab(int tabIndex) {
    setState(() {
      _currentView = 1;
      _tabController.index = tabIndex;
    });
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
              child: _currentView == 0 ? _buildLandingView() : _buildFormTabsView(),
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

  Widget _buildLandingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const Text(
          'Welcome',
          style: TextStyle(color: AppTheme.textWhite, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Track your operational metrics and perform at your highest level.',
          style: TextStyle(color: AppTheme.textLight, fontSize: 16, height: 1.4),
        ),
        const Spacer(),
        _buildActionButton('SIGN IN', () => _navigateToTab(0)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _navigateToTab(1),
            child: const Text(
              'SIGN UP',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormTabsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        IconButton(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite, size: 22),
          onPressed: () {
            setState(() {
              _currentView = 0;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome',
          style: TextStyle(color: AppTheme.textWhite, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to track your operational metrics',
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
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
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
            controller: _tabController,
            children: [
              _buildSignInFormView(),
              _buildSignUpFormView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInFormView() {
    return Form(
      key: _signInFormKey,
      autovalidateMode: _signInAutovalidateMode,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _buildTextFormField(
            controller: _signInEmailController,
            hintText: 'Email Address',
            icon: Icons.email_outlined,
            validator: _validateEmail,
            autovalidateMode: _signInAutovalidateMode,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _signInPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            isObscure: _obscureSignInPassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              return null;
            },
            autovalidateMode: _signInAutovalidateMode,
          ),
          const SizedBox(height: 8),
          Theme(
            data: ThemeData(unselectedWidgetColor: AppTheme.textLight),
            child: CheckboxListTile(
              title: const Text('Show Password', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
              value: !_obscureSignInPassword,
              onChanged: (value) {
                setState(() {
                  _obscureSignInPassword = !value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primaryOrange,
              checkColor: Colors.white,
              dense: true,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 13)),
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
      autovalidateMode: _signUpAutovalidateMode,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
                  decoration: BoxDecoration(
                    color: index <= _signUpStep ? AppTheme.primaryOrange : Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          if (_signUpStep == 0) ...[
            _buildTextFormField(
              controller: _signUpEmailController,
              hintText: 'Email Address',
              icon: Icons.email_outlined,
              validator: _validateEmail,
              autovalidateMode: _signUpAutovalidateMode,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _signUpPasswordController,
              hintText: 'Password',
              icon: Icons.lock_outline_rounded,
              isObscure: _obscureSignUpPassword,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a password';
                if (value.length < 6) return 'Password must be at least 6 characters long';
                return null;
              },
              autovalidateMode: _signUpAutovalidateMode,
            ),
            const SizedBox(height: 8),
            Theme(
              data: ThemeData(unselectedWidgetColor: AppTheme.textLight),
              child: CheckboxListTile(
                title: const Text('Show Password', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                value: !_obscureSignUpPassword,
                onChanged: (value) {
                  setState(() {
                    _obscureSignUpPassword = !value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryOrange,
                checkColor: Colors.white,
                dense: true,
              ),
            ),
          ] else if (_signUpStep == 1) ...[
            _buildTextFormField(
              controller: _signUpFirstNameController,
              hintText: 'First Name',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter your first name';
                return null;
              },
              autovalidateMode: _signUpAutovalidateMode,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _signUpLastNameController,
              hintText: 'Last Name',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter your last name';
                return null;
              },
              autovalidateMode: _signUpAutovalidateMode,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _signUpDisplayNameController,
              hintText: 'Display Name',
              icon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter a display name';
                return null;
              },
              autovalidateMode: _signUpAutovalidateMode,
            ),
          ] else if (_signUpStep == 2) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  dropdownColor: AppTheme.darkCard,
                  hint: Row(
                    children: const [
                      Icon(Icons.wc_outlined, color: AppTheme.textLight, size: 20),
                      Spacer(),
                      Text('Gender', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                    ],
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight),
                  items: ['MALE', 'FEMALE', 'OTHER'].map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g, style: const TextStyle(color: AppTheme.textWhite)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickBirthDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.textLight, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedBirthDate == null
                          ? 'Date of Birth'
                          : '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedBirthDate == null ? AppTheme.textLight : AppTheme.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_signUpStep > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _previousSignUpStep,
                    child: const Text('BACK', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  _signUpStep == 2 ? 'CREATE ACCOUNT' : 'NEXT',
                  _nextSignUpStep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
    required AutovalidateMode autovalidateMode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppTheme.textWhite),
      validator: validator,
      autovalidateMode: autovalidateMode,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
        ),
      ),
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
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }
}