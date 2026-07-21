import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'auth_screen.dart';

class SignInFormView extends StatefulWidget {
  final dynamic parentState; // Accessing parent structure securely

  const SignInFormView({super.key, required this.parentState});

  @override
  State<SignInFormView> createState() => _SignInFormViewState();
}

class _SignInFormViewState extends State<SignInFormView> {
  bool _obscureSignInPassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    final state = widget.parentState;

    return Form(
      key: state.signInFormKey,
      autovalidateMode: _autovalidateMode,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _buildField(
            controller: state.signInEmailController,
            hintText: 'Email Address',
            icon: Icons.email_outlined,
            validator: (val) => (val == null || !val.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: state.signInPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            isObscure: _obscureSignInPassword,
            validator: (val) => (val == null || val.isEmpty) ? 'Enter password' : null,
          ),
          CheckboxListTile(
            title: const Text('Show Password', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
            value: !_obscureSignInPassword,
            onChanged: (val) => setState(() => _obscureSignInPassword = !val!),
            activeColor: AppTheme.primaryOrange,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (state.signInFormKey.currentState!.validate()) {
                  state.submitAuthSession(true);
                } else {
                  setState(() => _autovalidateMode = AutovalidateMode.always);
                }
              },
              child: const Text('SIGN IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String hintText, required IconData icon, bool isObscure = false, required String? Function(String?) validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppTheme.textWhite),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textLight, size: 20),
        filled: true,
        fillColor: AppTheme.darkCard,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
      ),
    );
  }
}